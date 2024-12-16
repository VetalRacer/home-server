# Nginx-proxy

Nginx-proxy service proxies requests to internal services

You can find all configs in `roles/nginx-proxy/templates/nginx-proxy/conf.d/` folder

# Gitlab

Gitlab service help planning to production, brings teams together to shorten cycle times, reduce costs, strengthen security, and increase developer productivit

# Samba

Samba service provides file and print services for various Microsoft Windows clients and can integrate with a Microsoft Windows Server domain, either as a Domain Controller (DC) or as a domain member. As of version 4, it supports Active Directory and Microsoft Windows NT domains.

You can find all configs in `roles/samba/templates/samba/` folder

# Transmission

Transmission is a light-weight and cross-platform BitTorrent client.

You can read more about configured [here](https://hub.docker.com/r/linuxserver/transmission)

# Plex

Plex is an American streaming media service and a client–server media player platform, made by Plex, Inc. The Plex Media Server organizes video, audio, and photos from a user's collections and from online services, and streams it to the players. The official clients and unofficial third-party clients run on mobile devices, smart TVs, streaming boxes, and in web apps.

You can read more about configured [here](https://hub.docker.com/r/linuxserver/plex)

# Homepage

A modern (fully static, fast), secure (fully proxied), highly customizable application dashboard with integrations for more than 25 services and translations for over 15 languages. Easily configured via YAML files (or discovery via docker labels)

You can read more about configured [here](https://gethomepage.dev/en/installation/)

# FileBrowser

File Browser provides a file managing interface within a specified directory and it can be used to upload, delete, preview, rename and edit your files. It allows the creation of multiple users and each user can have its own directory.

You can read more about configured [here](https://filebrowser.org/)

# Pi-hole

Pi-hole is a Linux network-level advertisement and Internet tracker blocking application which acts as a DNS sinkhole and optionally a DHCP server, intended for use on a private network.

You can read more about configured [here](https://github.com/pi-hole/docker-pi-hole) or [here](https://docs.pi-hole.net/)

# ps3netsrv

Is a server application used to stream content from a remote server to the PS3.

You can read more about configured [here](https://github.com/shawly/docker-ps3netsrv) or [here](https://github.com/aldostools/webMAN-MOD/wiki/~-PS3-NET-Server)

# Speedtest-Tracker

This service runs a speedtest check every hour and graphs the results. The back-end is written in Laravel and the front-end uses React. It uses Ookla's Speedtest cli to get the data and uses Chart.js to plot the results.

You can read more about configured [here](https://github.com/henrywhitaker3/Speedtest-Tracker) or [here](https://hub.docker.com/r/henrywhitaker3/speedtest-tracker)

# Overseerr
This is a request management and media discovery tool built to work with your existing Plex ecosystem.

You can read more about configured [here](https://hub.docker.com/r/linuxserver/overseerr)

# Sonarr
This is a PVR for usenet and bittorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

You can read more about configured [here](https://hub.docker.com/r/linuxserver/overseerr)

# Radarr
A fork of Sonarr to work with movies à la Couchpotato.

You can read more about configured [here](https://hub.docker.com/r/linuxserver/radarr)

# Jackett
Jackett works as a proxy server: it translates queries from apps (Sonarr, SickRage, CouchPotato, Mylar, etc) into tracker-site-specific http queries, parses the html response, then sends results back to the requesting software. This allows for getting recent uploads (like RSS) and performing searches. Jackett is a single repository of maintained indexer scraping & translation logic - removing the burden from other apps.

You can read more about configured [here](https://hub.docker.com/r/linuxserver/jackett)

# TVHeadend
Tvheadend works as a proxy server: is a TV streaming server and recorder for Linux, FreeBSD and Android supporting DVB-S, DVB-S2, DVB-C, DVB-T, ATSC, ISDB-T, IPTV, SAT>IP and HDHomeRun as input sources. Tvheadend offers the HTTP (VLC, MPlayer), HTSP (Kodi, Movian) and SAT>IP streaming. Multiple EPG sources are supported (over-the-air DVB and ATSC including OpenTV DVB extensions, XMLTV, PyXML).

You can read more about configured [here](https://hub.docker.com/r/linuxserver/tvheadend)

# MeTube
Web GUI for youtube-dl (using the yt-dlp fork) with playlist support. Allows you to download videos from YouTube and dozens of other sites (https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md).

You can read more about configured [here](https://hub.docker.com/r/alexta69/metube)

# Nexus
Nexus3 Disaster Recovery (N3DR) is a tool that is capable of downloading all artifacts from a Nexus3 server and to migrate them to another one.

You can read more about configured [here](https://hub.docker.com/r/sonatype/nexus3)

# Prometheus
Prometheus is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true.

You can read more about configured [here](https://hub.docker.com/r/prom/prometheus)

# Grafana
Grafana allows you to query, visualize, alert on and understand your metrics no matter where they are stored. Create, explore, and share dashboards with your team and foster a data-driven culture.

You can read more about configured [here](https://hub.docker.com/r/grafana/grafana) or [here](https://github.com/grafana/grafana)

# Postgres
Postgres is a free and open-source relational database management system (RDBMS) emphasizing extensibility and SQL compliance.

You can read more about configured [here](https://hub.docker.com/_/postgres)

# pgAdmin
pgAdmin 4 is a web based administration tool for the PostgreSQL database. 

You can read more about configured [here](https://www.pgadmin.org/support/list/)

# MotionEye
MotionEye is an online interface for the software motion, a video surveillance program with motion detection.

You can read more about configured [here](https://github.com/motioneye-project/motioneye/tree/dev)

# Torrserver
TorrServer, stream torrent to http.

You can read more about configured [here](https://github.com/YouROK/TorrServer)

# TubeArchivist
Your self hosted YouTube media server

You can read more about configured [here](https://github.com/tubearchivist/tubearchivist) or [here](https://www.tubearchivist.com/)

# Nextcloud
Your self hosted Nextcloud server. A safe home for all your data. Access & share your files, calendars, contacts, mail & more from any device, on your terms.

You can read more about configured [here](https://hub.docker.com/_/nextcloud) or [here](https://github.com/nextcloud/docker)

# Whoogle
Get Google search results, but without any ads, JavaScript, AMP links, cookies, or IP address tracking. Easily deployable in one click as a Docker app, and customizable with a single config file. Quick and simple to implement as a primary search engine replacement on both desktop and mobile.

You can read more about configured [here](https://hub.docker.com/r/benbusby/whoogle-search) or [here](https://github.com/benbusby/whoogle-search)