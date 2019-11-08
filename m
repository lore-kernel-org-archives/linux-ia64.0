From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 08 Nov 2019 21:07:24 +0000
Subject: [PATCH 04/23] y2038: vdso: change timespec to __kernel_old_timespec
Message-Id: <20191108210824.1534248-4-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191108210236.1296047-1-arnd@arndb.de>
In-Reply-To: <20191108210236.1296047-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: y2038@lists.linaro.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org

In order to remove 'timespec' completely from the kernel, all
internal uses should be converted to a y2038-safe type, while
those that are only for compatibity with existing user space
should be marked appropriately.

Change vdso to use __kernel_old_timespec in order to avoid
the deprecated type and mark these interfaces as outdated.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/kernel/asm-offsets.c        |  2 +-
 arch/nds32/kernel/vdso/gettimeofday.c | 22 +++++++++++-----------
 arch/sparc/vdso/vclock_gettime.c      | 24 ++++++++++++------------
 arch/x86/um/vdso/um_vdso.c            |  4 ++--
 4 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 00e8e2a1eb19..fb0deb8a4221 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -211,7 +211,7 @@ void foo(void)
 	       offsetof (struct cpuinfo_ia64, ptce_stride));
 	BLANK();
 	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET,
-	       offsetof (struct timespec, tv_nsec));
+	       offsetof (struct __kernel_old_timespec, tv_nsec));
 	DEFINE(IA64_TIME_SN_SPEC_SNSEC_OFFSET,
 	       offsetof (struct time_sn_spec, snsec));
 
diff --git a/arch/nds32/kernel/vdso/gettimeofday.c b/arch/nds32/kernel/vdso/gettimeofday.c
index 1e69fd5b067b..687abc7145f5 100644
--- a/arch/nds32/kernel/vdso/gettimeofday.c
+++ b/arch/nds32/kernel/vdso/gettimeofday.c
@@ -48,9 +48,9 @@ static notrace int vdso_read_retry(const struct vdso_data *vdata, u32 start)
 }
 
 static notrace long clock_gettime_fallback(clockid_t _clkid,
-					   struct timespec *_ts)
+					   struct __kernel_old_timespec *_ts)
 {
-	register struct timespec *ts asm("$r1") = _ts;
+	register struct __kernel_old_timespec *ts asm("$r1") = _ts;
 	register clockid_t clkid asm("$r0") = _clkid;
 	register long ret asm("$r0");
 
@@ -63,7 +63,7 @@ static notrace long clock_gettime_fallback(clockid_t _clkid,
 	return ret;
 }
 
-static notrace int do_realtime_coarse(struct timespec *ts,
+static notrace int do_realtime_coarse(struct __kernel_old_timespec *ts,
 				      struct vdso_data *vdata)
 {
 	u32 seq;
@@ -78,7 +78,7 @@ static notrace int do_realtime_coarse(struct timespec *ts,
 	return 0;
 }
 
-static notrace int do_monotonic_coarse(struct timespec *ts,
+static notrace int do_monotonic_coarse(struct __kernel_old_timespec *ts,
 				       struct vdso_data *vdata)
 {
 	struct timespec tomono;
@@ -115,7 +115,7 @@ static notrace inline u64 vgetsns(struct vdso_data *vdso)
 	return ((u64) cycle_delta & vdso->cs_mask) * vdso->cs_mult;
 }
 
-static notrace int do_realtime(struct timespec *ts, struct vdso_data *vdata)
+static notrace int do_realtime(struct __kernel_old_timespec *ts, struct vdso_data *vdata)
 {
 	unsigned count;
 	u64 ns;
@@ -133,7 +133,7 @@ static notrace int do_realtime(struct timespec *ts, struct vdso_data *vdata)
 	return 0;
 }
 
-static notrace int do_monotonic(struct timespec *ts, struct vdso_data *vdata)
+static notrace int do_monotonic(struct __kernel_old_timespec *ts, struct vdso_data *vdata)
 {
 	struct timespec tomono;
 	u64 nsecs;
@@ -158,7 +158,7 @@ static notrace int do_monotonic(struct timespec *ts, struct vdso_data *vdata)
 	return 0;
 }
 
-notrace int __vdso_clock_gettime(clockid_t clkid, struct timespec *ts)
+notrace int __vdso_clock_gettime(clockid_t clkid, struct __kernel_old_timespec *ts)
 {
 	struct vdso_data *vdata;
 	int ret = -1;
@@ -191,10 +191,10 @@ notrace int __vdso_clock_gettime(clockid_t clkid, struct timespec *ts)
 }
 
 static notrace int clock_getres_fallback(clockid_t _clk_id,
-					  struct timespec *_res)
+					  struct __kernel_old_timespec *_res)
 {
 	register clockid_t clk_id asm("$r0") = _clk_id;
-	register struct timespec *res asm("$r1") = _res;
+	register struct __kernel_old_timespec *res asm("$r1") = _res;
 	register int ret asm("$r0");
 
 	asm volatile ("movi	$r15, %3\n"
@@ -206,7 +206,7 @@ static notrace int clock_getres_fallback(clockid_t _clk_id,
 	return ret;
 }
 
-notrace int __vdso_clock_getres(clockid_t clk_id, struct timespec *res)
+notrace int __vdso_clock_getres(clockid_t clk_id, struct __kernel_old_timespec *res)
 {
 	struct vdso_data *vdata = __get_datapage();
 
@@ -248,7 +248,7 @@ static notrace inline int gettimeofday_fallback(struct __kernel_old_timeval *_tv
 
 notrace int __vdso_gettimeofday(struct __kernel_old_timeval *tv, struct timezone *tz)
 {
-	struct timespec ts;
+	struct __kernel_old_timespec ts;
 	struct vdso_data *vdata;
 	int ret;
 
diff --git a/arch/sparc/vdso/vclock_gettime.c b/arch/sparc/vdso/vclock_gettime.c
index a20c5030578d..e794edde6755 100644
--- a/arch/sparc/vdso/vclock_gettime.c
+++ b/arch/sparc/vdso/vclock_gettime.c
@@ -63,7 +63,7 @@ notrace static __always_inline struct vvar_data *get_vvar_data(void)
 	return (struct vvar_data *) ret;
 }
 
-notrace static long vdso_fallback_gettime(long clock, struct timespec *ts)
+notrace static long vdso_fallback_gettime(long clock, struct __kernel_old_timespec *ts)
 {
 	register long num __asm__("g1") = __NR_clock_gettime;
 	register long o0 __asm__("o0") = clock;
@@ -144,7 +144,7 @@ notrace static __always_inline u64 vgetsns_stick(struct vvar_data *vvar)
 }
 
 notrace static __always_inline int do_realtime(struct vvar_data *vvar,
-					       struct timespec *ts)
+					       struct __kernel_old_timespec *ts)
 {
 	unsigned long seq;
 	u64 ns;
@@ -164,7 +164,7 @@ notrace static __always_inline int do_realtime(struct vvar_data *vvar,
 }
 
 notrace static __always_inline int do_realtime_stick(struct vvar_data *vvar,
-						     struct timespec *ts)
+						     struct __kernel_old_timespec *ts)
 {
 	unsigned long seq;
 	u64 ns;
@@ -184,7 +184,7 @@ notrace static __always_inline int do_realtime_stick(struct vvar_data *vvar,
 }
 
 notrace static __always_inline int do_monotonic(struct vvar_data *vvar,
-						struct timespec *ts)
+						struct __kernel_old_timespec *ts)
 {
 	unsigned long seq;
 	u64 ns;
@@ -204,7 +204,7 @@ notrace static __always_inline int do_monotonic(struct vvar_data *vvar,
 }
 
 notrace static __always_inline int do_monotonic_stick(struct vvar_data *vvar,
-						      struct timespec *ts)
+						      struct __kernel_old_timespec *ts)
 {
 	unsigned long seq;
 	u64 ns;
@@ -224,7 +224,7 @@ notrace static __always_inline int do_monotonic_stick(struct vvar_data *vvar,
 }
 
 notrace static int do_realtime_coarse(struct vvar_data *vvar,
-				      struct timespec *ts)
+				      struct __kernel_old_timespec *ts)
 {
 	unsigned long seq;
 
@@ -237,7 +237,7 @@ notrace static int do_realtime_coarse(struct vvar_data *vvar,
 }
 
 notrace static int do_monotonic_coarse(struct vvar_data *vvar,
-				       struct timespec *ts)
+				       struct __kernel_old_timespec *ts)
 {
 	unsigned long seq;
 
@@ -251,7 +251,7 @@ notrace static int do_monotonic_coarse(struct vvar_data *vvar,
 }
 
 notrace int
-__vdso_clock_gettime(clockid_t clock, struct timespec *ts)
+__vdso_clock_gettime(clockid_t clock, struct __kernel_old_timespec *ts)
 {
 	struct vvar_data *vvd = get_vvar_data();
 
@@ -275,11 +275,11 @@ __vdso_clock_gettime(clockid_t clock, struct timespec *ts)
 	return vdso_fallback_gettime(clock, ts);
 }
 int
-clock_gettime(clockid_t, struct timespec *)
+clock_gettime(clockid_t, struct __kernel_old_timespec *)
 	__attribute__((weak, alias("__vdso_clock_gettime")));
 
 notrace int
-__vdso_clock_gettime_stick(clockid_t clock, struct timespec *ts)
+__vdso_clock_gettime_stick(clockid_t clock, struct __kernel_old_timespec *ts)
 {
 	struct vvar_data *vvd = get_vvar_data();
 
@@ -311,7 +311,7 @@ __vdso_gettimeofday(struct __kernel_old_timeval *tv, struct timezone *tz)
 	if (likely(vvd->vclock_mode != VCLOCK_NONE)) {
 		if (likely(tv != NULL)) {
 			union tstv_t {
-				struct timespec ts;
+				struct __kernel_old_timespec ts;
 				struct __kernel_old_timeval tv;
 			} *tstv = (union tstv_t *) tv;
 			do_realtime(vvd, &tstv->ts);
@@ -347,7 +347,7 @@ __vdso_gettimeofday_stick(struct __kernel_old_timeval *tv, struct timezone *tz)
 	if (likely(vvd->vclock_mode != VCLOCK_NONE)) {
 		if (likely(tv != NULL)) {
 			union tstv_t {
-				struct timespec ts;
+				struct __kernel_old_timespec ts;
 				struct __kernel_old_timeval tv;
 			} *tstv = (union tstv_t *) tv;
 			do_realtime_stick(vvd, &tstv->ts);
diff --git a/arch/x86/um/vdso/um_vdso.c b/arch/x86/um/vdso/um_vdso.c
index 845336c11364..371724cf70da 100644
--- a/arch/x86/um/vdso/um_vdso.c
+++ b/arch/x86/um/vdso/um_vdso.c
@@ -13,7 +13,7 @@
 #include <linux/getcpu.h>
 #include <asm/unistd.h>
 
-int __vdso_clock_gettime(clockid_t clock, struct timespec *ts)
+int __vdso_clock_gettime(clockid_t clock, struct __kernel_old_timespec *ts)
 {
 	long ret;
 
@@ -22,7 +22,7 @@ int __vdso_clock_gettime(clockid_t clock, struct timespec *ts)
 
 	return ret;
 }
-int clock_gettime(clockid_t, struct timespec *)
+int clock_gettime(clockid_t, struct __kernel_old_timespec *)
 	__attribute__((weak, alias("__vdso_clock_gettime")));
 
 int __vdso_gettimeofday(struct __kernel_old_timeval *tv, struct timezone *tz)
-- 
2.20.0
