From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Tue, 26 Nov 2002 17:54:36 +0000
Subject: [Linux-ia64] 2.5.45 with CONFIG_NUMA=y
Message-Id: <marc-linux-ia64-105590709805486@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Booting the 2.5.45 kernel on our numa platform, we hit 2 problems:

. Current settings for DIG are : 512MB/bank, 16GB/node,(mmzone.h)  but our
platform can support 64 GB/node (Even with less memory, bios maps
each node memory modulo 64GB).=20
As it has been cleanly coded :-), we just changed DIG_BANKSHIFT to 31=20
(2GB banks) and system runs.=20
Should these values bee incremented in the future ?

. We can't get X11 working (Xserver loops in user mode). Note that=20
it works OK with 2.5.45 without DISCONTIG_MEM set. Having a look to the
mappings in /proc/ and the XFree86 log, we saw no difference. Any idea=20
?

thanks in advance for your help.

Xavier

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________



