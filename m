From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 10 Sep 2003 21:34:57 +0000
Subject: [PATCH] protect PAL mapping printk with EFI_DEBUG
Message-Id: <marc-linux-ia64-106323064411277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Having this print out for every CPU on a large system was a pain, so
protect the printk with EFI_DEBUG.

Jesse


diff -Nru a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Wed Sep 10 14:26:40 2003
+++ b/arch/ia64/kernel/efi.c	Wed Sep 10 14:26:40 2003
@@ -446,10 +446,12 @@
 			panic("Woah!  PAL code size bigger than a granule!");
 
 		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
+#if EFI_DEBUG
 		printk(KERN_INFO "CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
 		       smp_processor_id(), md->phys_addr,
 		       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
 		       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
+#endif
 
 		/*
 		 * Cannot write to CRx with PSR.ic=1
