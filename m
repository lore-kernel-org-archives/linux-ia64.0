From: Sergei Trofimovich <slyich@gmail.com>
Date: Sat, 20 Aug 2022 18:18:13 +0000
Subject: [PATCH v2] ia64: fix clock_getres(CLOCK_MONOTONIC) to report ITC frequency
Message-Id: <20220820181813.2275195-1-slyich@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220820191751.26b125af@nz>
In-Reply-To: <20220820191751.26b125af@nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Sergei Trofimovich <slyich@gmail.com>, =?UTF-8?q?=C3=89meric=20Maschino?= <emeric.maschino@gmail.com>, linux-ia64@vger.kernel.org, matoro <matoro_mailinglist_kernel@matoro.tk>

clock_gettime(CLOCK_MONOTONIC, &tp) is very precise on ia64 as it uses
ITC (similar to rdtsc on x86). It's not quite a hrtimer as it is a few
times slower than 1ns. Usually 2-3ns.

clock_getres(CLOCK_MONOTONIC, &res) never reflected that fact and
reported 0.04s precision (1/HZ value).

In https://bugs.gentoo.org/596382 gstreamer's test suite failed loudly
when it noticed precision discrepancy.

Before the change:

    clock_getres(CLOCK_MONOTONIC, &res) reported 250Hz precision.

After the change:

    clock_getres(CLOCK_MONOTONIC, &res) reports ITC (400Mhz) precision.

The patch is based on matoro's fix. I added a bit of explanation why we
need to special-case arch-specific clock_getres().

CC: Émeric Maschino <emeric.maschino@gmail.com>
CC: linux-ia64@vger.kernel.org
CC: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: matoro <matoro_mailinglist_kernel@matoro.tk>
Signed-off-by: Sergei Trofimovich <slyich@gmail.com>
---
Change since v1:
- No code or in-code comment change
- CCed Émeric
- Added matoro's S-O-B the way matoro comfortable with
- Fixed Subject typo s/clock_getre/clock_getres/
 arch/ia64/kernel/sys_ia64.c           | 26 ++++++++++++++++++++++++++
 arch/ia64/kernel/syscalls/syscall.tbl |  2 +-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
index e14db25146c2..d5d47eb4608e 100644
--- a/arch/ia64/kernel/sys_ia64.c
+++ b/arch/ia64/kernel/sys_ia64.c
@@ -166,3 +166,29 @@ ia64_mremap (unsigned long addr, unsigned long old_len, unsigned long new_len, u
 		force_successful_syscall_return();
 	return addr;
 }
+
+asmlinkage long
+ia64_clock_getres(const clockid_t which_clock, struct __kernel_timespec __user *tp)
+{
+	/*
+	 * ia64's clock_gettime() syscall is implemented as a vdso call
+	 * fsys_clock_gettime(). Currently it handles only
+	 * CLOCK_REALTIME and CLOCK_MONOTONIC. Both are based on
+	 * 'ar.itc' counter which gets incremented at a constant
+	 * frequency. It's usually 400MHz, ~2.5x times slower than CPU
+	 * clock frequency. Which is almost a 1ns hrtimer, but not quite.
+	 *
+	 * Let's special-case these timers to report correct precision
+	 * based on ITC frequency and not HZ frequency for supported
+	 * clocks.
+	 */
+	switch (which_clock) {
+		case CLOCK_REALTIME:
+		case CLOCK_MONOTONIC:
+			s64 tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);
+			struct timespec64 rtn_tp = ns_to_timespec64(tick_ns);
+			return put_timespec64(&rtn_tp, tp);
+	}
+
+	return sys_clock_getres(which_clock, tp);
+}
diff --git a/arch/ia64/kernel/syscalls/syscall.tbl b/arch/ia64/kernel/syscalls/syscall.tbl
index 78b1d03e86e1..72c929d9902b 100644
--- a/arch/ia64/kernel/syscalls/syscall.tbl
+++ b/arch/ia64/kernel/syscalls/syscall.tbl
@@ -240,7 +240,7 @@
 228	common	timer_delete			sys_timer_delete
 229	common	clock_settime			sys_clock_settime
 230	common	clock_gettime			sys_clock_gettime
-231	common	clock_getres			sys_clock_getres
+231	common	clock_getres			ia64_clock_getres
 232	common	clock_nanosleep			sys_clock_nanosleep
 233	common	fstatfs64			sys_fstatfs64
 234	common	statfs64			sys_statfs64
-- 
2.37.1
