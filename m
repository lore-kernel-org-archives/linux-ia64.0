From: Roy Dragseth <royd@cc.uit.no>
Date: Wed, 08 Jan 2003 21:39:24 +0000
Subject: [Linux-ia64] disabling nics in efi.
Message-Id: <marc-linux-ia64-105590709805644@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I have a bunch of HP rx2600 that have two internal nics (10/100Mbit and 1Gb=
it)=20
and one external nic (1Gbit).  Is it possible to disable the two internal=20
ones in efi so linux won't see them?  I tried to use the disconnect command=
=20
in the efi shell, but they still keep showing up when I boot up linux.
I used=20
disconnect 4C
disconnect 49
and they report successful operation.  Am I missing the point completely?

I also tried the reserve=3D boot option to avoid linux to probe them, but t=
hat=20
didn't work either.  I probably computed the iobase and extents wrong.  Do =

anyone know how to determine the correct parameters?

The reason for wanting to disable the internal nics is that the redhat=20
installer insists on fetching the kickstart file over eth0 when doing=20
installations over the network and the external nic that I want to use=20
becomes eth2.

Any hints is greatly appreciated.

Best regards,
Roy.
--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no


