From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sun, 23 May 2010 20:01:47 +0000
Subject: [PATCH 151/199] arch/ia64/kernel/brl_emu.c: Checkpatch cleanup
Message-Id: <1274644930-26600-3-git-send-email-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/kernel/brl_emu.c:55: WARNING: space prohibited between function name and open parenthesis '('
arch/ia64/kernel/brl_emu.c:76: ERROR: trailing statements should be on next line
arch/ia64/kernel/brl_emu.c:79: ERROR: trailing statements should be on next line
arch/ia64/kernel/brl_emu.c:91: ERROR: switch and case should be at the same indent
arch/ia64/kernel/brl_emu.c:91: ERROR: space required before the open parenthesis '('
arch/ia64/kernel/brl_emu.c:97: ERROR: trailing statements should be on next line
arch/ia64/kernel/brl_emu.c:128: ERROR: switch and case should be at the same indent
arch/ia64/kernel/brl_emu.c:128: ERROR: space required before the open parenthesis '('

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/kernel/brl_emu.c |  168 ++++++++++++++++++++++----------------------
 1 files changed, 85 insertions(+), 83 deletions(-)

diff --git a/arch/ia64/kernel/brl_emu.c b/arch/ia64/kernel/brl_emu.c
index 0b286ca..6b4d227 100644
--- a/arch/ia64/kernel/brl_emu.c
+++ b/arch/ia64/kernel/brl_emu.c
@@ -52,7 +52,7 @@ struct illegal_op_return {
  */
 
 struct illegal_op_return
-ia64_emulate_brl (struct pt_regs *regs, unsigned long ar_ec)
+ia64_emulate_brl(struct pt_regs *regs, unsigned long ar_ec)
 {
 	unsigned long bundle[2];
 	unsigned long opcode, btype, qp, offset, cpl;
@@ -73,10 +73,12 @@ ia64_emulate_brl (struct pt_regs *regs, unsigned long ar_ec)
 	next_ip = (unsigned long) regs->cr_iip + 16;
 
 	/* "brl" must be in slot 2. */
-	if (ia64_psr(regs)->ri != 1) return rv;
+	if (ia64_psr(regs)->ri != 1)
+		return rv;
 
 	/* Must be "mlx" template */
-	if ((bundle[0] & 0x1e) != 0x4) return rv;
+	if ((bundle[0] & 0x1e) != 0x4)
+		return rv;
 
 	opcode = (bundle[1] >> 60);
 	btype = ((bundle[1] >> 29) & 0x7);
@@ -88,92 +90,92 @@ ia64_emulate_brl (struct pt_regs *regs, unsigned long ar_ec)
 
 	tmp_taken = regs->pr & (1L << qp);
 
-	switch(opcode) {
-
-		case 0xC:
+	switch (opcode) {
+	case 0xC:
+		/*
+		 *  Long Branch.
+		 */
+		if (btype != 0)
+			return rv;
+		rv.fkt = 0;
+		if (!(tmp_taken)) {
 			/*
-			 *  Long Branch.
+			 *  Qualifying predicate is 0.
+			 *  Skip instruction.
 			 */
-			if (btype != 0) return rv;
-			rv.fkt = 0;
-			if (!(tmp_taken)) {
-				/*
-				 *  Qualifying predicate is 0.
-				 *  Skip instruction.
-				 */
-				regs->cr_iip = next_ip;
-				ia64_psr(regs)->ri = 0;
-				return rv;
-			}
-			break;
+			regs->cr_iip = next_ip;
+			ia64_psr(regs)->ri = 0;
+			return rv;
+		}
+		break;
 
-		case 0xD:
+	case 0xD:
+		/*
+		 *  Long Call.
+		 */
+		rv.fkt = 0;
+		if (!(tmp_taken)) {
 			/*
-			 *  Long Call.
+			 *  Qualifying predicate is 0.
+			 *  Skip instruction.
 			 */
-			rv.fkt = 0;
-			if (!(tmp_taken)) {
-				/*
-				 *  Qualifying predicate is 0.
-				 *  Skip instruction.
-				 */
-				regs->cr_iip = next_ip;
-				ia64_psr(regs)->ri = 0;
-				return rv;
-			}
+			regs->cr_iip = next_ip;
+			ia64_psr(regs)->ri = 0;
+			return rv;
+		}
 
-			/*
-			 *  BR[btype] = IP+16
-			 */
-			switch(btype) {
-				case 0:
-					regs->b0 = next_ip;
-					break;
-				case 1:
-					rv.fkt = (unsigned long) &ia64_set_b1;
-					break;
-				case 2:
-					rv.fkt = (unsigned long) &ia64_set_b2;
-					break;
-				case 3:
-					rv.fkt = (unsigned long) &ia64_set_b3;
-					break;
-				case 4:
-					rv.fkt = (unsigned long) &ia64_set_b4;
-					break;
-				case 5:
-					rv.fkt = (unsigned long) &ia64_set_b5;
-					break;
-				case 6:
-					regs->b6 = next_ip;
-					break;
-				case 7:
-					regs->b7 = next_ip;
-					break;
-			}
+		/*
+		 *  BR[btype] = IP+16
+		 */
+		switch (btype) {
+		case 0:
+			regs->b0 = next_ip;
+			break;
+		case 1:
+			rv.fkt = (unsigned long) &ia64_set_b1;
+			break;
+		case 2:
+			rv.fkt = (unsigned long) &ia64_set_b2;
+			break;
+		case 3:
+			rv.fkt = (unsigned long) &ia64_set_b3;
+			break;
+		case 4:
+			rv.fkt = (unsigned long) &ia64_set_b4;
+			break;
+		case 5:
+			rv.fkt = (unsigned long) &ia64_set_b5;
+			break;
+		case 6:
+			regs->b6 = next_ip;
+			break;
+		case 7:
+			regs->b7 = next_ip;
+			break;
+		}
 			rv.arg1 = next_ip;
 
-			/*
-			 *  AR[PFS].pfm = CFM
-			 *  AR[PFS].pec = AR[EC]
-			 *  AR[PFS].ppl = PSR.cpl
-			 */
-			cpl = ia64_psr(regs)->cpl;
-			regs->ar_pfs = ((regs->cr_ifs & 0x3fffffffff)
-					| (ar_ec << 52) | (cpl << 62));
+		/*
+		 *  AR[PFS].pfm = CFM
+		 *  AR[PFS].pec = AR[EC]
+		 *  AR[PFS].ppl = PSR.cpl
+		 */
+		cpl = ia64_psr(regs)->cpl;
+		regs->ar_pfs = ((regs->cr_ifs & 0x3fffffffff)
+				| (ar_ec << 52) | (cpl << 62));
 
-			/*
-			 *  CFM.sof -= CFM.sol
-			 *  CFM.sol = 0
-			 *  CFM.sor = 0
-			 *  CFM.rrb.gr = 0
-			 *  CFM.rrb.fr = 0
-			 *  CFM.rrb.pr = 0
-			 */
-			regs->cr_ifs = ((regs->cr_ifs & 0xffffffc00000007f)
-					- ((regs->cr_ifs >> 7) & 0x7f));
+		/*
+		 *  CFM.sof -= CFM.sol
+		 *  CFM.sol = 0
+		 *  CFM.sor = 0
+		 *  CFM.rrb.gr = 0
+		 *  CFM.rrb.fr = 0
+		 *  CFM.rrb.pr = 0
+		 */
+		regs->cr_ifs = ((regs->cr_ifs & 0xffffffc00000007f)
+				- ((regs->cr_ifs >> 7) & 0x7f));
 
-			break;
+		break;
 
 		default:
 			/*
-- 
1.7.1.251.gf80a2

