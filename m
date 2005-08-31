From: "Moore, Robert" <robert.moore@intel.com>
Date: Wed, 31 Aug 2005 20:07:20 +0000
Subject: RE: [ACPI] RE: One-line patch for systems with ACPI enabled but incomplete tree
Message-Id: <971FCB6690CD0E4898387DBF7552B90E02961E28@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Brown, Len" <len.brown@intel.com>, "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Cc: acpi-devel@lists.sourceforge.net, hch@infradead.org, linux-ia64@vger.kernel.org

I agree with Len's sentiments, assuming we are understanding the problem
correctly.

The ACPI CA subsystem operates under the assumption that at least the
following absolute minimum table set is available:

RSDT/XSDT
DSDT
FADT
FACS

It is quite simple for a simulator to provide these tables; see the
AcpiExec "simulator" source code (provided with ACPI CA) for a good
example of this.

Bob Moore


> -----Original Message-----
> From: acpi-devel-admin@lists.sourceforge.net [mailto:acpi-devel-
> admin@lists.sourceforge.net] On Behalf Of Brown, Len
> Sent: Wednesday, August 31, 2005 12:50 PM
> To: Magenheimer, Dan (HP Labs Fort Collins)
> Cc: acpi-devel@lists.sourceforge.net; hch@infradead.org; linux-
> ia64@vger.kernel.org
> Subject: [ACPI] RE: One-line patch for systems with ACPI enabled but
> incomplete tree
> 
> >
> >The attached patch allows systems for which ACPI is enabled,
> >but a full tree is not present, to avoid a horrible kernel crash.
> >Systems with this characteristic include the ia64 HP simulator
> >(with ACPI enabled) and some future virtualized environments
> >(e.g. Xen, specifically Xen/ia64).
> >
> >If no objections, please apply.  If discussion ensues, please
> >cc me as I am not a subscriber to this list.
> >
> >Thanks,
> >Dan Magenheimer
> >HP Labs
> >
> >--- 1.6/drivers/acpi/motherboard.c	Wed Nov 10 15:57:35 2004
> >+++ 1.7/drivers/acpi/motherboard.c	Fri Apr 22 16:47:41 2005
> >@@ -120,6 +120,7 @@
> > static void __init
> > acpi_reserve_resources (void)
> > {
> >+	if (!acpi_gbl_FADT) return;
> 
> Is this the same simulator that runs arch/ia64/configs/sim_defconfig,
> but for your kernel ACPI is now enabled?
> Why is ACPI now enabled in the simulation?
> Why can't the simulator provide an FADT?
> 
> Modifying (everybodies) Linux to work-around simulator bugs
> doesn't sound like a good idea for a number of reasons.
> 
> thanks,
> -Len
> 
> 
> -------------------------------------------------------
> SF.Net email is Sponsored by the Better Software Conference & EXPO
> September 19-22, 2005 * San Francisco, CA * Development Lifecycle
> Practices
> Agile & Plan-Driven Development * Managing Projects & Teams * Testing
& QA
> Security * Process Improvement & Measurement *
http://www.sqe.com/bsce5sf
> _______________________________________________
> Acpi-devel mailing list
> Acpi-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/acpi-devel
