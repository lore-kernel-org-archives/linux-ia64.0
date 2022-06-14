From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 14 Jun 2022 16:40:53 +0000
Subject: Re: [PATCH 14/36] cpuidle: Fix rcu_idle_*() usage
Message-Id: <Yqi6Fd38ZCsDUnQG@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220608142723.103523089@infradead.org>
 <20220608144516.808451191@infradead.org>
 <YqiB6YpVqq4wuDtO@FVFF77S0Q05N>
In-Reply-To: <YqiB6YpVqq4wuDtO@FVFF77S0Q05N>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Rutland <mark.rutland@arm.com>
Cc: rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, linux@armlinux.org.uk, ulli.kroll@googlemail.com, linus.walleij@linaro.org, shawnguo@kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, kernel@pengutronix.de, festevam@gmail.com, linux-imx@nxp.com, tony@atomide.com, khilman@kernel.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, bcain@quicinc.com, chenhuacai@kernel.org, kernel@xen0n.name, geert@linux-m68k.org, sammy@sammy.net, monstr@monstr.eu, tsbogend@alpha.franken.de, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, richard@nod.at, anton.ivanov@cambridgegreys.com, johannes@sipsolutions.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@kernel.org, namhyung@kernel.org, jgross@suse.com, srivatsa@csail.mit.edu, amakhalov@vmware.com, pv-drivers@vmware.com, boris.ostrovsky@oracle.com, chris@zankel.net, jcmvbkbc@gmail.com, rafael@kernel.org, lenb@kernel.org, pavel@ucw.cz, gregkh@linuxfoundation.org, mturquette@baylibre.com, sboyd@kernel.org, daniel.lezcano@linaro.org, lpieralisi@kernel.org, sudeep.holla@arm.com, agross@kernel.org, bjorn.andersson@linaro.org, anup@brainfault.org, thierry.reding@gmail.com, jonathanh@nvidia.com, jacob.jun.pan@linux.intel.com, Arnd Bergmann <arnd@arndb.de>, yury.norov@gmail.com, andriy.shevchenko@linux.intel.com, linux@rasmusvillemoes.dk, rostedt@goodmis.org, pmladek@suse.com, senozhatsky@chromium.org, john.ogness@linutronix.de, paulmck@kernel.org, frederic@kernel.org, quic_neeraju@quicinc.com, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, joel@joelfernandes.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-xtensa@linux-xtensa.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-clk@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, rcu@vger.kernel.org

On Tue, Jun 14, 2022 at 01:41:13PM +0100, Mark Rutland wrote:
> On Wed, Jun 08, 2022 at 04:27:37PM +0200, Peter Zijlstra wrote:
> > --- a/kernel/time/tick-broadcast.c
> > +++ b/kernel/time/tick-broadcast.c
> > @@ -622,9 +622,13 @@ struct cpumask *tick_get_broadcast_onesh
> >   * to avoid a deep idle transition as we are about to get the
> >   * broadcast IPI right away.
> >   */
> > -int tick_check_broadcast_expired(void)
> > +noinstr int tick_check_broadcast_expired(void)
> >  {
> > +#ifdef _ASM_GENERIC_BITOPS_INSTRUMENTED_NON_ATOMIC_H
> > +	return arch_test_bit(smp_processor_id(), cpumask_bits(tick_broadcast_force_mask));
> > +#else
> >  	return cpumask_test_cpu(smp_processor_id(), tick_broadcast_force_mask);
> > +#endif
> >  }
> 
> This is somewhat not-ideal. :/

I'll say.

> Could we unconditionally do the arch_test_bit() variant, with a comment, or
> does that not exist in some cases?

Loads of build errors ensued, which is how I ended up with this mess ...
