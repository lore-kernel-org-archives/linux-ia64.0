From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Date: Thu, 16 Jun 2022 21:26:56 +0000
Subject: Re: [PATCH 04/36] cpuidle,intel_idle: Fix CPUIDLE_FLAG_IRQ_ENABLE
Message-Id: <20220616142656.4b1acc4a@jacob-builder>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220608142723.103523089@infradead.org>
        <20220608144516.172460444@infradead.org>
        <20220609164921.5e61711d@jacob-builder>
        <Yqb45vclY2KVL0wZ@hirez.programming.kicks-ass.net>
In-Reply-To: <Yqb45vclY2KVL0wZ@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, linux@armlinux.org.uk, ulli.kroll@googlemail.com, linus.walleij@linaro.org, shawnguo@kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, kernel@pengutronix.de, festevam@gmail.com, linux-imx@nxp.com, tony@atomide.com, khilman@kernel.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, bcain@quicinc.com, chenhuacai@kernel.org, kernel@xen0n.name, geert@linux-m68k.org, sammy@sammy.net, monstr@monstr.eu, tsbogend@alpha.franken.de, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, richard@nod.at, anton.ivanov@cambridgegreys.com, johannes@sipsolutions.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, acme@kernel.org, mark.rutland@arm.com, alexander.shishkin@linux.intel.com, jolsa@kernel.org, namhyung@kernel.org, jgross@suse.com, srivatsa@csail.mit.edu, amakhalov@vmware.com, pv-drivers@vmware.com, boris.ostrovsky@oracle.com, chris@zankel.net, jcmvbkbc@gmail.com, rafael@kernel.org, lenb@kernel.org, pavel@ucw.cz, gregkh@linuxfoundation.org, mturquette@baylibre.com, sboyd@kernel.org, daniel.lezcano@linaro.org, lpieralisi@kernel.org, sudeep.holla@arm.com, agross@kernel.org, bjorn.andersson@linaro.org, anup@brainfault.org, thierry.reding@gmail.com, jonathanh@nvidia.com, Arnd Bergmann <arnd@arndb.de>, yury.norov@gmail.com, andriy.shevchenko@linux.intel.com, linux@rasmusvillemoes.dk, rostedt@goodmis.org, pmladek@suse.com, senozhatsky@chromium.org, john.ogness@linutronix.de, paulmck@kernel.org, frederic@kernel.org, quic_neeraju@quicinc.com, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, joel@joelfernandes.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-xtensa@linux-xtensa.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-clk@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, rcu@vger.kernel.org, jacob.jun.pan@linux.intel.com

Hi Peter,

On Mon, 13 Jun 2022 10:44:22 +0200, Peter Zijlstra <peterz@infradead.org>
wrote:

> On Thu, Jun 09, 2022 at 04:49:21PM -0700, Jacob Pan wrote:
> > Hi Peter,
> > 
> > On Wed, 08 Jun 2022 16:27:27 +0200, Peter Zijlstra
> > <peterz@infradead.org> wrote:
> >   
> > > Commit c227233ad64c ("intel_idle: enable interrupts before C1 on
> > > Xeons") wrecked intel_idle in two ways:
> > > 
> > >  - must not have tracing in idle functions
> > >  - must return with IRQs disabled
> > > 
> > > Additionally, it added a branch for no good reason.
> > > 
> > > Fixes: c227233ad64c ("intel_idle: enable interrupts before C1 on
> > > Xeons") Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> > > ---
> > >  drivers/idle/intel_idle.c |   48
> > > +++++++++++++++++++++++++++++++++++----------- 1 file changed, 37
> > > insertions(+), 11 deletions(-)
> > > 
> > > --- a/drivers/idle/intel_idle.c
> > > +++ b/drivers/idle/intel_idle.c
> > > @@ -129,21 +137,37 @@ static unsigned int mwait_substates __in
> > >   *
> > >   * Must be called under local_irq_disable().
> > >   */  
> > nit: this comment is no long true, right?  
> 
> It still is, all the idle routines are called with interrupts disabled,
> but must also exit with interrupts disabled.
> 
> If the idle method requires interrupts to be enabled, it must be sure to
> disable them again before returning. Given all the RCU/tracing concerns
> it must use raw_local_irq_*() for this though.
Makes sense, it is just little confusing when the immediate caller does
raw_local_irq_enable() which does not cancel out local_irq_disable().

Thanks,

Jacob
