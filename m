From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 12 Jan 2023 19:44:01 +0000
Subject: [PATCH v3 47/51] cpuidle: Ensure ct_cpuidle_enter() is always called from noinstr/__cpuidle
Message-Id: <20230112195542.212914195@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230112194314.845371875@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org
Cc: richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, linux@armlinux.org.uk, nsekhar@ti.com, brgl@bgdev.pl, ulli.kroll@googlemail.com, linus.walleij@linaro.org, shawnguo@kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, kernel@pengutronix.de, festevam@gmail.com, linux-imx@nxp.com, tony@atomide.com, khilman@kernel.org, krzysztof.kozlowski@linaro.org, alim.akhtar@samsung.com, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, bcain@quicinc.com, chenhuacai@kernel.org, kernel@xen0n.name, geert@linux-m68k.org, sammy@sammy.net, monstr@monstr.eu, tsbogend@alpha.franken.de, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, richard@nod.at, anton.ivanov@cambridgegreys.com, johannes@sipsolutions.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, acme@kernel.org, mark.rutland@arm.com, alexander.shishkin@linux.intel.com, jolsa@kernel.org, namhyung@kernel.org, jgross@suse.com, srivatsa@csail.mit.edu, amakhalov@vmware.com, pv-drivers@vmware.com, boris.ostrovsky@oracle.com, chris@zankel.net, jcmvbkbc@gmail.com, rafael@kernel.org, lenb@kernel.org, pavel@ucw.cz, gregkh@linuxfoundation.org, mturquette@baylibre.com, sboyd@kernel.org, daniel.lezcano@linaro.org, lpieralisi@kernel.org, sudeep.holla@arm.com, agross@kernel.org, andersson@kernel.org, konrad.dybcio@linaro.org, anup@brainfault.org, thierry.reding@gmail.com, jonathanh@nvidia.com, jacob.jun.pan@linux.intel.com, atishp@atishpatra.org, Arnd Bergmann <arnd@arndb.de>, yury.norov@gmail.com, andriy.shevchenko@linux.intel.com, linux@rasmusvillemoes.dk, dennis@kernel.org, tj@kernel.org, cl@linux.com, rostedt@goodmis.org, mhiramat@kernel.org, frederic@kernel.org, paulmck@kernel.org, pmladek@suse.com, senozhatsky@chromium.org, john.ogness@linutronix.de, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, ryabinin.a.a@gmail.com, glider@google.com, andreyknvl@gmail.com, dvyukov@google.com, vincenzo.frascino@arm.com, Andrew Morton <akpm@linux-foundation.org>, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-omap@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-xtensa@linux-xtensa.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-clk@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-trace-kernel@vger.kernel.org, kasan-dev@googlegroups.com

Tracing (kprobes included) and other compiler instrumentation relies
on a normal kernel runtime. Therefore all functions that disable RCU
should be noinstr, as should all functions that are called while RCU
is disabled.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 drivers/cpuidle/cpuidle.c |   37 ++++++++++++++++++++++++++++---------
 1 file changed, 28 insertions(+), 9 deletions(-)

--- a/drivers/cpuidle/cpuidle.c
+++ b/drivers/cpuidle/cpuidle.c
@@ -137,11 +137,13 @@ int cpuidle_find_deepest_state(struct cp
 }
 
 #ifdef CONFIG_SUSPEND
-static void enter_s2idle_proper(struct cpuidle_driver *drv,
-				struct cpuidle_device *dev, int index)
+static noinstr void enter_s2idle_proper(struct cpuidle_driver *drv,
+					 struct cpuidle_device *dev, int index)
 {
-	ktime_t time_start, time_end;
 	struct cpuidle_state *target_state = &drv->states[index];
+	ktime_t time_start, time_end;
+
+	instrumentation_begin();
 
 	time_start = ns_to_ktime(local_clock());
 
@@ -152,13 +154,18 @@ static void enter_s2idle_proper(struct c
 	 * suspended is generally unsafe.
 	 */
 	stop_critical_timings();
-	if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE))
+	if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE)) {
 		ct_cpuidle_enter();
+		/* Annotate away the indirect call */
+		instrumentation_begin();
+	}
 	target_state->enter_s2idle(dev, drv, index);
 	if (WARN_ON_ONCE(!irqs_disabled()))
 		raw_local_irq_disable();
-	if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE))
+	if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE)) {
+		instrumentation_end();
 		ct_cpuidle_exit();
+	}
 	tick_unfreeze();
 	start_critical_timings();
 
@@ -166,6 +173,7 @@ static void enter_s2idle_proper(struct c
 
 	dev->states_usage[index].s2idle_time += ktime_us_delta(time_end, time_start);
 	dev->states_usage[index].s2idle_usage++;
+	instrumentation_end();
 }
 
 /**
@@ -200,8 +208,9 @@ int cpuidle_enter_s2idle(struct cpuidle_
  * @drv: cpuidle driver for this cpu
  * @index: index into the states table in @drv of the state to enter
  */
-int cpuidle_enter_state(struct cpuidle_device *dev, struct cpuidle_driver *drv,
-			int index)
+noinstr int cpuidle_enter_state(struct cpuidle_device *dev,
+				 struct cpuidle_driver *drv,
+				 int index)
 {
 	int entered_state;
 
@@ -209,6 +218,8 @@ int cpuidle_enter_state(struct cpuidle_d
 	bool broadcast = !!(target_state->flags & CPUIDLE_FLAG_TIMER_STOP);
 	ktime_t time_start, time_end;
 
+	instrumentation_begin();
+
 	/*
 	 * Tell the time framework to switch to a broadcast timer because our
 	 * local timer will be shut down.  If a local timer is used from another
@@ -235,15 +246,21 @@ int cpuidle_enter_state(struct cpuidle_d
 	time_start = ns_to_ktime(local_clock());
 
 	stop_critical_timings();
-	if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE))
+	if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE)) {
 		ct_cpuidle_enter();
+		/* Annotate away the indirect call */
+		instrumentation_begin();
+	}
 
 	entered_state = target_state->enter(dev, drv, index);
+
 	if (WARN_ONCE(!irqs_disabled(), "%ps leaked IRQ state", target_state->enter))
 		raw_local_irq_disable();
 
-	if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE))
+	if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE)) {
+		instrumentation_end();
 		ct_cpuidle_exit();
+	}
 	start_critical_timings();
 
 	sched_clock_idle_wakeup_event();
@@ -306,6 +323,8 @@ int cpuidle_enter_state(struct cpuidle_d
 		dev->states_usage[index].rejected++;
 	}
 
+	instrumentation_end();
+
 	return entered_state;
 }
 

