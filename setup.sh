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

cp -r *.php *.css *.js $WEB_ROOT/ 
# ^ copy all .php .css .js files from current dir into web root
# ^ -r includes nested files (from where we copy files)

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

cp config/nginx-cv.conf $NGINX_SITE
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
# ^ we don't use a secrets manager as it's overkill for now
# ^ 
