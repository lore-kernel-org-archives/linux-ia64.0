From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 24 Jan 2020 09:23:23 +0000
Subject: [PATCH 4.19 033/639] signal/ia64: Use the force_sig(SIGSEGV,...) in ia64_rt_sigreturn
Message-Id: <20200124093051.581418128@linuxfoundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200124093047.008739095@linuxfoundation.org>
In-Reply-To: <20200124093047.008739095@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, Sasha Levin <sashal@kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

[ Upstream commit b92adb74adde62d9a9780ff2977d63dcb21aeaa6 ]

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
Acked-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/ia64/kernel/signal.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index 01fc133b2e4c8..9a960829a01d9 100644
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
2.20.1


