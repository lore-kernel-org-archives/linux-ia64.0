From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 19 Sep 2022 10:00:14 +0000
Subject: [PATCH v2 35/44] cpuidle,omap3: Push RCU-idle into omap_sram_idle()
Message-Id: <20220919101522.707997632@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919095939.761690562@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org
Cc: juri.lelli@redhat.com, rafael@kernel.org, catalin.marinas@arm.com, linus.walleij@linaro.org, bsegall@google.com, guoren@kernel.org, pavel@ucw.cz, agordeev@linux.ibm.com, linux-arch@vger.kernel.org, vincent.guittot@linaro.org, mpe@ellerman.id.au, chenhuacai@kernel.org, christophe.leroy@csgroup.eu, linux-acpi@vger.kernel.org, agross@kernel.org, geert@linux-m68k.org, linux-imx@nxp.com, vgupta@kernel.org, mattst88@gmail.com, mturquette@baylibre.com, sammy@sammy.net, pmladek@suse.com, linux-pm@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, linux-um@lists.infradead.org, npiggin@gmail.com, tglx@linutronix.de, linux-omap@vger.kernel.org, dietmar.eggemann@arm.com, andreyknvl@gmail.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-perf-users@vger.kernel.org, senozhatsky@chromium.org, svens@linux.ibm.com, jolsa@kernel.org, tj@kernel.org, Andrew Morton <akpm@linux-foundation.org>, mark.rutland@arm.com, linux-ia64@vger.kernel.org, dave.hansen@linux.intel.com, virtualization@lists.linux-foundation.org, James.Bottomley@HansenPartnership.com, jcmvbkbc@gmail.com, thierry.reding@gmail.com, kernel@xen0n.name, cl@linux.com, linux-s390@vger.kernel.org, vschneid@redhat.com, john.ogness@linutronix.de, ysato@users.sourceforge.jp, linux-sh@vger.kernel.org, festevam@gmail.com, deller@gmx.de, daniel.lezcano@linaro.org, jonathanh@nvidia.com, dennis@kernel.org, lenb@kernel.org, linux-xtensa@linux-xtensa.org, kernel@pengutronix.de, gor@linux.ibm.com, linux-arm-msm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, shorne@gmail.com, chris@zankel.net, sboyd@kernel.org, dinguyen@kernel.org, bristot@redhat.com, alexander.shishkin@linux.intel.com, fweisbec@gmail.com, lpieralisi@kernel.org, atishp@atishpatra.org, linux@rasmusvillemoes.dk, kasan-dev@googlegroups.com, will@kernel.org, boris.ostrovsky@oracle.com, khilman@kernel.org, linux-csky@vger.kernel.org, pv-drivers@vmware.com, linux-snps-arc@lists.infradead.org, mgorman@suse.de, jacob.jun.pan@linux.intel.com, Arnd Bergmann <arnd@arndb.de>, ulli.kroll@googlemail.com, linux-clk@vger.kernel.org, rostedt@goodmis.org, ink@jurassic.park.msu.ru, bcain@quicinc.com, tsbogend@alpha.franken.de, linux-parisc@vger.kernel.org, ryabinin.a.a@gmail.com, sudeep.holla@arm.com, shawnguo@kernel.org, davem@davemloft.net, dalias@libc.org, tony@atomide.com, amakhalov@vmware.com, konrad.dybcio@somainline.org, bjorn.andersson@linaro.org, glider@google.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-riscv@lists.infradead.org, vincenzo.frascino@arm.com, anton.ivanov@cambridgegreys.com, jonas@southpole.se, yury.norov@gmail.com, richard@nod.at, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, richard.henderson@linaro.org, stefan.kristiansson@saunalahti.fi, openrisc@lists.librecores.org, acme@kernel.org, paul.walmsley@sifive.com, linux-tegra@vger.kernel.org, namhyung@kernel.org, andriy.shevchenko@linux.intel.com, jpoimboe@kernel.org, dvyukov@google.com, jgross@suse.com, monstr@monstr.eu, linux-mips@vger.kernel.org, palmer@dabbelt.com, anup@brainfault.org, bp@alien8.de, johannes@sipsolutions.net, linuxppc-dev@lists.ozlabs.org

OMAP3 uses full SoC suspend modes as idle states, as such it needs the
whole power-domain and clock-domain code from the idle path.

All that code is not suitable to run with RCU disabled, as such push
RCU-idle deeper still.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Tony Lindgren <tony@atomide.com>
Tested-by: Tony Lindgren <tony@atomide.com>
---
 arch/arm/mach-omap2/cpuidle34xx.c |    4 +---
 arch/arm/mach-omap2/pm.h          |    2 +-
 arch/arm/mach-omap2/pm34xx.c      |   12 ++++++++++--
 3 files changed, 12 insertions(+), 6 deletions(-)

--- a/arch/arm/mach-omap2/cpuidle34xx.c
+++ b/arch/arm/mach-omap2/cpuidle34xx.c
@@ -133,9 +133,7 @@ static int omap3_enter_idle(struct cpuid
 	}
 
 	/* Execute ARM wfi */
-	ct_cpuidle_enter();
-	omap_sram_idle();
-	ct_cpuidle_exit();
+	omap_sram_idle(true);
 
 	/*
 	 * Call idle CPU PM enter notifier chain to restore
--- a/arch/arm/mach-omap2/pm.h
+++ b/arch/arm/mach-omap2/pm.h
@@ -29,7 +29,7 @@ static inline int omap4_idle_init(void)
 
 extern void *omap3_secure_ram_storage;
 extern void omap3_pm_off_mode_enable(int);
-extern void omap_sram_idle(void);
+extern void omap_sram_idle(bool rcuidle);
 extern int omap_pm_clkdms_setup(struct clockdomain *clkdm, void *unused);
 
 #if defined(CONFIG_PM_OPP)
--- a/arch/arm/mach-omap2/pm34xx.c
+++ b/arch/arm/mach-omap2/pm34xx.c
@@ -26,6 +26,7 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/of.h>
+#include <linux/cpuidle.h>
 
 #include <trace/events/power.h>
 
@@ -174,7 +175,7 @@ static int omap34xx_do_sram_idle(unsigne
 	return 0;
 }
 
-void omap_sram_idle(void)
+void omap_sram_idle(bool rcuidle)
 {
 	/* Variable to tell what needs to be saved and restored
 	 * in omap_sram_idle*/
@@ -254,11 +255,18 @@ void omap_sram_idle(void)
 	 */
 	if (save_state)
 		omap34xx_save_context(omap3_arm_context);
+
+	if (rcuidle)
+		ct_cpuidle_enter();
+
 	if (save_state = 1 || save_state = 3)
 		cpu_suspend(save_state, omap34xx_do_sram_idle);
 	else
 		omap34xx_do_sram_idle(save_state);
 
+	if (rcuidle)
+		ct_cpuidle_exit();
+
 	/* Restore normal SDRC POWER settings */
 	if (cpu_is_omap3430() && omap_rev() >= OMAP3430_REV_ES3_0 &&
 	    (omap_type() = OMAP2_DEVICE_TYPE_EMU ||
@@ -316,7 +324,7 @@ static int omap3_pm_suspend(void)
 
 	omap3_intc_suspend();
 
-	omap_sram_idle();
+	omap_sram_idle(false);
 
 restore:
 	/* Restore next_pwrsts */

