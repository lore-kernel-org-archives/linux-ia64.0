From: Ulf Hansson <ulf.hansson@linaro.org>
Date: Tue, 04 Oct 2022 11:08:00 +0000
Subject: Re: [PATCH v2 23/44] arm,smp: Remove trace_.*_rcuidle() usage
Message-Id: <CAPDyKFoMidikoTPe0Xd+wZQdBBJSoy+CZ2ZmJShfLkbGZZRYDQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919095939.761690562@infradead.org> <20220919101521.886766952@infradead.org>
In-Reply-To: <20220919101521.886766952@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: juri.lelli@redhat.com, rafael@kernel.org, catalin.marinas@arm.com, linus.walleij@linaro.org, bsegall@google.com, guoren@kernel.org, pavel@ucw.cz, agordeev@linux.ibm.com, linux-arch@vger.kernel.org, vincent.guittot@linaro.org, mpe@ellerman.id.au, chenhuacai@kernel.org, christophe.leroy@csgroup.eu, linux-acpi@vger.kernel.org, agross@kernel.org, geert@linux-m68k.org, linux-imx@nxp.com, vgupta@kernel.org, mattst88@gmail.com, mturquette@baylibre.com, sammy@sammy.net, pmladek@suse.com, linux-pm@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, linux-um@lists.infradead.org, npiggin@gmail.com, tglx@linutronix.de, linux-omap@vger.kernel.org, dietmar.eggemann@arm.com, andreyknvl@gmail.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-perf-users@vger.kernel.org, senozhatsky@chromium.org, svens@linux.ibm.com, jolsa@kernel.org, tj@kernel.org, Andrew Morton <akpm@linux-foundation.org>, mark.rutland@arm.com, linux-ia64@vger.kernel.org, dave.hansen@linux.intel.com, virtualization@lists.linux-foundation.org, James.Bottomley@hansenpartnership.com, jcmvbkbc@gmail.com, thierry.reding@gmail.com, kernel@xen0n.name, cl@linux.com, linux-s390@vger.kernel.org, vschneid@redhat.com, john.ogness@linutronix.de, ysato@users.sourceforge.jp, linux-sh@vger.kernel.org, festevam@gmail.com, deller@gmx.de, daniel.lezcano@linaro.org, jonathanh@nvidia.com, dennis@kernel.org, lenb@kernel.org, linux-xtensa@linux-xtensa.org, kernel@pengutronix.de, gor@linux.ibm.com, linux-arm-msm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, shorne@gmail.com, chris@zankel.net, sboyd@kernel.org, dinguyen@kernel.org, bristot@redhat.com, alexander.shishkin@linux.intel.com, fweisbec@gmail.com, lpieralisi@kernel.org, atishp@atishpatra.org, linux@rasmusvillemoes.dk, kasan-dev@googlegroups.com, will@kernel.org, boris.ostrovsky@oracle.com, khilman@kernel.org, linux-csky@vger.kernel.org, pv-drivers@vmware.com, linux-snps-arc@lists.infradead.org, mgorman@suse.de, jacob.jun.pan@linux.intel.com, Arnd Bergmann <arnd@arndb.de>, ulli.kroll@googlemail.com, linux-clk@vger.kernel.org, rostedt@goodmis.org, ink@jurassic.park.msu.ru, bcain@quicinc.com, tsbogend@alpha.franken.de, linux-parisc@vger.kernel.org, ryabinin.a.a@gmail.com, sudeep.holla@arm.com, shawnguo@kernel.org, davem@davemloft.net, dalias@libc.org, tony@atomide.com, amakhalov@vmware.com, konrad.dybcio@somainline.org, bjorn.andersson@linaro.org, glider@google.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-riscv@lists.infradead.org, vincenzo.frascino@arm.com, anton.ivanov@cambridgegreys.com, jonas@southpole.se, yury.norov@gmail.com, richard@nod.at, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, richard.henderson@linaro.org, stefan.kristiansson@saunalahti.fi, openrisc@lists.librecores.org, acme@kernel.org, paul.walmsley@sifive.com, linux-tegra@vger.kernel.org, namhyung@kernel.org, andriy.shevchenko@linux.intel.com, jpoimboe@kernel.org, dvyukov@google.com, jgross@suse.com, monstr@monstr.eu, linux-mips@vger.kernel.org, palmer@dabbelt.com, anup@brainfault.org, bp@alien8.de, johannes@sipsolutions.net, linuxppc-dev@lists.ozlabs.org

On Mon, 19 Sept 2022 at 12:18, Peter Zijlstra <peterz@infradead.org> wrote:
>
> None of these functions should ever be ran with RCU disabled anymore.
>
> Specifically, do_handle_IPI() is only called from handle_IPI() which
> explicitly does irq_enter()/irq_exit() which ensures RCU is watching.
>
> The problem with smp_cross_call() was, per commit 7c64cc0531fa ("arm: Use
> _rcuidle for smp_cross_call() tracepoints"), that
> cpuidle_enter_state_coupled() already had RCU disabled, but that's
> long been fixed by commit 1098582a0f6c ("sched,idle,rcu: Push rcu_idle
> deeper into the idle path").
>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

FWIW:

Reviewed-by: Ulf Hansson <ulf.hansson@linaro.org>

Kind regards
Uffe

> ---
>  arch/arm/kernel/smp.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> --- a/arch/arm/kernel/smp.c
> +++ b/arch/arm/kernel/smp.c
> @@ -639,7 +639,7 @@ static void do_handle_IPI(int ipinr)
>         unsigned int cpu = smp_processor_id();
>
>         if ((unsigned)ipinr < NR_IPI)
> -               trace_ipi_entry_rcuidle(ipi_types[ipinr]);
> +               trace_ipi_entry(ipi_types[ipinr]);
>
>         switch (ipinr) {
>         case IPI_WAKEUP:
> @@ -686,7 +686,7 @@ static void do_handle_IPI(int ipinr)
>         }
>
>         if ((unsigned)ipinr < NR_IPI)
> -               trace_ipi_exit_rcuidle(ipi_types[ipinr]);
> +               trace_ipi_exit(ipi_types[ipinr]);
>  }
>
>  /* Legacy version, should go away once all irqchips have been converted */
> @@ -709,7 +709,7 @@ static irqreturn_t ipi_handler(int irq,
>
>  static void smp_cross_call(const struct cpumask *target, unsigned int ipinr)
>  {
> -       trace_ipi_raise_rcuidle(target, ipi_types[ipinr]);
> +       trace_ipi_raise(target, ipi_types[ipinr]);
>         __ipi_send_mask(ipi_desc[ipinr], target);
>  }
>
>
>
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
