From: Xavier Bru <Xavier.Bru@bull.net>
Date: Thu, 10 Jul 2003 14:50:27 +0000
Subject: kdb v4.3 for 2.5.72 ia64
Message-Id: <marc-linux-ia64-105784864810217@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Hello all,

I updated the previous port of kdb on 2.5.72 ia64 to kdb v4.3 on:
	         http://www.bullfreeware.com/linux/kdb=20

It has same limitations, just a fix for calling bh_enable() only when
interrupts are enabled (Problem is seen on 2.5 when kdb() is called
from kdb_ipi(), due to 	WARN_ON() in this code, but also exists in 2.4).

Hoping this can help. Please don't expect too much fixes from me until=20
september.

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



Xavier Bru writes:
 > Hello Keith & all,
 >=20
 > I put on:
 >       http://www.bullfreeware.com/linux/kdb=20
 > patches that work on our IA64 platform with kernel 2.5.72.
 >=20
 > It is based on kdb v4.1 ia64 for 2.4.20, and the initial port you have=20
 > done of kdb i386 on 2.5.45.
 >=20
 > The result is far from perfect.
 > Major restrictions are:
 > . only arch ia64 support.
 > . no keyboard support (debug through serial line only:
 >      - new ia64 platforms have no AT keyboard.
 >      - the kdb USB keyboard driver developped by Sebastien Lelarge
 >        still needs to be ported on new USB code.
 > . breakpoints still deadlock in SMP.
 > . no section, rmmod commands.
 > . mca/init  not tested.
 >=20
 > What should work:
 > . parameters support.
 > . kernel & module symbols.
 > . new tpa command that translates virtual to physical addresses (ia64).
 >=20
 > I hope this can be help, as kdb is really mandatory for 2.5.=20
