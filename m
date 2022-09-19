From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 19 Sep 2022 09:59:45 +0000
Subject: [PATCH v2 06/44] cpuidle,tegra: Push RCU-idle into driver
Message-Id: <20220919101520.736563806@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919095939.761690562@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org
Cc: richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, linux@armlinux.org.uk, ulli.kroll@googlemail.com, linus.walleij@linaro.org, shawnguo@kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, kernel@pengutronix.de, festevam@gmail.com, linux-imx@nxp.com, tony@atomide.com, khilman@kernel.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, bcain@quicinc.com, chenhuacai@kernel.org, kernel@xen0n.name, geert@linux-m68k.org, sammy@sammy.net, monstr@monstr.eu, tsbogend@alpha.franken.de, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, richard@nod.at, anton.ivanov@cambridgegreys.com, johannes@sipsolutions.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, acme@kernel.org, mark.rutland@arm.com, alexander.shishkin@linux.intel.com, jolsa@kernel.org, namhyung@kernel.org, jgross@suse.com, srivatsa@csail.mit.edu, amakhalov@vmware.com, pv-drivers@vmware.com, boris.ostrovsky@oracle.com, chris@zankel.net, jcmvbkbc@gmail.com, rafael@kernel.org, lenb@kernel.org, pavel@ucw.cz, gregkh@linuxfoundation.org, mturquette@baylibre.com, sboyd@kernel.org, daniel.lezcano@linaro.org, lpieralisi@kernel.org, sudeep.holla@arm.com, agross@kernel.org, bjorn.andersson@linaro.org, konrad.dybcio@somainline.org, anup@brainfault.org, thierry.reding@gmail.com, jonathanh@nvidia.com, jacob.jun.pan@linux.intel.com, atishp@atishpatra.org, Arnd Bergmann <arnd@arndb.de>, yury.norov@gmail.com, andriy.shevchenko@linux.intel.com, linux@rasmusvillemoes.dk, dennis@kernel.org, tj@kernel.org, cl@linux.com, rostedt@goodmis.org, pmladek@suse.com, senozhatsky@chromium.org, john.ogness@linutronix.de, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, fweisbec@gmail.com, ryabinin.a.a@gmail.com, glider@google.com, andreyknvl@gmail.com, dvyukov@google.com, vincenzo.frascino@arm.com, Andrew Morton <akpm@linux-foundation.org>, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-omap@vger.kernel.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-xtensa@linux-xtensa.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-clk@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, kasan-dev@googlegroups.com

Doing RCU-idle outside the driver, only to then temporarily enable it
again, at least twice, before going idle is daft.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 drivers/cpuidle/cpuidle-tegra.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

--- a/drivers/cpuidle/cpuidle-tegra.c
+++ b/drivers/cpuidle/cpuidle-tegra.c
@@ -180,9 +180,11 @@ static int tegra_cpuidle_state_enter(str
 	}
 
 	local_fiq_disable();
-	RCU_NONIDLE(tegra_pm_set_cpu_in_lp2());
+	tegra_pm_set_cpu_in_lp2();
 	cpu_pm_enter();
 
+	ct_idle_enter();
+
 	switch (index) {
 	case TEGRA_C7:
 		err = tegra_cpuidle_c7_enter();
@@ -197,8 +199,10 @@ static int tegra_cpuidle_state_enter(str
 		break;
 	}
 
+	ct_idle_exit();
+
 	cpu_pm_exit();
-	RCU_NONIDLE(tegra_pm_clear_cpu_in_lp2());
+	tegra_pm_clear_cpu_in_lp2();
 	local_fiq_enable();
 
 	return err ?: index;
@@ -226,6 +230,7 @@ static int tegra_cpuidle_enter(struct cp
 			       struct cpuidle_driver *drv,
 			       int index)
 {
+	bool do_rcu = drv->states[index].flags & CPUIDLE_FLAG_RCU_IDLE;
 	unsigned int cpu = cpu_logical_map(dev->cpu);
 	int ret;
 
@@ -233,9 +238,13 @@ static int tegra_cpuidle_enter(struct cp
 	if (dev->states_usage[index].disable)
 		return -1;
 
-	if (index = TEGRA_C1)
+	if (index = TEGRA_C1) {
+		if (do_rcu)
+			ct_idle_enter();
 		ret = arm_cpuidle_simple_enter(dev, drv, index);
-	else
+		if (do_rcu)
+			ct_idle_exit();
+	} else
 		ret = tegra_cpuidle_state_enter(dev, index, cpu);
 
 	if (ret < 0) {
@@ -285,7 +294,8 @@ static struct cpuidle_driver tegra_idle_
 			.exit_latency		= 2000,
 			.target_residency	= 2200,
 			.power_usage		= 100,
-			.flags			= CPUIDLE_FLAG_TIMER_STOP,
+			.flags			= CPUIDLE_FLAG_TIMER_STOP |
+						  CPUIDLE_FLAG_RCU_IDLE,
 			.name			= "C7",
 			.desc			= "CPU core powered off",
 		},
@@ -295,6 +305,7 @@ static struct cpuidle_driver tegra_idle_
 			.target_residency	= 10000,
 			.power_usage		= 0,
 			.flags			= CPUIDLE_FLAG_TIMER_STOP |
+						  CPUIDLE_FLAG_RCU_IDLE   |
 						  CPUIDLE_FLAG_COUPLED,
 			.name			= "CC6",
 			.desc			= "CPU cluster powered off",

