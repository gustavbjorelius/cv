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
- Debian  OS, no abstractions, close to the metal
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
