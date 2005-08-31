From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Wed, 31 Aug 2005 20:28:25 +0000
Subject: RE: One-line patch for systems with ACPI enabled but incomplete tree
Message-Id: <516F50407E01324991DD6D07B0531AD56954F6@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <F7DC2337C7631D4386A2DF6E8FB22B30047B83DE@hdsmsx401.amr.corp.intel.com>
In-Reply-To: <F7DC2337C7631D4386A2DF6E8FB22B30047B83DE@hdsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Brown, Len" <len.brown@intel.com>
Cc: acpi-devel@lists.sourceforge.net, hch@infradead.org, linux-ia64@vger.kernel.org

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

I have been working on a patch that allows real kernels to
run on this simulator... that is the same bits that work
on real hardware will run on the simulator.  This will make
debugging ia64 kernels easier for some situations.  Real kernels
of course have ACPI on and this is the only remaining (non-ia64)
code that fails when running a real kernel on the simulator.

The same ACPI setup code used by this simulator is
currently used for Xen/ia64 so the same problem
occurs there.

> From: Moore, Robert [mailto:robert.moore@intel.com] 
> Subject: RE: [ACPI] RE: One-line patch for systems with ACPI 
> enabled but incomplete tree
> 
> I agree with Len's sentiments, assuming we are understanding 
> the problem
> correctly.
> 
> The ACPI CA subsystem operates under the assumption that at least the
> following absolute minimum table set is available:
> 
> RSDT/XSDT
> DSDT
> FADT
> FACS
> 
> It is quite simple for a simulator to provide these tables; see the
> AcpiExec "simulator" source code (provided with ACPI CA) for a good
> example of this.

If FADT is absolutely required for every ACPI tree, I see why
there is no check in the kernel code.  However, it still seems
like a bug to me as everything else works if the FADT pointer
is zero (with the above one line patch).

Thanks for the pointer... I will go find it and see if I can
leverage the code.

Dan
