From: "Yu, Luming" <luming.yu@intel.com>
Date: Mon, 08 Mar 2004 02:08:05 +0000
Subject: RE: IA64 test report: .6.4-rc1-mm2/Lion 2004-3-3: 10/10 pass
Message-Id: <3ACA40606221794F80A5670F0AF15F8401CBB72E@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401720DBF@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401720DBF@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>=20
> Is this the same box as the 2.6.4-rc1 test?  I guess not -- the
> "Lion 2.6.4-rc1" test claims this:
>=20
> > ACPI: XSDT (v001 INTEL  SR870BN4 0x01072002 MSFT=20
> 0x00010013) @ 0x000000003ff83090
>=20
> Which looks like an 870-based box (Tiger, maybe)?

I'm sorry for the typo of title. This is for tiger.

>=20
> > ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0x01]=20
> lsapic_eid[0x00] enabled)
> > CPU 1 (0x0100) enabled
> > CPU 1: base freq=133.333MHz, ITC ratio=12/2, ITC=20
> freq=800.003MHz+/--1ppm
> > Calibrating delay loop... 797.80 BogoMIPS
> > CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles,=20
> maxerr 551 cycles)
>=20
> Hmm...  We still print 5 lines per CPU (tons better than it used to
> be), but we have no indication of what processor model it is.  That
> seems more useful than some of this stuff.

Yes.

>=20
> >  pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive=20
> IRQ for device 0000:00:03.3
> > ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3
>=20
> Ah, here's our friend the SMBus device.
>=20
> No USB funnies in this boot.  I guess that's probably due to
> the fact that this really isn't the same box as the 2.6.4-rc1
> boot.
>=20
>=20

Yes, this is for tiger.

Thanks,
Luming
