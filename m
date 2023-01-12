From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 12 Jan 2023 19:44:03 +0000
Subject: [PATCH v3 49/51] cpuidle,arch: Mark all regular cpuidle_state::enter methods __cpuidle
Message-Id: <20230112195542.335211484@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230112194314.845371875@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org
Cc: richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, linux@armlinux.org.uk, nsekhar@ti.com, brgl@bgdev.pl, ulli.kroll@googlemail.com, linus.walleij@linaro.org, shawnguo@kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, kernel@pengutronix.de, festevam@gmail.com, linux-imx@nxp.com, tony@atomide.com, khilman@kernel.org, krzysztof.kozlowski@linaro.org, alim.akhtar@samsung.com, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, bcain@quicinc.com, chenhuacai@kernel.org, kernel@xen0n.name, geert@linux-m68k.org, sammy@sammy.net, monstr@monstr.eu, tsbogend@alpha.franken.de, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, richard@nod.at, anton.ivanov@cambridgegreys.com, johannes@sipsolutions.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, acme@kernel.org, mark.rutland@arm.com, alexander.shishkin@linux.intel.com, jolsa@kernel.org, namhyung@kernel.org, jgross@suse.com, srivatsa@csail.mit.edu, amakhalov@vmware.com, pv-drivers@vmware.com, boris.ostrovsky@oracle.com, chris@zankel.net, jcmvbkbc@gmail.com, rafael@kernel.org, lenb@kernel.org, pavel@ucw.cz, gregkh@linuxfoundation.org, mturquette@baylibre.com, sboyd@kernel.org, daniel.lezcano@linaro.org, lpieralisi@kernel.org, sudeep.holla@arm.com, agross@kernel.org, andersson@kernel.org, konrad.dybcio@linaro.org, anup@brainfault.org, thierry.reding@gmail.com, jonathanh@nvidia.com, jacob.jun.pan@linux.intel.com, atishp@atishpatra.org, Arnd Bergmann <arnd@arndb.de>, yury.norov@gmail.com, andriy.shevchenko@linux.intel.com, linux@rasmusvillemoes.dk, dennis@kernel.org, tj@kernel.org, cl@linux.com, rostedt@goodmis.org, mhiramat@kernel.org, frederic@kernel.org, paulmck@kernel.org, pmladek@suse.com, senozhatsky@chromium.org, john.ogness@linutronix.de, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, ryabinin.a.a@gmail.com, glider@google.com, andreyknvl@gmail.com, dvyukov@google.com, vincenzo.frascino@arm.com, Andrew Morton <akpm@linux-foundation.org>, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-omap@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-xtensa@linux-xtensa.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-clk@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-trace-kernel@vger.kernel.org, kasan-dev@googlegroups.com

For all cpuidle drivers that do not use CPUIDLE_FLAG_RCU_IDLE (iow,
the simple ones) make sure all the functions are marked __cpuidle.

( due to lack of noinstr validation on these platforms it is entirely
  possible this isn't complete )

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/arm/kernel/cpuidle.c           |    4 ++--
 arch/arm/mach-davinci/cpuidle.c     |    4 ++--
 arch/arm/mach-imx/cpuidle-imx5.c    |    4 ++--
 arch/arm/mach-imx/cpuidle-imx6sl.c  |    4 ++--
 arch/arm/mach-imx/cpuidle-imx7ulp.c |    4 ++--
 arch/arm/mach-s3c/cpuidle-s3c64xx.c |    5 ++---
 arch/mips/kernel/idle.c             |    6 +++---
 7 files changed, 15 insertions(+), 16 deletions(-)

--- a/arch/arm/kernel/cpuidle.c
+++ b/arch/arm/kernel/cpuidle.c
@@ -26,8 +26,8 @@ static struct cpuidle_ops cpuidle_ops[NR
  *
  * Returns the index passed as parameter
  */
-int arm_cpuidle_simple_enter(struct cpuidle_device *dev,
-		struct cpuidle_driver *drv, int index)
+__cpuidle int arm_cpuidle_simple_enter(struct cpuidle_device *dev, struct
+				       cpuidle_driver *drv, int index)
 {
 	cpu_do_idle();
 
--- a/arch/arm/mach-davinci/cpuidle.c
+++ b/arch/arm/mach-davinci/cpuidle.c
@@ -44,8 +44,8 @@ static void davinci_save_ddr_power(int e
 }
 
 /* Actual code that puts the SoC in different idle states */
-static int davinci_enter_idle(struct cpuidle_device *dev,
-			      struct cpuidle_driver *drv, int index)
+static __cpuidle int davinci_enter_idle(struct cpuidle_device *dev,
+					struct cpuidle_driver *drv, int index)
 {
 	davinci_save_ddr_power(1, ddr2_pdown);
 	cpu_do_idle();
--- a/arch/arm/mach-imx/cpuidle-imx5.c
+++ b/arch/arm/mach-imx/cpuidle-imx5.c
@@ -8,8 +8,8 @@
 #include <asm/system_misc.h>
 #include "cpuidle.h"
 
-static int imx5_cpuidle_enter(struct cpuidle_device *dev,
-			      struct cpuidle_driver *drv, int index)
+static __cpuidle int imx5_cpuidle_enter(struct cpuidle_device *dev,
+					struct cpuidle_driver *drv, int index)
 {
 	arm_pm_idle();
 	return index;
--- a/arch/arm/mach-imx/cpuidle-imx6sl.c
+++ b/arch/arm/mach-imx/cpuidle-imx6sl.c
@@ -11,8 +11,8 @@
 #include "common.h"
 #include "cpuidle.h"
 
-static int imx6sl_enter_wait(struct cpuidle_device *dev,
-			    struct cpuidle_driver *drv, int index)
+static __cpuidle int imx6sl_enter_wait(struct cpuidle_device *dev,
+				       struct cpuidle_driver *drv, int index)
 {
 	imx6_set_lpm(WAIT_UNCLOCKED);
 	/*
--- a/arch/arm/mach-imx/cpuidle-imx7ulp.c
+++ b/arch/arm/mach-imx/cpuidle-imx7ulp.c
@@ -12,8 +12,8 @@
 #include "common.h"
 #include "cpuidle.h"
 
-static int imx7ulp_enter_wait(struct cpuidle_device *dev,
-			    struct cpuidle_driver *drv, int index)
+static __cpuidle int imx7ulp_enter_wait(struct cpuidle_device *dev,
+					struct cpuidle_driver *drv, int index)
 {
 	if (index = 1)
 		imx7ulp_set_lpm(ULP_PM_WAIT);
--- a/arch/arm/mach-s3c/cpuidle-s3c64xx.c
+++ b/arch/arm/mach-s3c/cpuidle-s3c64xx.c
@@ -19,9 +19,8 @@
 #include "regs-sys-s3c64xx.h"
 #include "regs-syscon-power-s3c64xx.h"
 
-static int s3c64xx_enter_idle(struct cpuidle_device *dev,
-			      struct cpuidle_driver *drv,
-			      int index)
+static __cpuidle int s3c64xx_enter_idle(struct cpuidle_device *dev,
+					struct cpuidle_driver *drv, int index)
 {
 	unsigned long tmp;
 
--- a/arch/mips/kernel/idle.c
+++ b/arch/mips/kernel/idle.c
@@ -241,7 +241,7 @@ void __init check_wait(void)
 	}
 }
 
-void arch_cpu_idle(void)
+__cpuidle void arch_cpu_idle(void)
 {
 	if (cpu_wait)
 		cpu_wait();
@@ -249,8 +249,8 @@ void arch_cpu_idle(void)
 
 #ifdef CONFIG_CPU_IDLE
 
-int mips_cpuidle_wait_enter(struct cpuidle_device *dev,
-			    struct cpuidle_driver *drv, int index)
+__cpuidle int mips_cpuidle_wait_enter(struct cpuidle_device *dev,
+				      struct cpuidle_driver *drv, int index)
 {
 	arch_cpu_idle();
 	return index;

