From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 Jan 2004 01:46:21 +0000
Subject: Re: script to check for guaranteed-to-crash-your-app warnings
Message-Id: <16379.25837.133067.747494@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16379.11171.475075.708058@napali.hpl.hp.com>
In-Reply-To: <16379.11171.475075.708058@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 6 Jan 2004 13:46:52 -0800, Randolph Chung <tausq@debian.org> said:

  >> Does Debian (and other distros) keep the log files of package
  >> builds?  If so, it would be interesting to run the script over
  >> those log files and see what else crops up.

  Randolph> see http://buildd.debian.org/

"They" don't make it easy, do they??

So here is what I did: I ran the attached debian-fetch-log script to
fetch as many build-log files as possible from the 1282 packages
listed in /var/lib/dpkg/available on my "unstable" machine.  That
netted 485 log files (see second attachement) on which I ran the
checker script:

 $ debian-fetch-log $(fgrep Package: /var/lib/dpkg/available | cut -f2 -d' ')
 $ for f in *.log; do echo checking $f...; \
	cat $f | ~/scripts/check-implicit-pointer-functions ; done
   :
 checking gnome-iconedit.log...
 Function `ie_model_get_pixel' implicitly converted to pointer at grid.c:417
 Function `ie_model_get_pixel' implicitly converted to pointer at mode.c:54
   :
 checking gnome-media.log...
 Function `device_from_name' implicitly converted to pointer at prefs.c:119
   :
 checking libgsm.log...
 Function `fdopen' implicitly converted to pointer at src/toast.c:510

I verified that gnome-iconedit can be crashed easily by selecting the
"color-picker" tool in the left bar and clicking on a icon-pixel.  I
didn't check gnome-memdia or libgsm, but I have high confidence that
the reported problems are indeed real bugs.

Anyone willing to help me get bug-reports/patches filed against these
packages?

Thanks,

	--david

<--- debian-fetch-log --><--- debian-fetch-log --><--- debian-fetch-log -->
#!/bin/sh
# fetch the log file for packages $*
tmpfile=$(mktemp)
for pkg in $*; do
    echo -n "Fetching log for package $pkg: "
    version=$(dpkg -s $pkg | grep '^Version: ' | cut -f2 -d' ')
    if [ -z "$version" ]; then
	echo "No version found"
	continue
    fi
    srcpkg=$(dpkg -s $pkg | grep '^Source: ' | cut -f2 -d' ')
    if [ -n "$srcpkg" ]; then
	pkg=$srcpkg
    fi
    socksify wget --quiet -O$tmpfile "http://buildd.debian.org/build.php?arch=ia64&pkg=$pkg"
    line=$(fgrep $version $tmpfile)
    vpattern=$(echo $version | sed 's,\(.\),[\1],g')
    uri=$(expr "$line" : ".*>$vpattern</a> (latest build at <a href=\"\([^\"]*\)\"")
    if [ -n "$uri" ]; then
	socksify lynx --dump "http://buildd.debian.org/$uri" > $pkg.log
	echo "OK"
    else
	echo "Failed"
    fi
done
rm -f $tmpfile

<-- checked package list -->
a2ps
a52dec
aalib
abiword
acl
adns
afio
alsa-lib
analog
anjuta
apmd
apt
aptitude
arts
asclock
aspell-en
aspell
at-spi
at
atk1.0
attr
audiofile
aumix
base-files
base-passwd
bc
biff
bigloo
bind9
binutils
bison
bluefish
bluez-libs
bluez-pin
bluez-sdp
bluez-utils
bonnie++
bonobo-activation
bonobo-conf
bonobo
bsd-finger
bsdmainutils
build-essential
byacc
bzip2
c2man
cdparanoia
cflow
console-tools
control-center
coreutils
cpio
cramfs
cron
csh
cupsys
curl
cutils
cvs
cxref
cyrus-sasl
cyrus-sasl2
dante
dash
db1-compat
db2
db4.0
db4.1
dbus
debianutils
devhelp
devscripts
dhcp
dia
dialog
dictd
diff
diffstat
docbook-to-man
dosfstools
doxygen
dpkg
e2fsprogs
ed
eel
eel2
eject
emacs21
enlightenment
enscript
esound
eterm
ethereal
etherwake
ethtool
evolution
exim
expat
expect
exuberant-ctags
fam
fbset
fdutils
file
findutils
flac
flex
fnlib
fontconfig
fortune-mod
freetype
freetype1
fribidi
ftnchek
fweb
gail
gal
gal2
gawk
gconf
gconf2
gdb
gdbm
gdbm173
gdk-pixbuf
gdkxft
gdm
gettext
gimp-print
gimp
gkrellm-gnome
gkrellm-radio
gkrellm-volume
gkrellm
gkrellmms
glade-2
gle
glib1.2
glib2.0
gmp
gnet1.1
gnome-alsamixer
gnome-applets
gnome-breakout
gnome-core
gnome-desktop
gnome-iconedit
gnome-libs
gnome-media
gnome-panel
gnome-pilot
gnome-print
gnome-session
gnome-terminal
gnome-themes
gnome-utils
gnome-vfs
gnome-vfs2
gnubiff
gnumeric
gnutls5
gnutls7
gperf
gpm
gqview
grep
groff
gs
gst-plugins
gstreamer
gtk+1.2
gtk+2.0
gtk-doc
gtk-industrial-engine
gtk-smooth-engine
gtk2-engines
gtkdiff
gtkhtml
gtkhtml3.0
gtksourceview
gtkspell
gtranslator
gucharmap
guile-1.6
guile-core
gv
heimdal
help2man
hermes1
host
hostname
html2text
ifupdown
imagemagick
imlib+png2
imlib
imlib2
indent
ipchains
iproute
iptables
ispell
jade
kbackup
kdebase
kdelibs
knews
koffice
krb4
krb5
lcms
less
lesstif1-1
libabz
libao
libapt-pkg-perl
libart-lgpl
libast1
libber
libbonobo
libbonoboui
libcap
libcapplet
libdbd-mysql-perl
libdbi-perl
libdebug
libdv
libdvbpsi
libdvbpsi2
libdvdplay
libdvdread
libedit
libelf
libgc
libgcrypt
libgcrypt7
libgd
libgd2
libgda2
libghttp
libglade
libglade2
libgnome
libgnomecanvas
libgnomedb
libgnomeprint
libgnomeui
libgpg-error
libgsf
libgsm
libgtk-perl
libgtkhtml2
libgtop
libgtop2
libhtml-parser-perl
libid3tag
libident
libidl
libidn
libjcode-pm-perl
libjpeg6b
liblocale-gettext-perl
liblockfile
libmad
libmikmod
libmng
libmrproject
libmysqlclient-lgpl
libnss-db
libogg
libole2
libopenobex
libpaper
libpcap
libpng
libpng3
libproplist
librep
librsvg
librsvg2
libsdl1.2
libsigc++-1.2
libsigc++
libsoup
libsynce
libtasn1
libtext-charwidth-perl
libtext-iconv-perl
libtextwrap
libtool
libungif4
libunicode
libusb
libvorbis
libwmf
libwnck
libxml-parser-perl
libxml
libxml2
libxmltok
libxslt
libzvt
linc
linux-kernel-headers
lirc
liwc
logrotate
lpr
lsof
lwm
lynx
lzo
m4
magicfilter
mailx
make
man-db
mawk
mc
medusa
menu
metacity-setup
metacity
metamail
mgp
minicom
module-init-tools
modutils
moon-buggy
mozilla
mpack
mpg321
mtools
mtr
multisync
mutt
mysql-dfsg
nano
nas
nautilus
nautilus1
ncftp
ncurses
net-tools
netcat
netkit-base
netkit-ftp
netkit-rsh
netkit-telnet
netpbm-free
newt
nfs-utils
nmh
ntp
nvi
oaf
opencdk
opencdk8
openldap2
openslp
openssh
openssl
openssl096
orbit
orbit2
pam
pan
pango1.0
patch
pciutils
pcre3
pdksh
perl-tk
perl
perlftlib
pilot-link
pkgconfig
popt
portmap
postgresql
powermgmt-base
ppp
procmail
procps
psmisc
pspell-ispell
pspell
psutils
pyorbit
python-gnome2
python-gtk2
python-iconvcodec
python-numeric
python1.5
python2.1
python2.2
python2.3
qt-x11-free
qt-x11
quake2
rcs
rdist
readline4
recode
rep-gtk
rplay
rpm
rsync
rxvt
sawfish
schedutils
screen
scrollkeeper
scsiadd
sdl-mixer1.2
sed
setserial
shadow
sharutils
slang
smpeg
sox
speex
startup-notification
strace
swfdec
symlinks
synce-dccm
sysklogd
sysstat
sysvinit
t1lib
tasksel
tcl8.3
tcl8.4
tcp-wrappers
tcpdump
tcsh
tetex-bin
texinfo
tftp-hpa
tiff
time
tin
tinysnmp
tk8.3
tk8.4
traceroute
tree
tuxracer
ucd-snmp
unzip
update
usbutils
usbview
uw-imap
vacation
vim
vlc
vm
vte
vtwm
w3c-libwww
wget
whois
wmaker
xaw3d
xchat
xcursor
xfree86
xft
xft2
xgalaga
xli
xmms
xosd
xpaint
xpdf
xrender
xscreensaver
xzgv
yelp
zip
zlib
zsh
