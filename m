From: Bernhard Walle <bwalle@suse.de>
Date: Thu, 01 Mar 2007 13:03:36 +0000
Subject: Re: [Fastboot] [PATCH 1/1] - platform_kernel_launch_event is noop on generic kernel
Message-Id: <20070301130336.GB18853@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070228194517.25635.98535.sendpatchset@attica.americas.sgi.com> <20070301042227.GO6479@verge.net.au> <20070301125736.GA18853@strauss.suse.de>
In-Reply-To: <20070301125736.GA18853@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

* Bernhard Walle <bwalle@suse.de> [2007-03-01 13:57]:
> * Horms <horms@verge.net.au> [2007-03-01 05:22]:
> > On Wed, Feb 28, 2007 at 01:45:17PM -0600, John Keller wrote:
> > > Add a missing #define for the platform_kernel_launch_event.
> > > Without this fix, a call to platform_kernel_launch_event()
> > > becomes a noop on generic kernels. SN systems require this
> > > fix to successfully kdump/kexec from certain hardware errors.
> > >
> > > Signed-off-by: John Keller <jpk@sgi.com>
> > 
> > I made a similar change when porting to xen, but I hadn't thought
> > to see if mainline linux needs it to.
> > 
> > Acked-by: Simon Horman <horms@verge.net.au>
> 
> I think there's an additional change needed. Without that, it leads to
> a NULL pointer dereference.

Maybe I should also get my editor right ... ;):

---
 include/asm-ia64/machvec.h |    2 ++
 1 file changed, 2 insertions(+)

Index: b/include/asm-ia64/machvec.h
=================================--- a/include/asm-ia64/machvec.h
+++ b/include/asm-ia64/machvec.h
@@ -168,6 +168,7 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_setup_msi_irq	ia64_mv.setup_msi_irq
 #  define platform_teardown_msi_irq	ia64_mv.teardown_msi_irq
 #  define platform_pci_fixup_bus	ia64_mv.pci_fixup_bus
+#  define platform_kernel_launch_event	ia64_mv.kernel_launch_event
 # endif
 
 /* __attribute__((__aligned__(16))) is required to make size of the
@@ -269,6 +270,7 @@ struct ia64_machine_vector {
 	platform_setup_msi_irq,			\
 	platform_teardown_msi_irq,		\
 	platform_pci_fixup_bus,			\
+	platform_kernel_launch_event            \
 }
 
 extern struct ia64_machine_vector ia64_mv;
