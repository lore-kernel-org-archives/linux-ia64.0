From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Mon, 21 Oct 2002 16:16:31 +0000
Subject: [Linux-ia64] Re: Planned removal of USB keyboard support from kdb
Message-Id: <marc-linux-ia64-105590709805200@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi, Keith
Keith Owens writes:
 > Sebastien Lelarge did a patch for USB keyboard support in kdb, to
 > support IA64 machines made by Bull.  AFAICT nobody has managed to get
 > this code to work, including the USB maintainer.  The USB code in kdb
 > for 2.5 kernels is a straight copy of the 2.4 code and will not even
 > compile, I have asked for updates to make it work on 2.5 with no
 > response.
 >=20
 > Has anybody got USB keyboard support to work on 2.4 kernels?
 >=20

It works OK on 2.4.19 ia64.

 > If it works on 2.4, will anybody make USB support work in kdb for 2.5
 > kernels?  i386 only will do, kdb for ia64 is waiting for a current ia64
 > 2.5 patch from David Mosberger (away at the moment).
 >=20

It should not be a big problem to have it working on 2.5 ia64.=20

 > Without evidence that this feature works and support for 2.5 kernels,
 > USB keyboard support will be removed from kdb.  I will wait until
 > November 12 before deciding.
The Tiger machines have no PS2 keyboard, and even if we can use a
serial console to debug, it is interesting to have kdb working on USB.

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________



