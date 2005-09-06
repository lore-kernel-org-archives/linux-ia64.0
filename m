From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 06 Sep 2005 23:05:23 +0000
Subject: [patch] make exception handler in copy_user more robust
Message-Id: <200509062306.j86N64g19803@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The exception handler in copy user always expects fault occurs only on
user space address and the fall back recovery code is written with that
very assumption in mind.  Recent source code inspection revealed that
while it worked splendid and to the expectation under normal circumstances,
It broke down under unexpected condition where some address calculation
might go outside the legal address range the original copy_user was
called for.  This patch is to make copy_user exception handler more robust
and to prevent potential memory corruption.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- linux-2.6.13/arch/ia64/lib/memcpy_mck.S.orig	2005-09-06 15:15:29.560795174 -0700
+++ linux-2.6.13/arch/ia64/lib/memcpy_mck.S	2005-09-06 15:21:46.798095240 -0700
@@ -625,8 +625,11 @@ EK(.ex_handler,  (p17)	st8	[dst1]=r39,8)
 	clrrrb
 	;;
 	alloc	saved_pfs_stack=ar.pfs,3,3,3,0
+	cmp.lt	p8,p0=A,r0
 	sub	B = dst0, saved_in0	// how many byte copied so far
 	;;
+(p8)	mov	A = 0;			// A shouldn't be negative, cap it
+	;;
 	sub	C = A, B
 	sub	D = saved_in2, A
 	;;

