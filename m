From: Michael Di Domenico <mdidomenico4@gmail.com>
Date: Thu, 10 Sep 2009 18:25:04 +0000
Subject: elilo questions
Message-Id: <e75d22a90909101125y26dcd5cdob8f374e2dc160536@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hopefully someone here can either help or point me in the right
direction.  I've gotten an IA64 system (hp rx2600) to boot via
PXE(elilo) and install RedHat v5.3, but I've run into a few issues:

1.  When i try to use a kickstart line with an ampersand in it, for
some reason the ampersand's don't seem to make it through to the HTTP
server, for example

ks=3Dhttp://server/ks/ks.cgi?hostname=AAa&option1=BBb is what i set, but
if i look at the URI_QUERY_STRING on the webserver i get
'?hostname=AAaoption1=BBb'

If i take out the ampersand and just use ks=3Dhttp://server/ks/aaa.ks it
seems to work fine

2.  I'd like to setup the machines to boot from network everytime, via DHCP

2a.  first issue, after i do a kickstart install it resets the systems
EFI firmware to boot from the hard disk by default rather then the
network card, is there a way to force it to always boot from the nic
first regardless or prevent something from changing the settings

2b.  i can't seem to get the system to boot off the HDD after booting
from the network.  i want the system to boot off the network first and
then if no commands are entered, i want it to boot from the hard
drive.  with PXE, it has a 'localboot' option which falls through if
no input is entered

Thanks
