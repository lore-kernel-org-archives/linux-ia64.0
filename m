From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Wed, 27 Nov 2002 16:22:04 +0000
Subject: Re: [Linux-ia64] 2.5.45 with CONFIG_NUMA=y
Message-Id: <marc-linux-ia64-105590709805493@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805486@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805486@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Jesse
Thanks a lot for your answers.

Jesse Barnes writes:
 > On Tue, Nov 26, 2002 at 06:54:36PM +0100, Xavier Bru wrote:
 > >=20
 > > Hi,
 > >=20
 > > Booting the 2.5.45 kernel on our numa platform, we hit 2 problems:
 > >=20
 > > . Current settings for DIG are : 512MB/bank, 16GB/node,(mmzone.h)  but=
 our
 > > platform can support 64 GB/node (Even with less memory, bios maps
 > > each node memory modulo 64GB).=20
 > > As it has been cleanly coded :-), we just changed DIG_BANKSHIFT to 31 =

 > > (2GB banks) and system runs.=20
 > > Should these values bee incremented in the future ?
 >=20
 > Maybe that should be an option for the kernel configuration system?

This should be OK for us.

 >=20
 > > . We can't get X11 working (Xserver loops in user mode). Note that=20
 > > it works OK with 2.5.45 without DISCONTIG_MEM set. Having a look to the
 > > mappings in /proc/ and the XFree86 log, we saw no difference. Any idea=
=20
 > > ?
 >=20
 > Does X initialize your card correctly?  I know that scanning /dev/mem
 > for video cards (which is what XFree86 does, IIRC) can be problematic on
 > some platforms...

Seems that we use the VGA mode through /dev/mem (No driver is actually=20
loaded).=20
Are there some known problems with /dev/mem and DISCONTIG_MEM ?=20
Do you think we should have more chances validating Frame buffer support an=
d the
card driver ? (I think platform has no AGP support).
 >=20
 > Jesse
Thanks again.
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

