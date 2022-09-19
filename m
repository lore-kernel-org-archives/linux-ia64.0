From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 19 Sep 2022 10:00:23 +0000
Subject: [PATCH v2 44/44] arm64,riscv,perf: Remove RCU_NONIDLE() usage
Message-Id: <20220919101523.312333837@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919095939.761690562@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org
Cc: juri.lelli@redhat.com, rafael@kernel.org, catalin.marinas@arm.com, linus.walleij@linaro.org, bsegall@google.com, guoren@kernel.org, pavel@ucw.cz, agordeev@linux.ibm.com, linux-arch@vger.kernel.org, vincent.guittot@linaro.org, mpe@ellerman.id.au, chenhuacai@kernel.org, christophe.leroy@csgroup.eu, linux-acpi@vger.kernel.org, agross@kernel.org, geert@linux-m68k.org, linux-imx@nxp.com, vgupta@kernel.org, mattst88@gmail.com, mturquette@baylibre.com, sammy@sammy.net, pmladek@suse.com, linux-pm@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, linux-um@lists.infradead.org, npiggin@gmail.com, tglx@linutronix.de, linux-omap@vger.kernel.org, dietmar.eggemann@arm.com, andreyknvl@gmail.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-perf-users@vger.kernel.org, senozhatsky@chromium.org, svens@linux.ibm.com, jolsa@kernel.org, tj@kernel.org, Andrew Morton <akpm@linux-foundation.org>, mark.rutland@arm.com, linux-ia64@vger.kernel.org, dave.hansen@linux.intel.com, virtualization@lists.linux-foundation.org, James.Bottomley@HansenPartnership.com, jcmvbkbc@gmail.com, thierry.reding@gmail.com, kernel@xen0n.name, cl@linux.com, linux-s390@vger.kernel.org, vschneid@redhat.com, john.ogness@linutronix.de, ysato@users.sourceforge.jp, linux-sh@vger.kernel.org, festevam@gmail.com, deller@gmx.de, daniel.lezcano@linaro.org, jonathanh@nvidia.com, dennis@kernel.org, lenb@kernel.org, linux-xtensa@linux-xtensa.org, kernel@pengutronix.de, gor@linux.ibm.com, linux-arm-msm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, shorne@gmail.com, chris@zankel.net, sboyd@kernel.org, dinguyen@kernel.org, bristot@redhat.com, alexander.shishkin@linux.intel.com, fweisbec@gmail.com, lpieralisi@kernel.org, atishp@atishpatra.org, linux@rasmusvillemoes.dk, kasan-dev@googlegroups.com, will@kernel.org, boris.ostrovsky@oracle.com, khilman@kernel.org, linux-csky@vger.kernel.org, pv-drivers@vmware.com, linux-snps-arc@lists.infradead.org, mgorman@suse.de, jacob.jun.pan@linux.intel.com, Arnd Bergmann <arnd@arndb.de>, ulli.kroll@googlemail.com, linux-clk@vger.kernel.org, rostedt@goodmis.org, ink@jurassic.park.msu.ru, bcain@quicinc.com, tsbogend@alpha.franken.de, linux-parisc@vger.kernel.org, ryabinin.a.a@gmail.com, sudeep.holla@arm.com, shawnguo@kernel.org, davem@davemloft.net, dalias@libc.org, tony@atomide.com, amakhalov@vmware.com, konrad.dybcio@somainline.org, bjorn.andersson@linaro.org, glider@google.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-riscv@lists.infradead.org, vincenzo.frascino@arm.com, anton.ivanov@cambridgegreys.com, jonas@southpole.se, yury.norov@gmail.com, richard@nod.at, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, richard.henderson@linaro.org, stefan.kristiansson@saunalahti.fi, openrisc@lists.librecores.org, acme@kernel.org, paul.walmsley@sifive.com, linux-tegra@vger.kernel.org, namhyung@kernel.org, andriy.shevchenko@linux.intel.com, jpoimboe@kernel.org, dvyukov@google.com, jgross@suse.com, monstr@monstr.eu, linux-mips@vger.kernel.org, palmer@dabbelt.com, anup@brainfault.org, bp@alien8.de, johannes@sipsolutions.net, linuxppc-dev@lists.ozlabs.org

The PM notifiers should no longer be ran with RCU disabled (per the
previous patches), as such this hack is no longer required either.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 drivers/perf/arm_pmu.c       |   11 +----------
 drivers/perf/riscv_pmu_sbi.c |    8 +-------
 2 files changed, 2 insertions(+), 17 deletions(-)

--- a/drivers/perf/arm_pmu.c
+++ b/drivers/perf/arm_pmu.c
@@ -762,17 +762,8 @@ static void cpu_pm_pmu_setup(struct arm_
 		case CPU_PM_ENTER_FAILED:
 			 /*
 			  * Restore and enable the counter.
-			  * armpmu_start() indirectly calls
-			  *
-			  * perf_event_update_userpage()
-			  *
-			  * that requires RCU read locking to be functional,
-			  * wrap the call within RCU_NONIDLE to make the
-			  * RCU subsystem aware this cpu is not idle from
-			  * an RCU perspective for the armpmu_start() call
-			  * duration.
 			  */
-			RCU_NONIDLE(armpmu_start(event, PERF_EF_RELOAD));
+			armpmu_start(event, PERF_EF_RELOAD);
 			break;
 		default:
 			break;
--- a/drivers/perf/riscv_pmu_sbi.c
+++ b/drivers/perf/riscv_pmu_sbi.c
@@ -747,14 +747,8 @@ static int riscv_pm_pmu_notify(struct no
 		case CPU_PM_ENTER_FAILED:
 			/*
 			 * Restore and enable the counter.
-			 *
-			 * Requires RCU read locking to be functional,
-			 * wrap the call within RCU_NONIDLE to make the
-			 * RCU subsystem aware this cpu is not idle from
-			 * an RCU perspective for the riscv_pmu_start() call
-			 * duration.
 			 */
-			RCU_NONIDLE(riscv_pmu_start(event, PERF_EF_RELOAD));
+			riscv_pmu_start(event, PERF_EF_RELOAD);
 			break;
 		default:
 			break;

