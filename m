From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Oct 2003 23:27:25 +0000
Subject: [PATCH 2.6.0test5: 2 of 3] MCA/TLB recovery
Message-Id: <marc-linux-ia64-106522368223247@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This part is just a clean-up of the logging code to only
print registers that are implemented (instead of blindly
dumping CR[0] ... CR[127] and AR[0] ... AR[127].

-Tony

diff -ru linux-2.6.0-test5/arch/ia64/kernel/mca.c temp/arch/ia64/kernel/mca.c
--- linux-2.6.0-test5/arch/ia64/kernel/mca.c	2003-09-08 12:50:03.000000000 -0700
+++ temp/arch/ia64/kernel/mca.c	2003-10-03 15:37:40.095070954 -0700
@@ -1498,6 +1498,12 @@
 			lh->timestamp.slh_second, lh->severity);
 }
 
+/* Bitmasks of implemented registers */
+static u64 arbits[2] = { 0x11117f2f00ffUL, 0x7UL };
+static u64 brbits[1] = { 0xffUL };
+static u64 crbits[2] = { 0x3fb0107UL, 0x307ffUL };
+static u64 rrbits[1] = { 0xffUL };
+
 /*
  * ia64_log_processor_regs_print
  *	Print the contents of the saved processor register(s) in the format
@@ -1513,6 +1519,7 @@
 void
 ia64_log_processor_regs_print(u64	*regs,
 			      int	reg_num,
+			      u64	*reg_bits,
 			      char	*reg_class,
 			      char	*reg_prefix,
 			      prfunc_t	prfunc)
@@ -1521,7 +1528,8 @@
 
 	prfunc("+%s Registers\n", reg_class);
 	for (i = 0; i < reg_num; i++)
-		prfunc("+ %s[%d] 0x%lx\n", reg_prefix, i, regs[i]);
+		if (reg_bits[i/64] & (1UL << (i%64)))
+			prfunc("+ %s[%d] 0x%lx\n", reg_prefix, i, regs[i]);
 }
 
 /*
@@ -2159,22 +2167,22 @@
 
 		/* Print branch register contents if valid */
 		if (spsi->valid.br)
-			ia64_log_processor_regs_print(spsi->br, 8, "Branch", "br",
+			ia64_log_processor_regs_print(spsi->br, 8, brbits, "Branch", "br",
 						      prfunc);
 
 		/* Print control register contents if valid */
 		if (spsi->valid.cr)
-			ia64_log_processor_regs_print(spsi->cr, 128, "Control", "cr",
+			ia64_log_processor_regs_print(spsi->cr, 128, crbits, "Control", "cr",
 						      prfunc);
 
 		/* Print application register contents if valid */
 		if (spsi->valid.ar)
-			ia64_log_processor_regs_print(spsi->ar, 128, "Application",
+			ia64_log_processor_regs_print(spsi->ar, 128, arbits, "Application",
 						      "ar", prfunc);
 
 		/* Print region register contents if valid */
 		if (spsi->valid.rr)
-			ia64_log_processor_regs_print(spsi->rr, 8, "Region", "rr",
+			ia64_log_processor_regs_print(spsi->rr, 8, rrbits, "Region", "rr",
 						      prfunc);
 
 		/* Print floating-point register contents if valid */

