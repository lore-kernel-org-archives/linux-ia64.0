From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 19 Sep 2022 10:00:16 +0000
Subject: [PATCH v2 37/44] arm,omap2: Use WFI for omap2_pm_idle()
Message-Id: <20220919101522.842219871@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919095939.761690562@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org
Cc: juri.lelli@redhat.com, rafael@kernel.org, catalin.marinas@arm.com, linus.walleij@linaro.org, bsegall@google.com, guoren@kernel.org, pavel@ucw.cz, agordeev@linux.ibm.com, linux-arch@vger.kernel.org, vincent.guittot@linaro.org, mpe@ellerman.id.au, chenhuacai@kernel.org, christophe.leroy@csgroup.eu, linux-acpi@vger.kernel.org, agross@kernel.org, geert@linux-m68k.org, linux-imx@nxp.com, vgupta@kernel.org, mattst88@gmail.com, mturquette@baylibre.com, sammy@sammy.net, pmladek@suse.com, linux-pm@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, linux-um@lists.infradead.org, npiggin@gmail.com, tglx@linutronix.de, linux-omap@vger.kernel.org, dietmar.eggemann@arm.com, andreyknvl@gmail.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-perf-users@vger.kernel.org, senozhatsky@chromium.org, svens@linux.ibm.com, jolsa@kernel.org, tj@kernel.org, Andrew Morton <akpm@linux-foundation.org>, mark.rutland@arm.com, linux-ia64@vger.kernel.org, dave.hansen@linux.intel.com, virtualization@lists.linux-foundation.org, James.Bottomley@HansenPartnership.com, jcmvbkbc@gmail.com, thierry.reding@gmail.com, kernel@xen0n.name, cl@linux.com, linux-s390@vger.kernel.org, vschneid@redhat.com, john.ogness@linutronix.de, ysato@users.sourceforge.jp, linux-sh@vger.kernel.org, festevam@gmail.com, deller@gmx.de, daniel.lezcano@linaro.org, jonathanh@nvidia.com, dennis@kernel.org, lenb@kernel.org, linux-xtensa@linux-xtensa.org, kernel@pengutronix.de, gor@linux.ibm.com, linux-arm-msm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, shorne@gmail.com, chris@zankel.net, sboyd@kernel.org, dinguyen@kernel.org, bristot@redhat.com, alexander.shishkin@linux.intel.com, fweisbec@gmail.com, lpieralisi@kernel.org, atishp@atishpatra.org, linux@rasmusvillemoes.dk, kasan-dev@googlegroups.com, will@kernel.org, boris.ostrovsky@oracle.com, khilman@kernel.org, linux-csky@vger.kernel.org, pv-drivers@vmware.com, linux-snps-arc@lists.infradead.org, mgorman@suse.de, jacob.jun.pan@linux.intel.com, Arnd Bergmann <arnd@arndb.de>, ulli.kroll@googlemail.com, linux-clk@vger.kernel.org, rostedt@goodmis.org, ink@jurassic.park.msu.ru, bcain@quicinc.com, tsbogend@alpha.franken.de, linux-parisc@vger.kernel.org, ryabinin.a.a@gmail.com, sudeep.holla@arm.com, shawnguo@kernel.org, davem@davemloft.net, dalias@libc.org, tony@atomide.com, amakhalov@vmware.com, konrad.dybcio@somainline.org, bjorn.andersson@linaro.org, glider@google.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-riscv@lists.infradead.org, vincenzo.frascino@arm.com, anton.ivanov@cambridgegreys.com, jonas@southpole.se, yury.norov@gmail.com, richard@nod.at, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, richard.henderson@linaro.org, stefan.kristiansson@saunalahti.fi, openrisc@lists.librecores.org, acme@kernel.org, paul.walmsley@sifive.com, linux-tegra@vger.kernel.org, namhyung@kernel.org, andriy.shevchenko@linux.intel.com, jpoimboe@kernel.org, dvyukov@google.com, jgross@suse.com, monstr@monstr.eu, linux-mips@vger.kernel.org, palmer@dabbelt.com, anup@brainfault.org, bp@alien8.de, johannes@sipsolutions.net, linuxppc-dev@lists.ozlabs.org

arch_cpu_idle() is a very simple idle interface and exposes only a
single idle state and is expected to not require RCU and not do any
tracing/instrumentation.

As such, omap2_pm_idle() is not a valid implementation. Replace it
with a simple (shallow) omap2_do_wfi() call.

Omap2 doesn't have a cpuidle driver; but adding one would be the
recourse to (re)gain the other idle states.

Suggested-by: Tony Lindgren <tony@atomide.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/arm/mach-omap2/pm24xx.c |   51 +------------------------------------------
 1 file changed, 2 insertions(+), 49 deletions(-)

--- a/arch/arm/mach-omap2/pm24xx.c
+++ b/arch/arm/mach-omap2/pm24xx.c
@@ -116,50 +116,12 @@ static int omap2_enter_full_retention(vo
 
 static int sti_console_enabled;
 
-static int omap2_allow_mpu_retention(void)
-{
-	if (!omap2xxx_cm_mpu_retention_allowed())
-		return 0;
-	if (sti_console_enabled)
-		return 0;
-
-	return 1;
-}
-
-static void omap2_enter_mpu_retention(void)
+static void omap2_do_wfi(void)
 {
 	const int zero = 0;
 
-	/* The peripherals seem not to be able to wake up the MPU when
-	 * it is in retention mode. */
-	if (omap2_allow_mpu_retention()) {
-		/* REVISIT: These write to reserved bits? */
-		omap_prm_clear_mod_irqs(CORE_MOD, PM_WKST1, ~0);
-		omap_prm_clear_mod_irqs(CORE_MOD, OMAP24XX_PM_WKST2, ~0);
-		omap_prm_clear_mod_irqs(WKUP_MOD, PM_WKST, ~0);
-
-		/* Try to enter MPU retention */
-		pwrdm_set_next_pwrst(mpu_pwrdm, PWRDM_POWER_RET);
-
-	} else {
-		/* Block MPU retention */
-		pwrdm_set_next_pwrst(mpu_pwrdm, PWRDM_POWER_ON);
-	}
-
 	/* WFI */
 	asm("mcr p15, 0, %0, c7, c0, 4" : : "r" (zero) : "memory", "cc");
-
-	pwrdm_set_next_pwrst(mpu_pwrdm, PWRDM_POWER_ON);
-}
-
-static int omap2_can_sleep(void)
-{
-	if (omap2xxx_cm_fclks_active())
-		return 0;
-	if (__clk_is_enabled(osc_ck))
-		return 0;
-
-	return 1;
 }
 
 static void omap2_pm_idle(void)
@@ -169,16 +131,7 @@ static void omap2_pm_idle(void)
 	if (omap_irq_pending())
 		return;
 
-	error = cpu_cluster_pm_enter();
-	if (error || !omap2_can_sleep()) {
-		omap2_enter_mpu_retention();
-		goto out_cpu_cluster_pm;
-	}
-
-	omap2_enter_full_retention();
-
-out_cpu_cluster_pm:
-	cpu_cluster_pm_exit();
+	omap2_do_wfi();
 }
 
 static void __init prcm_setup_regs(void)

