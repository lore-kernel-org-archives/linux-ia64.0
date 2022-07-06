From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 06 Jul 2022 13:54:32 +0000
Subject: Re: [PATCH 05/36] cpuidle: Move IRQ state validation
Message-Id: <CAJZ5v0g0fCNxsc1mg9aL+ieQ1uMVS+RWqesHKoZ_zeL7cx655A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220608142723.103523089@infradead.org> <20220608144516.235041924@infradead.org>
In-Reply-To: <20220608144516.235041924@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, ulli.kroll@googlemail.com, Linus Walleij <linus.walleij@linaro.org>, Shawn Guo <shawnguo@kernel.org>, Sascha Hauer <s.hauer@pengutronix.de>, Sascha Hauer <kernel@pengutronix.de>, Fabio Estevam <festevam@gmail.com>, dl-linux-imx <linux-imx@nxp.com>, Tony Lindgren <tony@atomide.com>, Kevin Hilman <khilman@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, bcain@quicinc.com, Huacai Chen <chenhuacai@kernel.org>, kernel@xen0n.name, Geert Uytterhoeven <geert@linux-m68k.org>, sammy@sammy.net, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, Stafford Horne <shorne@gmail.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, David Miller <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, anton.ivanov@cambridgegreys.com, Johannes Berg <johannes@sipsolutions.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, acme@kernel.org, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, jolsa@kernel.org, namhyung@kernel.org, Juergen Gross <jgross@suse.com>, srivatsa@csail.mit.edu, amakhalov@vmware.com, pv-drivers@vmware.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Chris Zankel <chris@zankel.net>, jcmvbkbc@gmail.com, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Daniel Lezcano <daniel.lezcano@linaro.org>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Sudeep Holla <sudeep.holla@arm.com>, Andy Gross <agross@kernel.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Anup Patel <anup@brainfault.org>, Thierry Reding <thierry.reding@gmail.com>, Jon Hunter <jonathanh@nvidia.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, senozhatsky@chromium.org, John Ogness <john.ogness@linutronix.de>, "Paul E. McKenney" <paulmck@kernel.org>, Frederic Weisbecker <frederic@kernel.org>, quic_neeraju@quicinc.com, Josh Triplett <josh@joshtriplett.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Joel Fernandes <joel@joelfernandes.org>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Benjamin Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, vschneid@redhat.com, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux OMAP Mailing List <linux-omap@vger.kernel.org>, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, openrisc@lists.librecores.org, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-xtensa@linux-xtensa.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-clk <linux-clk@vger.kernel.org>, linux-arm-msm <linux-arm-msm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, rcu@vger.kernel.org

On Wed, Jun 8, 2022 at 4:47 PM Peter Zijlstra <peterz@infradead.org> wrote:
>
> Make cpuidle_enter_state() consistent with the s2idle variant and
> verify ->enter() always returns with interrupts disabled.
>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  drivers/cpuidle/cpuidle.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> --- a/drivers/cpuidle/cpuidle.c
> +++ b/drivers/cpuidle/cpuidle.c
> @@ -234,7 +234,11 @@ int cpuidle_enter_state(struct cpuidle_d
>         stop_critical_timings();
>         if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE))
>                 rcu_idle_enter();
> +
>         entered_state = target_state->enter(dev, drv, index);
> +       if (WARN_ONCE(!irqs_disabled(), "%ps leaked IRQ state", target_state->enter))

I'm not sure if dumping a call trace here is really useful and
WARN_ON() often gets converted to panic().

I would print an error message with pr_warn_once().

Otherwise LGTM.

> +               raw_local_irq_disable();
> +
>         if (!(target_state->flags & CPUIDLE_FLAG_RCU_IDLE))
>                 rcu_idle_exit();
>         start_critical_timings();
> @@ -246,12 +250,8 @@ int cpuidle_enter_state(struct cpuidle_d
>         /* The cpu is no longer idle or about to enter idle. */
>         sched_idle_set_state(NULL);
>
> -       if (broadcast) {
> -               if (WARN_ON_ONCE(!irqs_disabled()))
> -                       local_irq_disable();
> -
> +       if (broadcast)
>                 tick_broadcast_exit();
> -       }
>
>         if (!cpuidle_state_is_coupled(drv, index))
>                 local_irq_enable();
>
>
