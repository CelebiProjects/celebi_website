# Celebi Website

The static website for the [Celebi](https://github.com/CelebiProjects/Celebi) project —
reproducible analysis management for high-energy physics.

Built with [Hugo](https://gohugo.io/), bilingual (English / 中文), no external theme or
frontend dependencies.

## Preview locally

```sh
brew install hugo   # once
hugo server
# → http://localhost:1313/  (中文: /zh/)
```

## Build

```sh
hugo            # outputs to public/
```

## Deployment (own server, celebi.labz0.org)

1. DNS: add an `A` record for `celebi.labz0.org` pointing to your server IP.
2. Server: install nginx, copy `nginx.conf.example` to
   `/etc/nginx/sites-available/celebi.labz0.org`, enable it, then
   `sudo certbot --nginx -d celebi.labz0.org` for HTTPS.
3. Deploy from this machine:

```sh
SSH_HOST=ubuntu@<server-ip> ./deploy.sh   # hugo build + rsync to /var/www/celebi.labz0.org
```

## Project layout

```
hugo.toml              site config (languages, params, links)
i18n/                  UI strings (nav, buttons, footer) in en / zh
data/en/home.yaml      homepage content — English
data/zh/home.yaml      homepage content — 中文
content/en/news/*.md   news entries — English
content/zh/news/*.md   news entries — 中文
layouts/               templates (index.html is the one-page homepage)
static/css/style.css   all styles (light + dark via prefers-color-scheme)
static/images/         logo.svg, favicon.svg
```

## Editing content

- **Homepage sections** (hero, features, terminal demo, concepts, ecosystem,
  get-started, roadmap): edit `data/<lang>/home.yaml`.
- **Add a news entry**: create matching files in `content/en/news/` and
  `content/zh/news/` with front matter `title`, `date`, `summary`.
- **Site-wide links** (GitHub, docs, license): `hugo.toml` `[params]`.
