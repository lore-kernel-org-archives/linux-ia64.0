From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 03 Mar 2004 16:34:59 +0000
Subject: Re: IA64 test report: .6.4-rc1-mm2/Lion 2004-3-3: 10/10 pass
Message-Id: <200403030934.59343.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401720DBF@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401720DBF@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Is this the same box as the 2.6.4-rc1 test?  I guess not -- the
"Lion 2.6.4-rc1" test claims this:

> ACPI: XSDT (v001 INTEL  SR870BN4 0x01072002 MSFT 0x00010013) @ 0x00000000=
3ff83090

Which looks like an 870-based box (Tiger, maybe)?

This one ("Lion 2.6.4-mm2") looks 460-based:

> ACPI: XSDT (v001  INTEL  SR460AC 0x00000003 MSFT 0x0100000a) @ 0x00000000=
5fe96658
> 4 CPUs available, 8 CPUs total

So 4 of the 8 CPUs are disabled.  Is that what you expect?

> ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0x01] lsapic_eid[0x00] enabled)
> CPU 1 (0x0100) enabled
> CPU 1: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.003MHz+/--1ppm
> Calibrating delay loop... 797.80 BogoMIPS
> CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 551 cycles)

Hmm...  We still print 5 lines per CPU (tons better than it used to
be), but we have no indication of what processor model it is.  That
seems more useful than some of this stuff.

>  pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive IRQ for devic=
e 0000:00:03.3
> ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3

Ah, here's our friend the SMBus device.

No USB funnies in this boot.  I guess that's probably due to
the fact that this really isn't the same box as the 2.6.4-rc1
boot.

