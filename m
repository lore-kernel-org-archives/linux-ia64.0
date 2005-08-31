From: "Brown, Len" <len.brown@intel.com>
Date: Wed, 31 Aug 2005 19:49:50 +0000
Subject: RE: One-line patch for systems with ACPI enabled but incomplete tree
Message-Id: <F7DC2337C7631D4386A2DF6E8FB22B30047B83DE@hdsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Cc: acpi-devel@lists.sourceforge.net, hch@infradead.org, linux-ia64@vger.kernel.org

>
>The attached patch allows systems for which ACPI is enabled,
>but a full tree is not present, to avoid a horrible kernel crash.
>Systems with this characteristic include the ia64 HP simulator
>(with ACPI enabled) and some future virtualized environments
>(e.g. Xen, specifically Xen/ia64).
>
>If no objections, please apply.  If discussion ensues, please
>cc me as I am not a subscriber to this list.
>
>Thanks,
>Dan Magenheimer
>HP Labs
>
>--- 1.6/drivers/acpi/motherboard.c	Wed Nov 10 15:57:35 2004
>+++ 1.7/drivers/acpi/motherboard.c	Fri Apr 22 16:47:41 2005
>@@ -120,6 +120,7 @@
> static void __init
> acpi_reserve_resources (void)
> {
>+	if (!acpi_gbl_FADT) return;

Is this the same simulator that runs arch/ia64/configs/sim_defconfig,
but for your kernel ACPI is now enabled?
Why is ACPI now enabled in the simulation?
Why can't the simulator provide an FADT?

Modifying (everybodies) Linux to work-around simulator bugs
doesn't sound like a good idea for a number of reasons.

thanks,
-Len
