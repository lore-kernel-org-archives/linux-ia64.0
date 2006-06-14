From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 Jun 2006 23:30:36 +0000
Subject: RE: [Fastboot] Ia64 kdump patch
Message-Id: <617E1C2C70743745A92448908E030B2A174653@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> I'm very excited to be able to play with the new version of this patch,
> but the version you posted seems to included include all the kexec patch
> that went into Tony Luck's tree. Here is a rediff relative to the
> existing kexec patch (no other changes).

I applied this on top of the existing patch in my test tree.  The
first few kexec's went just fine, but when I tried to switch from
a kernel based on arch/ia64/configs/tiger_defconfig to a kernel
based on arch/ia64/defconfig, the system failed to boot (probably
because of problems with the mpt/fusion driver).  Last few messages
on the console were:

Fusion MPT base driver 3.03.09
Copyright (c) 1999-2005 LSI Logic Corporation
Fusion MPT SPI Host driver 3.03.09
GSI 28 (level, low) -> CPU 1 (0xc018) vector 49
ACPI: PCI Interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 49
mptbase: Initiating ioc0 bringup
mptbase: ioc0: ERROR - Doorbell ACK timeout (countI99), IntStatus=80000000!
mptbase: ioc0: ERROR - Doorbell ACK timeout (countI99), IntStatus=80000000!
mptbase: ioc0: ERROR - Diagnostic reset FAILED! (142h)
mptbase: ioc0 NOT READY WARNING!
mptbase: WARNING - ioc0 did not initialize properly! (-1)
mptspi: probe of 0000:06:02.0 failed with error -1
GSI 29 (level, low) -> CPU 2 (0xc218) vector 50
ACPI: PCI Interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 50
mptbase: Initiating ioc1 bringup

I reset the system, and the generic kernel booted just fine. kexec
from the generic kernel to the tiger_defconfig kernel also worked OK.

-Tony
