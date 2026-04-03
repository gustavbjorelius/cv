#!/bin/bash
# ^ the shebang - tells the os to run this script w bash interpreter 

# sudo bash setup.sh 
# ^ required as it writes to system directories 

set -e
# ^ Fail FAST. So if ANYTHING produces a non-0 exit code, STOP the script



# These are path variables. 
# They will be defined once and reused throughout the script. 
# Simpler to change them in ONE PLACE rather then many. 

WEB_ROOT="/var/www/cv" 
# ^ Standard Linux location for web-served files 

CONFIG_DIR="/etc/cv" 
# ^ Standard location for app configs/secrets

NGINX_SITE="/etc/nginx/sites-available/cv"
# ^ Where nginx looks for site configs

LOG_FILE="/etc/logrotate.d/cv" 
# ^ config file for logrotate 


apt-get update 
# ^ apt-get == CLI tool for the APT package manager 
# ^ APT == remote server and we are updating our cashe of available pkgs and versio
# ^ update == downloads a list of available package + versions 
# ^ update !== upGRADE == upGRADES existing (installed) packages
# ^ important so when we run the command below (apt-get install) we DON'T 
# ^ install old packages

apt-get install -y nginx php-fpm php-curl
# ^ install these packages
# ^ -y == Just Do It (TM) 

echo "=== Deploying to FHS Standard Paths"
# ^ Prints a status message to the user 

mkdir -p $WEB_ROOT
# ^ -p == no error if path extant + create nesessary parent dir 

cp -r ~/cv/public/. $WEB_ROOT/
# separation of concern - what is in the public dir is what can go online, the \
# other files in the cv dir like README and setup.sh stays out
# Something I don't understand is the flow chart between this and sites-available
# for this to work, you ovb. need to make these changes in the dev env

# cp -r ~/cv/*.php ~/cv/*.css ~/cv/*.js $WEB_ROOT/ 
# this is not future proof--what about when you add a .jpg in the future? 
# ^ copy all .php .css .js files from ~/cv -> web root 
# ^ -r includes nested files (from where we copy files)
# ^ the ~/cv/ is from where the git pull will put cv in as we'll by default spawn \
# ^ in to ~/
# ^ we select a limited number of  file-types to put into web root - we don't want\
# ^ to put README and this setup script into it 

chown -R www-data:www-data $WEB_ROOT
# ^ www-data is a restricted user created specifically for nginx/PHP-FPM
# ^ if website hacked; the pwner can only act with www-data perms 
# ^ and will not get control to rest of my debian
# ^ before this cmd, /var/www/cv is owned by root (owned whoever ran cp) -
# ^ and this was sudo (root) as described above  
# ^ after, owned by www-data
# ^ linux processes are run by users; files are viewed, read, executed by users
# ^ linux files are OWNED by users 
# ^ file is owned by
# ^ chown TRANSFERS ownership it DOESN'T create users or permissions
# ^ the USER www-data was created when apt-get install nginx
# ^ nginx (the process) runs as www-data, bc linux processes run as USERS
# ^ permissions (as in rwx) set what the OWNER of the file can do
# ^ -R == recursive (for all nested files)
# ^ www-data:www-data <=> user:group

chmod -R 755 $WEB_ROOT
# ^ -R == recursive (applies to nested files/folders)
# ^ 7:5:5 == owner:group:others
# ^ 7 == 4 + 2 + 1 == r + w + x == true + true + true
# ^ 5 == 4 + 0 + 1 == true + false + true 
# ^ 5 == 4 + 0 + 1 == true + false + true 
# ^ let the owner (www-data) rwx
# ^ let the group (www-data) r-x  
# ^ let everyone else r-x
# ^ /var/www/cv/                       <- chmod 755 applied
# ^ /var/www/cv/index.php              <- chmod 755 applied
# ^ /var/www/cv/style.css              <- chmod 755 applied
# ^ /var/www/cv/components/header.php  <- chmod 755 applied
# ^ so, its NOT granular, and we DON'T need granular rn
# ^ $WEB_ROOT expands to /var/www/cv at runtime 

# find $WEB_ROOT -type d -exec chmod 755 {} \;  # dirs: need x to traverse
# find $WEB_ROOT -type f -exec chmod 644 {} \;  # files: no x needed
# ^ if necessary in the future 

mkdir -p $CONFIG_DIR
# ^ expand out to /etc/cv @ runtime 
# ^ -p == throw no error if extant && mk necessary parent dir 

chmod 700 $CONFIG_DIR
# ^ set permissions for owner: rwx==421, group: ---==000, others: ---==000
# ^ on the folder /etc/cv
# ^ root can do everything on this dir, nobody else can do anything 
# ^ root owns this dir, as that user created it from sudo bash setup.sh
# ^ so, www-data CANNOT do anything with this folder, or anything in it
# ^ meaning, a pwner would NOT be able to get my secrets - 
# ^ they would be restricted (or 'jailed') to www-data perms

cp config/nginx-cv.prod.conf $NGINX_SITE
# ^ edit files here + they are symlinked to 'sites-enabled' + 
# ^ ngnix -t && systemctl restart nginx
# ^ these changes are reflected instantly online 
# ^ copy the file in this dir to /etc/nginx/sites-available/cv
# ^ for nginx, 'sites-available' is the 'private' dir 
# ^ from this dir, you can yeasily link sites to -> 

ln -sf $NGINX_SITE /etc/nginx/sites-enabled/cv
# ^ -> this folder
# ^ nginx LOAD what is in this folder - create/delete symlinks = 
# ^ take sites online / offline
# ^ ln == link these two
# ^ -s == symbolic link (bash alias) pointer, not copy
# ^ -f == force == overwrite if symlink extant

rm -f /etc/nginx/sites-enabled/default
# ^ delete this SYMLINK else nginx might render the wrong page 
# ^ -f == no error if it doesn't exist

echo "=== Installing Cloudflare Tunnel"
# ^ Q: Why should this be here and not anywhere else in the script? Why before \
# ^ nginx start? A: Because this is what nginx will use to communicate with \
# ^ cloudflare - through the fucking tunnel. Good idea to install it before \
# ^ trying to initiate contact. 

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    CLOUDFLARED_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    CLOUDFLARED_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH. Run uname -m to identify, then include this in the logic of the setup script. Thank you."
    exit 1
    # this is the critial part of the setup script; it fails here if the above \
    # logic doesn't include the existing 
fi

curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$CLOUDFLARED_ARCH.deb -o /tmp/cloudflared.deb
# ^ Q: Check correct version? A: run uname -m on server if x86_64 == amd64 : True\
# ^ then this is the right version. 
# ^ /tmp in trixie == tmpfs == RAM, but is limited to 50% of RAM (default)
# ^ /tmp is VERY FAST in trixie, compared to bookworm :3
# ^ /tmp is automatically deleted after 10 days
# ^ /tmp conf in /usr/lib/tempfiles.d/tmp.conf
# ^ df -h /tmp == how much RAM is eaten? 
# ^ if /tmp is too small, use /var/tmp 
# ^ in THIS case, we know that 
# ^ -L == follow redirects 
# ^ -o == output file path 

dpkg -i /tmp/cloudflared.deb
# ^ dpkg == low level debian package manager
# ^ -i == INSTALL
# ^ apt-get handles dependencies, dpkg installs directly, if it fails, fix it by \
# ^ running sudo apt install -f right after failure
# ^ dpkg is low level, does not handle deps, it can only work with local .deb 
# ^ if there is a missing dep, it will only warn
# ^ it does not have internet access, as compared to apt-get and apt 
# ^ dpkg lets you exclude files in installation by --path-exclude, keeping your \
# ^ system lean 

rm /tmp/cloudflared.deb
# ^ we've installed, now free the RAM (very important in trixie)

cat > $LOG_FILE << ILOVEME
# 🪵🔄️
# When services starts, they will begin to produce logs. Logrotate defines \
# how these logs are managed. 
# This needs to be AFTER install of -whatever we are logging- and BEFORE \
# systemctl restart - it's important habit to define what happens to logs before\
# the services produces them. 

/var/log/nginx/*.log {
    daily
     # do this daily
    rotate 7 
     # delete log entries / files after day 7
    compress
     # compress files every day
    missingok
     # if there is a logfile missing: don't throw an error
    notifempty
     # if the logs are empty, no need to rotate/MANAGE them as defined here
}
/var/log/php8.2-fpm.log {
    daily
    rotate 7 
    compress
    missingok
    notifempty
}
ILOVEME

systemctl restart php*-fpm
# ^ systemctl interacts with systemd
# ^ systemd == INIT system of daemons and services; nginx being one of them
# ^ here, we restart after install, as installing it IMMEDIATELY starts a service,
# ^ reloading it after installation is good praxis so it runs cleanly as it could 
# ^ otherwise bring with it some config and use that instead of our config 
# ^ specifically $NGINX_SITE 
# ^ the * == php{whatever version we get, it will work for it}-fpm

nginx -t && systemctl restart nginx
# ^ nginx -t == test / LINT (don't start it) dry run
# ^ the && makes what comes after the && run iff what was before successful 
# ^ this prevents the site breaking mid-session for someone 
# ^ LINT comes from an old C tool called lint; scanned for errors w/o execution
# ^ nginx -t ;;; python -m py_compile file.py ;;; eslint app.js == lint

echo "Done. Site lives at: $WEB_ROOT"
# ^ informs the user that setup.sh worked and reminds where cv is in filesystem

echo "Put your token in: $CONFIG_DIR/github-token"
# ^ Manually by user for opsec; the script shouldn't know the secret
# ^ we don't use a secrets manager as it's overkill for now on the SERVER, while \
# ^ a using pass in the dev env is NOT overkill
# ^ Threat model: to answer the question, who can get to this file, and how? \ 
# ^ SSHing in, they need my private key, and passphrase == bigger problem than \
# ^ the PAT. Someone exploiting nginx/PHP->they'd run as www-data, which has 0 \
# ^ perms in /etc/cv (chmod 700 == root ownership). Banhof got physical access \
# ^ and I trust them. The token is protected by two layers: ssh + file perms. To \
# ^ to get via ssh the pass is necessaty, to change the file params (from www-data\# ^ you need the root password.  
# ^ so a server is different from a laptop, in that a laptop moves around through\
# ^ different networks, the laptop also got windows underneath where any program\ 
# ^ Since any windows program can see the files in wsl2, there is a reason to have\
# ^ it encrypted with pgp.
# ^ an attacker needs to penetrate both. To get the 

echo ""
echo "=== Manual steps necessary for Cloudflare Tunnel ==="
echo "Run these in order, after script finished:"
echo ""
echo " 1. cloudflared tunnel login" 
echo "    (this opens browser, auth w cloudflare in BROWSER)"
echo ""
echo " 2. cloudflared tunnel create cv"
echo "    (note the tunnel ID you get)"
echo ""
echo " 3. Create ~/.cloudflared/config.yml with:"
echo "    tunnel: cv"
echo "    credentials-file: /home/debian13/.cloudflared/<tunnel-id>.json"
echo "    ingress:"
echo "     - hostname: gustavbjorelius.dev"
echo "       service: http://localhost:80"
# cloudflare talks to nginx via http inside the tunnel
# we reach out to cloudflare with a tunnel, then cloudflare talks to us through it
# nginx does not manage SSL - cloudflare handles that for us
echo "     - service: http_status:404"
echo ""
echo " 4. cloudflared tunnel route dns cv gustavbjorelius.dev"
echo ""
echo " 5. sudo cloudflared --config ~/.cloudflared/config.yml service install"
echo " 6. sudo systemctl start cloudflared"
