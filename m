From: Keith Owens <kaos@sgi.com>
Date: Tue, 24 Jan 2006 01:31:26 +0000
Subject: [patch 2.6.16-rc1] Set the correct default OS status in the MCA handler
Message-Id: <6999.1138066286@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sos->os_status is set to a default value of IA64_MCA_COLD_BOOT for an
MCA, but then is incorrectly overwritten with IA64_MCA_SAME_CONTEXT (0).
This makes SAL think that all MCAs have been recovered.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2006-01-19 10:27:30.921806584 +1100
+++ linux/arch/ia64/kernel/mca_asm.S	2006-01-24 12:13:35.878617761 +1100
@@ -512,7 +512,7 @@ ia64_state_save:
 	st8 [temp1]=r12		// os_status, default is cold boot
 	mov r6=IA64_MCA_SAME_CONTEXT
 	;;
-	st8 [temp1]=r6		// context, default is same context
+	st8 [temp2]=r6		// context, default is same context
 
 	// Save the pt_regs data that is not in minstate.  The previous code
 	// left regs at sos.

