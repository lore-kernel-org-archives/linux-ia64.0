From: "Verkist, Bruno" <Bruno.Verkist@fujitsu-siemens.com>
Date: Wed, 31 Oct 2001 08:35:36 +0000
Subject: [Linux-ia64] LION hangs at init 0 (kernel 2.4.13 on top of SuSE 7.2a IA64 Dev.
Message-Id: <marc-linux-ia64-105590698805419@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi all,

I have an Intel LION (8GB, 2x733MHz C0, BIOS 100, BMC 26) installed with
SuSE 7.2a IA64 Developers Edition (kernel 2.4.4). On top of it I installed
kernel 2.4.13 and the IA64 patch linux-2_4_13-ia64-011024_diff .=20

Problem: When I reboot the machine with my new 2.4.13 kernel or switch from
runlevel 1 to 0 the system hangs while executing  /etc/rc.d/rc0.d/S20halt.
The last messages I see on the screen are

Sending all processes the TERM signal...
Sending all processes the KILL signal...
...
T=FDping <Ctrl-C>: blogd: Warning: the ioctl TIOCGDEV is not know by the
kernel

After that I have to power cycle my LION (and repair my root file system
after reboot!).

Bruno

Bruno Verkist mailto:Bruno.Verkist@fujitsu-siemens.com
FSC EP PS HE4, Paderborn      Tel. +49 5251 8 15365


