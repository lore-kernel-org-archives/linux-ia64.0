From: Jiri Slaby <jslaby@suse.cz>
Date: Mon, 15 May 2017 13:07:42 +0000
Subject: [PATCH 1/1] futex: remove duplicated code
Message-Id: <20170515130742.18357-1-jslaby@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tglx@linutronix.de
Cc: linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

There is code duplicated over all architecture's headers for
futex_atomic_op_inuser. Namely op decoding, access_ok check for uaddr,
and comparison of the result.

Remove this duplication and leave up to the arches only the needed
assembly which is now in arch_futex_atomic_op_inuser.

Note that s390 removed access_ok check in d12a29703 ("s390/uaccess:
remove pointless access_ok() checks") as access_ok there returns true.
We introduce it back to the helper for the sake of simplicity (it gets
optimized away anyway).

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Acked-by: Russell King <rmk+kernel@armlinux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Richard Kuo <rkuo@codeaurora.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>
Cc: Stafford Horne <shorne@gmail.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> [s390]
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: "David S. Miller" <davem@davemloft.net>
Acked-by: Chris Metcalf <cmetcalf@mellanox.com> [for tile]
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Chris Zankel <chris@zankel.net>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: <x86@kernel.org>
Cc: <linux-alpha@vger.kernel.org>
Cc: <linux-kernel@vger.kernel.org>
Cc: <linux-snps-arc@lists.infradead.org>
Cc: <linux-arm-kernel@lists.infradead.org>
Cc: <linux-hexagon@vger.kernel.org>
Cc: <linux-ia64@vger.kernel.org>
Cc: <linux-mips@linux-mips.org>
Cc: <openrisc@lists.librecores.org>
Cc: <linux-parisc@vger.kernel.org>
Cc: <linuxppc-dev@lists.ozlabs.org>
Cc: <linux-s390@vger.kernel.org>
Cc: <linux-sh@vger.kernel.org>
Cc: <sparclinux@vger.kernel.org>
Cc: <linux-xtensa@linux-xtensa.org>
Cc: <linux-arch@vger.kernel.org>
---
 arch/alpha/include/asm/futex.h      | 26 ++++---------------
 arch/arc/include/asm/futex.h        | 40 ++++-------------------------
 arch/arm/include/asm/futex.h        | 26 +++----------------
 arch/arm64/include/asm/futex.h      | 26 +++----------------
 arch/frv/include/asm/futex.h        |  3 ++-
 arch/frv/kernel/futex.c             | 27 +++-----------------
 arch/hexagon/include/asm/futex.h    | 38 +++-------------------------
 arch/ia64/include/asm/futex.h       | 25 +++----------------
 arch/microblaze/include/asm/futex.h | 38 +++-------------------------
 arch/mips/include/asm/futex.h       | 25 +++----------------
 arch/openrisc/include/asm/futex.h   | 39 +++--------------------------
 arch/parisc/include/asm/futex.h     | 26 +++----------------
 arch/powerpc/include/asm/futex.h    | 26 ++++---------------
 arch/s390/include/asm/futex.h       | 23 ++++-------------
 arch/sh/include/asm/futex.h         | 26 +++----------------
 arch/sparc/include/asm/futex_64.h   | 26 ++++---------------
 arch/tile/include/asm/futex.h       | 40 ++++-------------------------
 arch/x86/include/asm/futex.h        | 40 ++++-------------------------
 arch/xtensa/include/asm/futex.h     | 27 ++++----------------
 include/asm-generic/futex.h         | 50 +++++++------------------------------
 kernel/futex.c                      | 36 ++++++++++++++++++++++++++
 21 files changed, 127 insertions(+), 506 deletions(-)

diff --git a/arch/alpha/include/asm/futex.h b/arch/alpha/include/asm/futex.h
index fb01dfb760c2..05a70edd57b6 100644
--- a/arch/alpha/include/asm/futex.h
+++ b/arch/alpha/include/asm/futex.h
@@ -25,18 +25,10 @@
 	:	"r" (uaddr), "r"(oparg)				\
 	:	"memory")
 
-static inline int futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, int oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
 
 	pagefault_disable();
 
@@ -62,17 +54,9 @@ static inline int futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/arc/include/asm/futex.h b/arch/arc/include/asm/futex.h
index 11e1b1f3acda..eb887dd13e74 100644
--- a/arch/arc/include/asm/futex.h
+++ b/arch/arc/include/asm/futex.h
@@ -73,20 +73,11 @@
 
 #endif
 
-static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, int oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(int)))
-		return -EFAULT;
-
 #ifndef CONFIG_ARC_HAS_LLSC
 	preempt_disable();	/* to guarantee atomic r-m-w of futex op */
 #endif
@@ -118,30 +109,9 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	preempt_enable();
 #endif
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ:
-			ret = (oldval = cmparg);
-			break;
-		case FUTEX_OP_CMP_NE:
-			ret = (oldval != cmparg);
-			break;
-		case FUTEX_OP_CMP_LT:
-			ret = (oldval < cmparg);
-			break;
-		case FUTEX_OP_CMP_GE:
-			ret = (oldval >= cmparg);
-			break;
-		case FUTEX_OP_CMP_LE:
-			ret = (oldval <= cmparg);
-			break;
-		case FUTEX_OP_CMP_GT:
-			ret = (oldval > cmparg);
-			break;
-		default:
-			ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/arm/include/asm/futex.h b/arch/arm/include/asm/futex.h
index 6795368ad023..cc414382dab4 100644
--- a/arch/arm/include/asm/futex.h
+++ b/arch/arm/include/asm/futex.h
@@ -128,20 +128,10 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 #endif /* !SMP */
 
 static inline int
-futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret, tmp;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
-
 #ifndef CONFIG_SMP
 	preempt_disable();
 #endif
@@ -172,17 +162,9 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 	preempt_enable();
 #endif
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/arm64/include/asm/futex.h b/arch/arm64/include/asm/futex.h
index 85c4a8981d47..5bb2fd4674e7 100644
--- a/arch/arm64/include/asm/futex.h
+++ b/arch/arm64/include/asm/futex.h
@@ -48,20 +48,10 @@ do {									\
 } while (0)
 
 static inline int
-futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret, tmp;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
-
 	pagefault_disable();
 
 	switch (op) {
@@ -91,17 +81,9 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/frv/include/asm/futex.h b/arch/frv/include/asm/futex.h
index 2e1da71e27a4..ab346f5f8820 100644
--- a/arch/frv/include/asm/futex.h
+++ b/arch/frv/include/asm/futex.h
@@ -7,7 +7,8 @@
 #include <asm/errno.h>
 #include <linux/uaccess.h>
 
-extern int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr);
+extern int arch_futex_atomic_op_inuser(int op, int oparg, int *oval,
+		u32 __user *uaddr);
 
 static inline int
 futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
diff --git a/arch/frv/kernel/futex.c b/arch/frv/kernel/futex.c
index d155ca9e5098..37f7b2bf7f73 100644
--- a/arch/frv/kernel/futex.c
+++ b/arch/frv/kernel/futex.c
@@ -186,20 +186,10 @@ static inline int atomic_futex_op_xchg_xor(int oparg, u32 __user *uaddr, int *_o
 /*
  * do the futex operations
  */
-int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+int arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
-
 	pagefault_disable();
 
 	switch (op) {
@@ -225,18 +215,9 @@ int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS; break;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
 
 	return ret;
 
-} /* end futex_atomic_op_inuser() */
+} /* end arch_futex_atomic_op_inuser() */
diff --git a/arch/hexagon/include/asm/futex.h b/arch/hexagon/include/asm/futex.h
index 7e597f8434da..c607b77c8215 100644
--- a/arch/hexagon/include/asm/futex.h
+++ b/arch/hexagon/include/asm/futex.h
@@ -31,18 +31,9 @@
 
 
 static inline int
-futex_atomic_op_inuser(int encoded_op, int __user *uaddr)
+arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(int)))
-		return -EFAULT;
 
 	pagefault_disable();
 
@@ -72,30 +63,9 @@ futex_atomic_op_inuser(int encoded_op, int __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ:
-			ret = (oldval = cmparg);
-			break;
-		case FUTEX_OP_CMP_NE:
-			ret = (oldval != cmparg);
-			break;
-		case FUTEX_OP_CMP_LT:
-			ret = (oldval < cmparg);
-			break;
-		case FUTEX_OP_CMP_GE:
-			ret = (oldval >= cmparg);
-			break;
-		case FUTEX_OP_CMP_LE:
-			ret = (oldval <= cmparg);
-			break;
-		case FUTEX_OP_CMP_GT:
-			ret = (oldval > cmparg);
-			break;
-		default:
-			ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/ia64/include/asm/futex.h b/arch/ia64/include/asm/futex.h
index 76acbcd5c060..6d67dc1eaf2b 100644
--- a/arch/ia64/include/asm/futex.h
+++ b/arch/ia64/include/asm/futex.h
@@ -45,18 +45,9 @@ do {									\
 } while (0)
 
 static inline int
-futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (! access_ok (VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
 
 	pagefault_disable();
 
@@ -84,17 +75,9 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/microblaze/include/asm/futex.h b/arch/microblaze/include/asm/futex.h
index 01848f056f43..a9dad9e5e132 100644
--- a/arch/microblaze/include/asm/futex.h
+++ b/arch/microblaze/include/asm/futex.h
@@ -29,18 +29,9 @@
 })
 
 static inline int
-futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
 
 	pagefault_disable();
 
@@ -66,30 +57,9 @@ futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ:
-			ret = (oldval = cmparg);
-			break;
-		case FUTEX_OP_CMP_NE:
-			ret = (oldval != cmparg);
-			break;
-		case FUTEX_OP_CMP_LT:
-			ret = (oldval < cmparg);
-			break;
-		case FUTEX_OP_CMP_GE:
-			ret = (oldval >= cmparg);
-			break;
-		case FUTEX_OP_CMP_LE:
-			ret = (oldval <= cmparg);
-			break;
-		case FUTEX_OP_CMP_GT:
-			ret = (oldval > cmparg);
-			break;
-		default:
-			ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/mips/include/asm/futex.h b/arch/mips/include/asm/futex.h
index 1de190bdfb9c..a9e61ea54ca9 100644
--- a/arch/mips/include/asm/futex.h
+++ b/arch/mips/include/asm/futex.h
@@ -83,18 +83,9 @@
 }
 
 static inline int
-futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (! access_ok (VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
 
 	pagefault_disable();
 
@@ -125,17 +116,9 @@ futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/openrisc/include/asm/futex.h b/arch/openrisc/include/asm/futex.h
index 778087341977..8fed278a24b8 100644
--- a/arch/openrisc/include/asm/futex.h
+++ b/arch/openrisc/include/asm/futex.h
@@ -30,20 +30,10 @@
 })
 
 static inline int
-futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
-
 	pagefault_disable();
 
 	switch (op) {
@@ -68,30 +58,9 @@ futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ:
-			ret = (oldval = cmparg);
-			break;
-		case FUTEX_OP_CMP_NE:
-			ret = (oldval != cmparg);
-			break;
-		case FUTEX_OP_CMP_LT:
-			ret = (oldval < cmparg);
-			break;
-		case FUTEX_OP_CMP_GE:
-			ret = (oldval >= cmparg);
-			break;
-		case FUTEX_OP_CMP_LE:
-			ret = (oldval <= cmparg);
-			break;
-		case FUTEX_OP_CMP_GT:
-			ret = (oldval > cmparg);
-			break;
-		default:
-			ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/parisc/include/asm/futex.h b/arch/parisc/include/asm/futex.h
index 0ba14300cd8e..c601aab2fb36 100644
--- a/arch/parisc/include/asm/futex.h
+++ b/arch/parisc/include/asm/futex.h
@@ -32,22 +32,12 @@ _futex_spin_unlock_irqrestore(u32 __user *uaddr, unsigned long int *flags)
 }
 
 static inline int
-futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, int oparg, int *oval, u32 __user *uaddr)
 {
 	unsigned long int flags;
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval, ret;
 	u32 tmp;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(*uaddr)))
-		return -EFAULT;
-
 	_futex_spin_lock_irqsave(uaddr, &flags);
 	pagefault_disable();
 
@@ -85,17 +75,9 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 	pagefault_enable();
 	_futex_spin_unlock_irqrestore(uaddr, &flags);
 
-	if (ret = 0) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/powerpc/include/asm/futex.h b/arch/powerpc/include/asm/futex.h
index eaada6c92344..719ed9b61ea7 100644
--- a/arch/powerpc/include/asm/futex.h
+++ b/arch/powerpc/include/asm/futex.h
@@ -29,18 +29,10 @@
 	: "b" (uaddr), "i" (-EFAULT), "r" (oparg) \
 	: "cr0", "memory")
 
-static inline int futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, int oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (! access_ok (VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
 
 	pagefault_disable();
 
@@ -66,17 +58,9 @@ static inline int futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/s390/include/asm/futex.h b/arch/s390/include/asm/futex.h
index a4811aa0304d..8f8eec9e1198 100644
--- a/arch/s390/include/asm/futex.h
+++ b/arch/s390/include/asm/futex.h
@@ -21,17 +21,12 @@
 		: "0" (-EFAULT), "d" (oparg), "a" (uaddr),		\
 		  "m" (*uaddr) : "cc");
 
-static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, int oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, newval, ret;
 
 	load_kernel_asce();
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
 
 	pagefault_disable();
 	switch (op) {
@@ -60,17 +55,9 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	}
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/sh/include/asm/futex.h b/arch/sh/include/asm/futex.h
index d0078747d308..8f8cf941a8cd 100644
--- a/arch/sh/include/asm/futex.h
+++ b/arch/sh/include/asm/futex.h
@@ -27,21 +27,12 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 	return atomic_futex_op_cmpxchg_inatomic(uval, uaddr, oldval, newval);
 }
 
-static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, u32 oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	u32 oparg = (encoded_op << 8) >> 20;
-	u32 cmparg = (encoded_op << 20) >> 20;
 	u32 oldval, newval, prev;
 	int ret;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
-
 	pagefault_disable();
 
 	do {
@@ -80,17 +71,8 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = ((int)oldval < (int)cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = ((int)oldval >= (int)cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = ((int)oldval <= (int)cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = ((int)oldval > (int)cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
 
 	return ret;
 }
diff --git a/arch/sparc/include/asm/futex_64.h b/arch/sparc/include/asm/futex_64.h
index 4e899b0dabf7..1cfd89d92208 100644
--- a/arch/sparc/include/asm/futex_64.h
+++ b/arch/sparc/include/asm/futex_64.h
@@ -29,22 +29,14 @@
 	: "r" (uaddr), "r" (oparg), "i" (-EFAULT)	\
 	: "memory")
 
-static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, int oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret, tem;
 
-	if (unlikely(!access_ok(VERIFY_WRITE, uaddr, sizeof(u32))))
-		return -EFAULT;
 	if (unlikely((((unsigned long) uaddr) & 0x3UL)))
 		return -EINVAL;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
 	pagefault_disable();
 
 	switch (op) {
@@ -69,17 +61,9 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/tile/include/asm/futex.h b/arch/tile/include/asm/futex.h
index e64a1b75fc38..83c1e639b411 100644
--- a/arch/tile/include/asm/futex.h
+++ b/arch/tile/include/asm/futex.h
@@ -106,12 +106,9 @@
 	lock = __atomic_hashed_lock((int __force *)uaddr)
 #endif
 
-static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, u32 oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int uninitialized_var(val), ret;
 
 	__futex_prolog();
@@ -119,12 +116,6 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	/* The 32-bit futex code makes this assumption, so validate it here. */
 	BUILD_BUG_ON(sizeof(atomic_t) != sizeof(int));
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
-
 	pagefault_disable();
 	switch (op) {
 	case FUTEX_OP_SET:
@@ -148,30 +139,9 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	}
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ:
-			ret = (val = cmparg);
-			break;
-		case FUTEX_OP_CMP_NE:
-			ret = (val != cmparg);
-			break;
-		case FUTEX_OP_CMP_LT:
-			ret = (val < cmparg);
-			break;
-		case FUTEX_OP_CMP_GE:
-			ret = (val >= cmparg);
-			break;
-		case FUTEX_OP_CMP_LE:
-			ret = (val <= cmparg);
-			break;
-		case FUTEX_OP_CMP_GT:
-			ret = (val > cmparg);
-			break;
-		default:
-			ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = val;
+
 	return ret;
 }
 
diff --git a/arch/x86/include/asm/futex.h b/arch/x86/include/asm/futex.h
index b4c1f5453436..f4dc9b63bdda 100644
--- a/arch/x86/include/asm/futex.h
+++ b/arch/x86/include/asm/futex.h
@@ -41,20 +41,11 @@
 		       "+m" (*uaddr), "=&r" (tem)		\
 		     : "r" (oparg), "i" (-EFAULT), "1" (0))
 
-static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, int oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret, tem;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
-
 	pagefault_disable();
 
 	switch (op) {
@@ -80,30 +71,9 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ:
-			ret = (oldval = cmparg);
-			break;
-		case FUTEX_OP_CMP_NE:
-			ret = (oldval != cmparg);
-			break;
-		case FUTEX_OP_CMP_LT:
-			ret = (oldval < cmparg);
-			break;
-		case FUTEX_OP_CMP_GE:
-			ret = (oldval >= cmparg);
-			break;
-		case FUTEX_OP_CMP_LE:
-			ret = (oldval <= cmparg);
-			break;
-		case FUTEX_OP_CMP_GT:
-			ret = (oldval > cmparg);
-			break;
-		default:
-			ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/arch/xtensa/include/asm/futex.h b/arch/xtensa/include/asm/futex.h
index b39531babec0..eaaf1ebcc7a4 100644
--- a/arch/xtensa/include/asm/futex.h
+++ b/arch/xtensa/include/asm/futex.h
@@ -44,18 +44,10 @@
 	: "r" (uaddr), "I" (-EFAULT), "r" (oparg)	\
 	: "memory")
 
-static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+static inline int arch_futex_atomic_op_inuser(int op, int oparg, int *oval,
+		u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
 
 #if !XCHAL_HAVE_S32C1I
 	return -ENOSYS;
@@ -89,19 +81,10 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (ret)
-		return ret;
+	if (!ret)
+		*oval = oldval;
 
-	switch (cmp) {
-	case FUTEX_OP_CMP_EQ: return (oldval = cmparg);
-	case FUTEX_OP_CMP_NE: return (oldval != cmparg);
-	case FUTEX_OP_CMP_LT: return (oldval < cmparg);
-	case FUTEX_OP_CMP_GE: return (oldval >= cmparg);
-	case FUTEX_OP_CMP_LE: return (oldval <= cmparg);
-	case FUTEX_OP_CMP_GT: return (oldval > cmparg);
-	}
-
-	return -ENOSYS;
+	return ret;
 }
 
 static inline int
diff --git a/include/asm-generic/futex.h b/include/asm-generic/futex.h
index bf2d34c9d804..f0d8b1c51343 100644
--- a/include/asm-generic/futex.h
+++ b/include/asm-generic/futex.h
@@ -13,7 +13,7 @@
  */
 
 /**
- * futex_atomic_op_inuser() - Atomic arithmetic operation with constant
+ * arch_futex_atomic_op_inuser() - Atomic arithmetic operation with constant
  *			  argument and comparison of the previous
  *			  futex value with another constant.
  *
@@ -25,18 +25,11 @@
  * <0 - On error
  */
 static inline int
-futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, u32 oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval, ret;
 	u32 tmp;
 
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
 	preempt_disable();
 	pagefault_disable();
 
@@ -74,17 +67,9 @@ futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	pagefault_enable();
 	preempt_enable();
 
-	if (ret = 0) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (ret = 0)
+		*oval = oldval;
+
 	return ret;
 }
 
@@ -126,18 +111,9 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 
 #else
 static inline int
-futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
+arch_futex_atomic_op_inuser(int op, u32 oparg, int *oval, u32 __user *uaddr)
 {
-	int op = (encoded_op >> 28) & 7;
-	int cmp = (encoded_op >> 24) & 15;
-	int oparg = (encoded_op << 8) >> 20;
-	int cmparg = (encoded_op << 20) >> 20;
 	int oldval = 0, ret;
-	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
-		oparg = 1 << oparg;
-
-	if (! access_ok (VERIFY_WRITE, uaddr, sizeof(u32)))
-		return -EFAULT;
 
 	pagefault_disable();
 
@@ -153,17 +129,9 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 
 	pagefault_enable();
 
-	if (!ret) {
-		switch (cmp) {
-		case FUTEX_OP_CMP_EQ: ret = (oldval = cmparg); break;
-		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
-		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
-		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
-		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
-		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
-		default: ret = -ENOSYS;
-		}
-	}
+	if (!ret)
+		*oval = oldval;
+
 	return ret;
 }
 
diff --git a/kernel/futex.c b/kernel/futex.c
index 357348a6cf6b..28dc71b05250 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -1546,6 +1546,42 @@ futex_wake(u32 __user *uaddr, unsigned int flags, int nr_wake, u32 bitset)
 	return ret;
 }
 
+static int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
+{
+	int op = (encoded_op >> 28) & 7;
+	int cmp = (encoded_op >> 24) & 15;
+	int oparg = (encoded_op << 8) >> 20;
+	int cmparg = (encoded_op << 20) >> 20;
+	int oldval, ret;
+
+	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
+		oparg = 1 << oparg;
+
+	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
+		return -EFAULT;
+
+	ret = arch_futex_atomic_op_inuser(op, oparg, &oldval, uaddr);
+	if (ret)
+		return ret;
+
+	switch (cmp) {
+	case FUTEX_OP_CMP_EQ:
+		return oldval = cmparg;
+	case FUTEX_OP_CMP_NE:
+		return oldval != cmparg;
+	case FUTEX_OP_CMP_LT:
+		return oldval < cmparg;
+	case FUTEX_OP_CMP_GE:
+		return oldval >= cmparg;
+	case FUTEX_OP_CMP_LE:
+		return oldval <= cmparg;
+	case FUTEX_OP_CMP_GT:
+		return oldval > cmparg;
+	default:
+		return -ENOSYS;
+	}
+}
+
 /*
  * Wake up all waiters hashed on the physical page that is mapped
  * to this virtual address:
-- 
2.13.0

