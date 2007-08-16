From: Shaohua Li <shaohua.li@intel.com>
Date: Thu, 16 Aug 2007 06:16:39 +0000
Subject: [PATCH]forbid ptrace changes psr.ri to 3
Message-Id: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

PSR.ri bits 3 are reserved, change to 3 will break kernel.

The patch ignore such change, if you thought access_urea should return
an error in the case, please let me know.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

--- a/arch/ia64/kernel/ptrace.c	2007-08-27 05:48:49.000000000 +0800
+++ b/arch/ia64/kernel/ptrace.c	2007-08-27 05:57:42.000000000 +0800
@@ -951,10 +951,14 @@ access_uarea (struct task_struct *child,
 			return 0;
 
 		      case PT_CR_IPSR:
-			if (write_access)
-				pt->cr_ipsr = ((*data & IPSR_MASK)
+			if (write_access) {
+				unsigned long tmp = *data;
+				/* psr.ri bits 11 are reserved, ingore the change */
+				if ((tmp & IA64_PSR_RI) = IA64_PSR_RI)
+					tmp &= ~IA64_PSR_RI;
+				pt->cr_ipsr = ((tmp & IPSR_MASK)
 					       | (pt->cr_ipsr & ~IPSR_MASK));
-			else
+			} else
 				*data = (pt->cr_ipsr & IPSR_MASK);
 			return 0;
 
