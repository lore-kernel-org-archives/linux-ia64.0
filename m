From: Andreas Schwab <schwab@suse.de>
Date: Sat, 24 Mar 2007 09:17:24 +0000
Subject: sata-vsc broken on SGI Prism
Message-Id: <je8xdnova3.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, jeff@garzik.org

I'm getting this panic when loading sata-vsc on a SGI Prism:

Loading sata_vsc
ACPI: Unable to derive IRQ for device 0001:00:03.0
ACPI: PCI Interrupt 0001:00:03.0[A]: no GSI
FRZ XN request short error.=20
FRZ XN error detail 1A:
	Command word: 0x11
	Supplemental: 0xff
	Source node id: 0x0
	Source chip id: 0x2
	Destination chip id: 0x0
	Data error: 0x0
	Echo: 0x70
	Valid: 0x0
	Address: 0x1802000021
FRZ XN error detail 1B:
	Command word: 0x0
	Supplemental: 0x0
	Source node id: 0x0
	Source chip id: 0x0
	Destination chip id: 0x0
	Echo: 0x0
	Valid: 0x0
	Address: 0x0
Fatal ICE HW error
Kernel panic - not syncing: hub_eint_handler: Fatal TIO Error

Bisection has identified this patch (together with the follow-up patch to
fix the compilation failure):

commit 7cbaa86b937b0b1fab95c159989f6a3c00bbcf78
Author: Dan Wolstenholme <daniel@wolstenholme.net>
Date:   Tue Jan 9 05:59:21 2007 -0500

    [libata] sata_vsc: support PCI MSI
   =20
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
