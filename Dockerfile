FROM fedora

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN dnf update -y && \
    dnf install -y git rubygem-{bundler,thor,ffi} ruby-devel redhat-rpm-config gcc{,-c++} \
                   libxml2-devel nodejs 'dnf-command(builddep)' python-markdown && \
    dnf builddep -y gobject-introspection && \
    dnf install -y glib2-devel gtk3-devel webkitgtk4-devel clutter-gtk-devel cairo-devel \
                   gstreamer1-{,plugins-base-}devel pango-devel vte3-devel \
                   gtksourceview3-devel libappstream-glib-devel gspell-devel polkit-devel \
                   libappindicator-gtk3-devel gobject-introspection-devel \
                   libsecret-devel gsound-devel gupnp-devel gupnp-dlna-devel harfbuzz-devel \
                   ibus-devel keybinder3-devel NetworkManager-glib-devel librsvg2-devel \
                   telepathy-glib-devel tracker-devel upower-devel libgudev-devel udisks-devel && \
    git clone https://github.com/ptomato/devdocs -b gir-redux --depth=1 /opt/devdocs && \
    git clone https://github.com/ptomato/gobject-introspection -b wip/ptomato/devdocs --depth=1 /opt/gi && \
    cd /opt/devdocs && sed -i s/2.3.0/2.3.3/ Gemfile && bundle install && \
    cd /opt/gi && ./autogen.sh && make install

WORKDIR /opt/devdocs
RUN thor gir:generate_all && \
    thor docs:list && \
    for docset in appindicator301 appstreamglib10 atk10 atspi20 cairo10 cally10 clutter10 cluttergdk10 \
                  clutterx1110 cogl10 cogl20 coglpango10 coglpango20 css dbus10 dbusglib10 dbusmenu04 \
                  fontconfig20 freetype220 gdk30 gdkpixbuf20 gdkx1130 gio20 girepository20 gl10 glib20 \
                  gmodule20 gobject20 gsound10 gspell1 gssdp10 gst10 gstallocators10 gstapp10 gstaudio10 \
                  gstbase10 gstcheck10 gstcontroller10 gstfft10 gstnet10 gstpbutils10 gstrtp10 gstrtsp10 \
                  gstsdp10 gsttag10 gstvideo10 gtk30 gtkclutter10 gtksource30 gudev10 gupnp10 gupnpdlna20 \
                  gupnpdlnagst20 ibus10 javascript json10 keybinder30 libxml220 networkmanager10 \
                  nmclient10 pango10 pangocairo10 pangoft210 pangoxft10 polkit10 polkitagent10 rsvg20 \
                  soup24 soupgnome24 telepathyglib012 tracker10 trackercontrol10 trackerminer10 \
                  upowerglib10 vte290 webkit240 webkit2webextension40 win3210 xfixes40 xft20 xlib20 \
                  xrandr13; \
      do thor docs:generate $docset --force; done

EXPOSE 9292
CMD rackup -o 0.0.0.0