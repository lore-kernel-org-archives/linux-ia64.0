From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon, 24 Sep 2018 14:21:42 +0000
Subject: [REVIEW][PATCH 2/3] signal/ia64: Use the force_sig(SIGSEGV,...) in ia64_rt_sigreturn
Message-Id: <20180924142143.21356-2-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87pnx32j2p.fsf@xmission.com>
In-Reply-To: <87pnx32j2p.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, "Eric W. Biederman" <ebiederm@xmission.com>

The ia64 handling of failure to return from a signal frame has been trying
to set overlapping fields in struct siginfo since 2.3.43.  The si_code
corresponds to the fields that were stomped (not the field that is
actually written), so I can not imagine a piece of userspace code
making sense of the signal frame if it looks closely.

In practice failure to return from a signal frame is a rare event that
almost never happens.  Someone using an alternate signal stack to
recover and looking in detail is even more rare.  So I presume no one
has ever noticed and reported this ia64 nonsense.

Sort this out by causing ia64 to use force_sig(SIGSEGV) like other architectures.

Fixes: 2.3.43
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 arch/ia64/kernel/signal.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index 01fc133b2e4c..9a960829a01d 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -110,7 +110,6 @@ ia64_rt_sigreturn (struct sigscratch *scr)
 {
 	extern char ia64_strace_leave_kernel, ia64_leave_kernel;
 	struct sigcontext __user *sc;
-	struct siginfo si;
 	sigset_t set;
 	long retval;
 
@@ -153,14 +152,7 @@ ia64_rt_sigreturn (struct sigscratch *scr)
 	return retval;
 
   give_sigsegv:
-	clear_siginfo(&si);
-	si.si_signo = SIGSEGV;
-	si.si_errno = 0;
-	si.si_code = SI_KERNEL;
-	si.si_pid = task_pid_vnr(current);
-	si.si_uid = from_kuid_munged(current_user_ns(), current_uid());
-	si.si_addr = sc;
-	force_sig_info(SIGSEGV, &si, current);
+	force_sig(SIGSEGV, current);
 	return retval;
 }
 
-- 
2.17.1
