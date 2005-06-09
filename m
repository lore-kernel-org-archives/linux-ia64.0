From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 09 Jun 2005 19:29:10 +0000
Subject: [PATCH] Fix race condition in the rt_sigprocmask fastcall for IA64.
Message-Id: <Pine.LNX.4.62.0506091227350.22827@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

current->blocked will be set to the value of current->thread_info->flags if the
cmpxchg to update thread_info->flags fails. For performance reasons the store into
current->blocked was placed in the cmpxchg loop. However, the cmpxchg overwrites the
register holding the value to be stored. In the rare case of a retry the value of
thread_info->flags will be written into current->blocked.

The fix is to use another register so that the register containing the current->blocked
value is not overwritten.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/arch/ia64/kernel/fsys.S
=================================--- linux-2.6.11.orig/arch/ia64/kernel/fsys.S	2005-03-01 23:38:34.000000000 -0800
+++ linux-2.6.11/arch/ia64/kernel/fsys.S	2005-06-09 11:46:30.000000000 -0700
@@ -460,9 +460,9 @@ EX(.fail_efault, ld8 r14=[r33])			// r14
 	;;
 
 	st8 [r2]=r14				// update current->blocked with new mask
-	cmpxchg4.acq r14=[r9],r18,ar.ccv	// current->thread_info->flags <- r18
+	cmpxchg4.acq r8=[r9],r18,ar.ccv		// current->thread_info->flags <- r18
 	;;
-	cmp.ne p6,p0=r17,r14			// update failed?
+	cmp.ne p6,p0=r17,r8			// update failed?
 (p6)	br.cond.spnt.few 1b			// yes -> retry
 
 #ifdef CONFIG_SMP
