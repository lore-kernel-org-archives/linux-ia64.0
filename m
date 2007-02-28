From: John Keller <jpk@sgi.com>
Date: Wed, 28 Feb 2007 19:45:17 +0000
Subject: [PATCH 1/1] - platform_kernel_launch_event is noop on generic kernel
Message-Id: <20070228194517.25635.98535.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fastboot@lists.osdl.org
Cc: jlan@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

Add a missing #define for the platform_kernel_launch_event.
Without this fix, a call to platform_kernel_launch_event()
becomes a noop on generic kernels. SN systems require this
fix to successfully kdump/kexec from certain hardware errors.

Signed-off-by: John Keller <jpk@sgi.com>
---

Index: linux-2.6/include/asm-ia64/machvec.h
=================================--- linux-2.6.orig/include/asm-ia64/machvec.h	2007-02-28 08:39:45.764537727 -0600
+++ linux-2.6/include/asm-ia64/machvec.h	2007-02-28 08:40:01.254467899 -0600
@@ -168,6 +168,7 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_setup_msi_irq	ia64_mv.setup_msi_irq
 #  define platform_teardown_msi_irq	ia64_mv.teardown_msi_irq
 #  define platform_pci_fixup_bus	ia64_mv.pci_fixup_bus
+#  define platform_kernel_launch_event	ia64_mv.kernel_launch_event
 # endif
 
 /* __attribute__((__aligned__(16))) is required to make size of the
