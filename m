From: Keith Owens <kaos@sgi.com>
Date: Mon, 06 Jun 2005 09:04:28 +0000
Subject: [patch 2.6.12-rc5] Module gp must point to valid memory
Message-Id: <7136.1118048668@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some bits of the kernel assume that gp always points to valid memory,
in particular PHYSICAL_MODE_ENTER() assumes that both gp and sp are
valid virtual addresses with associated physical pages.  The IA64
module loader puts gp well past the end of the module, with no physical
backing.  Offsets on gp are still valid, but physical mode addressing
breaks for modules.  Ensure that gp always falls within the module
body.  Also ensure that gp is 8 byte aligned.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/module.c
=================================--- linux.orig/arch/ia64/kernel/module.c	2005-03-02 18:38:07.000000000 +1100
+++ linux/arch/ia64/kernel/module.c	2005-06-06 18:42:47.883261093 +1000
@@ -825,14 +825,16 @@ apply_relocate_add (Elf64_Shdr *sechdrs,
 		 * XXX Should have an arch-hook for running this after final section
 		 *     addresses have been selected...
 		 */
-		/* See if gp can cover the entire core module:  */
-		uint64_t gp = (uint64_t) mod->module_core + MAX_LTOFF / 2;
-		if (mod->core_size >= MAX_LTOFF)
+		uint64_t gp;
+		if (mod->core_size > MAX_LTOFF)
 			/*
 			 * This takes advantage of fact that SHF_ARCH_SMALL gets allocated
 			 * at the end of the module.
 			 */
-			gp = (uint64_t) mod->module_core + mod->core_size - MAX_LTOFF / 2;
+			gp = mod->core_size - MAX_LTOFF / 2;
+		else
+			gp = mod->core_size / 2;
+		gp = (uint64_t) mod->module_core + ((gp + 7) & -8);
 		mod->arch.gp = gp;
 		DEBUGP("%s: placing gp at 0x%lx\n", __FUNCTION__, gp);
 	}

