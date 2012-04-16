From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 16 Apr 2012 23:28:01 +0000
Subject: [PATCHv2] [IA64] Fix futex_atomic_cmpxchg_inatomic()
Message-Id: <4f8cab0131084f19b3@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Michel Lespinasse cleaned up the futex calling conventions in
commit 37a9d912b24f96a0591773e6e6c3642991ae5a70
    futex: Sanitize cmpxchg_futex_value_locked API

But the ia64 implementation was subtly broken. Gcc does not know
that register "r8" will be updated by the fault handler if the
cmpxchg instruction takes an exception. So it feels safe in letting
the initialization of r8 slide to after the cmpxchg. Result: we
always return 0 whether the user address faulted or not.

Fix by moving the initialization of r8 into the __asm__ code so
gcc won't move it.

Reported-by: <emeric.maschino@gmail.com>
Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?idB757
Tested-by: <emeric.maschino@gmail.com>
Acked-by: Michel Lespinasse <walken@google.com>
Cc: stable@vger.kernel.org # v2.6.39+
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
Make Linus happy by letting gcc know we touched r8 (which sounds like a
good idea ... since gcc has already shown that it gets in a snit if it
doesn't know what is going in inside the __asm__)

diff --git a/arch/ia64/include/asm/futex.h b/arch/ia64/include/asm/futex.h
index 8428525..21ab376 100644
--- a/arch/ia64/include/asm/futex.h
+++ b/arch/ia64/include/asm/futex.h
@@ -107,15 +107,16 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 		return -EFAULT;
 
 	{
-		register unsigned long r8 __asm ("r8") = 0;
+		register unsigned long r8 __asm ("r8");
 		unsigned long prev;
 		__asm__ __volatile__(
 			"	mf;;					\n"
-			"	mov ar.ccv=%3;;				\n"
-			"[1:]	cmpxchg4.acq %0=[%1],%2,ar.ccv		\n"
+			"	mov %0=r0				\n"
+			"	mov ar.ccv=%4;;				\n"
+			"[1:]	cmpxchg4.acq %1=[%2],%3,ar.ccv		\n"
 			"	.xdata4 \"__ex_table\", 1b-., 2f-.	\n"
 			"[2:]"
-			: "=r" (prev)
+			: "=r" (r8), "=r" (prev)
 			: "r" (uaddr), "r" (newval),
 			  "rO" ((long) (unsigned) oldval)
 			: "memory");
