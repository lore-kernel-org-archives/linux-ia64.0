From: Ard Biesheuvel <ardb@kernel.org>
Date: Wed, 15 Feb 2023 10:00:05 +0000
Subject: [RFC PATCH 2/5] kernel: Drop IA64 support from sig_fault handlers
Message-Id: <20230215100008.2565237-3-ardb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
In-Reply-To: <20230215100008.2565237-1-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ard Biesheuvel <ardb@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

Signed-off-by: Ard Biesheuvel <ardb@kernel.org>
---
 include/linux/sched/signal.h | 17 ++++---------
 kernel/signal.c              | 25 ++++----------------
 2 files changed, 9 insertions(+), 33 deletions(-)

diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
index 20099268fa257f40..6aecfbf823656f6c 100644
--- a/include/linux/sched/signal.h
+++ b/include/linux/sched/signal.h
@@ -303,20 +303,11 @@ static inline void kernel_signal_stop(void)
 
 	schedule();
 }
-#ifdef __ia64__
-# define ___ARCH_SI_IA64(_a1, _a2, _a3) , _a1, _a2, _a3
-#else
-# define ___ARCH_SI_IA64(_a1, _a2, _a3)
-#endif
 
-int force_sig_fault_to_task(int sig, int code, void __user *addr
-	___ARCH_SI_IA64(int imm, unsigned int flags, unsigned long isr)
-	, struct task_struct *t);
-int force_sig_fault(int sig, int code, void __user *addr
-	___ARCH_SI_IA64(int imm, unsigned int flags, unsigned long isr));
-int send_sig_fault(int sig, int code, void __user *addr
-	___ARCH_SI_IA64(int imm, unsigned int flags, unsigned long isr)
-	, struct task_struct *t);
+int force_sig_fault_to_task(int sig, int code, void __user *addr,
+			    struct task_struct *t);
+int force_sig_fault(int sig, int code, void __user *addr);
+int send_sig_fault(int sig, int code, void __user *addr, struct task_struct *t);
 
 int force_sig_mceerr(int code, void __user *, short);
 int send_sig_mceerr(int code, void __user *, short, struct task_struct *);
diff --git a/kernel/signal.c b/kernel/signal.c
index ae26da61c4d9fa6a..5b7f0bf2713901da 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1701,9 +1701,8 @@ void force_sigsegv(int sig)
 		force_sig(SIGSEGV);
 }
 
-int force_sig_fault_to_task(int sig, int code, void __user *addr
-	___ARCH_SI_IA64(int imm, unsigned int flags, unsigned long isr)
-	, struct task_struct *t)
+int force_sig_fault_to_task(int sig, int code, void __user *addr,
+			    struct task_struct *t)
 {
 	struct kernel_siginfo info;
 
@@ -1712,24 +1711,15 @@ int force_sig_fault_to_task(int sig, int code, void __user *addr
 	info.si_errno = 0;
 	info.si_code  = code;
 	info.si_addr  = addr;
-#ifdef __ia64__
-	info.si_imm = imm;
-	info.si_flags = flags;
-	info.si_isr = isr;
-#endif
 	return force_sig_info_to_task(&info, t, HANDLER_CURRENT);
 }
 
-int force_sig_fault(int sig, int code, void __user *addr
-	___ARCH_SI_IA64(int imm, unsigned int flags, unsigned long isr))
+int force_sig_fault(int sig, int code, void __user *addr)
 {
-	return force_sig_fault_to_task(sig, code, addr
-				       ___ARCH_SI_IA64(imm, flags, isr), current);
+	return force_sig_fault_to_task(sig, code, addr, current);
 }
 
-int send_sig_fault(int sig, int code, void __user *addr
-	___ARCH_SI_IA64(int imm, unsigned int flags, unsigned long isr)
-	, struct task_struct *t)
+int send_sig_fault(int sig, int code, void __user *addr, struct task_struct *t)
 {
 	struct kernel_siginfo info;
 
@@ -1738,11 +1728,6 @@ int send_sig_fault(int sig, int code, void __user *addr
 	info.si_errno = 0;
 	info.si_code  = code;
 	info.si_addr  = addr;
-#ifdef __ia64__
-	info.si_imm = imm;
-	info.si_flags = flags;
-	info.si_isr = isr;
-#endif
 	return send_sig_info(info.si_signo, &info, t);
 }
 
-- 
2.39.1
