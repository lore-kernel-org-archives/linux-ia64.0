From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 16 Sep 2005 17:43:10 +0000
Subject: [PATCH] ia64: add ar.k0 usage note
Message-Id: <200509161143.10842.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Update comment about how ar.k0 is used.  Make the initialization the
same as in start_secondary() (no functional change, just make it look
more similar).

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-vga2/arch/ia64/kernel/setup.c
=================================--- work-vga2.orig/arch/ia64/kernel/setup.c	2005-09-14 09:28:07.000000000 -0600
+++ work-vga2/arch/ia64/kernel/setup.c	2005-09-14 12:14:37.000000000 -0600
@@ -244,28 +244,31 @@
 static void __init
 io_port_init (void)
 {
-	extern unsigned long ia64_iobase;
 	unsigned long phys_iobase;
 
 	/*
-	 *  Set `iobase' to the appropriate address in region 6 (uncached access range).
+	 * Set `iobase' based on the EFI memory map or, failing that, the
+	 * value firmware left in ar.k0.
 	 *
-	 *  The EFI memory map is the "preferred" location to get the I/O port space base,
-	 *  rather the relying on AR.KR0. This should become more clear in future SAL
-	 *  specs. We'll fall back to getting it out of AR.KR0 if no appropriate entry is
-	 *  found in the memory map.
+	 * Note that in ia32 mode, IN/OUT instructions use ar.k0 to compute
+	 * the port's virtual address, so ia32_load_state() loads it with a
+	 * user virtual address.  But in ia64 mode, glibc uses the
+	 * *physical* address in ar.k0 to mmap the appropriate area from
+	 * /dev/mem, and the inX()/outX() interfaces use MMIO.  In both
+	 * cases, user-mode can only use the legacy 0-64K I/O port space.
+	 *
+	 * ar.k0 is not involved in kernel I/O port accesses, which can use
+	 * any of the I/O port spaces and are done via MMIO using the
+	 * virtual mmio_base from the appropriate io_space[].
 	 */
 	phys_iobase = efi_get_iobase();
-	if (phys_iobase)
-		/* set AR.KR0 since this is all we use it for anyway */
-		ia64_set_kr(IA64_KR_IO_BASE, phys_iobase);
-	else {
+	if (!phys_iobase) {
 		phys_iobase = ia64_get_kr(IA64_KR_IO_BASE);
-		printk(KERN_INFO "No I/O port range found in EFI memory map, falling back "
-		       "to AR.KR0\n");
-		printk(KERN_INFO "I/O port base = 0x%lx\n", phys_iobase);
+		printk(KERN_INFO "No I/O port range found in EFI memory map, "
+			"falling back to AR.KR0 (0x%lx)\n", phys_iobase);
 	}
 	ia64_iobase = (unsigned long) ioremap(phys_iobase, 0);
+	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
 
 	/* setup legacy IO port space */
 	io_space[0].mmio_base = ia64_iobase;
