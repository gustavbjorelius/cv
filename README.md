ssh into the banhof
 - ssh debian13@158.174.210.44 {enter}
 - <the terminal will tell you 'this is the public key'> 
 - now you need to go into the console in banhof (noVNC) and check in /etc/ssh 
 - to make sure that the public key matches and make sure that there is no Man-in
 - the middle attack. Do this via 
 - ssh-keygen -lf ssh_host_ed25519_key.pub 
 - the output needs to match what you see when you 
 - ssh debian13@158.174.210.44 {enter} in your wsl2 
 - once you have made sure there is no man in the middle attach, you can say yes
 - then the remote (banhof debian) reject you because you don't have the proper 
 - ssh private key in your ~/.ssh/private-key-banhof-debian13.rsa
 - that you was given in your local (wls2) folder, so the remote will reject 
 - what you need to do is to go to banhof and get the private key 
 - download your key from banhof, put it in [while in win11] in downloads
 - then in wsl2: cp "/mnt/c/Users/chris/Downloads/{key-name}" ~/.ssh/{key-name}
 - chmod 600 ~/.ssh/{private-key-to-banhof} 
 - or else banhof ssh will reject the link as it will believe that the key is 
 - a slut; everyone has access to it...
 - then to encrypt it with the ssh-keygen -pf {path-to-key}
 - then finally, 
 - ssh -i ~/.ssh/private-key-banhof-debian13.rsa debian@158.174.210.44
 - enter passphrase for ssh to decrypt your private ssh 
 - and you're IN! 

pass (cli tool wls2)
 - PAT github "cv-kpi-page" : read:user : no expiration
 - PAT "wls2 library fix" : entire repo : expires
 - ~/.password-store/cv 

cloudflare 
 - to serve the site
 - bypass cashing for everything
 - auto HTTPS and SSL 
 - Cloudflared Tunnel 
 - as my wls2 debian was initially the server,
 - now banhof (stable IP) instead of my dynamic one? 
 - do we need a cloudflare tunnel now with banhof> 

yo@gustavbjorelius.dev
 - linked to gmail 
 - smtp forwarding through Brevy.com

gpg
 - private key in bitwarden 

MISSING 
 - ? 

bitwarden 
 - wls2 debian pass (??)
 - wls2 

banhof as the server
 - Image:debian13
 - CPU: 1
 - RAM: 1024 MB
 - Volume: 10 GB
 - IP: 158.174.210.44
 - MAC address: fa:16:3e:94:41:c7
 - User: debian13

environment
 - win11 > wls2 debian > banhof vps (serves site)

# gustavbjorelius.dev

Personal CV, blog, and KPI tracker. Running on Debian, served by nginx,
tunneled to the internet via Cloudflare Tunnel.

## Why
Learning tools for iteration speed and micromanagement.
When something breaks (and it will), I can personally fix it.
Fun. Self-authorship. Toward fullstack.
No abstractions  if I built it, I understand it.

## What
- CV page
- Blog
- KPI tracker  daily coding metrics, GitHub-style green squares
- Works on mobile (responsive)
- Nice typography and layout
- Fast loading
- Real domain + SSL (gustavbjorelius.dev)
- Full infrastructure I can micromanage

## Stack
- nginx  web server
- PHP-FPM  executes PHP files
- Cloudflare Tunnel  exposes local server to internet without open ports, SSL automatic
- Debian  OS, no abstractions
- git + GitHub  version control, IaC, backup
- vi, tmux  terminal tools

## Setup on a new machine
1. Clone this repo
2. Install nginx and PHP: `sudo apt install nginx php-fpm -y`
3. Install cloudflared: `sudo dpkg -i cloudflared.deb`
4. Authenticate: `cloudflared tunnel login`
5. Copy nginx config: `sudo cp config/nginx-cv /etc/nginx/sites-available/cv`
6. Enable site: `sudo ln -s /etc/nginx/sites-available/cv /etc/nginx/sites-enabled/`
7. Install tunnel as service: `sudo cloudflared --config ~/.cloudflared/config.yml service install`
8. Start everything: `sudo systemctl start nginx cloudflared`

## TODOs
- [ ] setup.sh to automate all setup steps
- [ ] KPI page with green squares
- [ ] Responsive mobile layout
- [ ] Blog page
- [ ] Save nginx config to repo under config/

## Why Cloudflare Tunnel
Laptop moves between networks. Tunnel means no fixed IP, no open ports,
SSL handled automatically by Cloudflare.
