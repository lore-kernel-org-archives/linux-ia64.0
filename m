From: Petr Mladek <pmladek@suse.com>
Date: Thu, 09 Jun 2022 09:16:46 +0000
Subject: Re: [PATCH 24/36] printk: Remove trace_.*_rcuidle() usage
Message-Id: <YqG6URbihTNCk9YR@alley>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220608142723.103523089@infradead.org>
 <20220608144517.444659212@infradead.org>
In-Reply-To: <20220608144517.444659212@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@kernel.org, linux@armlinux.org.uk, ulli.kroll@googlemail.com, linus.walleij@linaro.org, shawnguo@kernel.org, Sascha Hauer <s.hauer@pengutronix.de>, kernel@pengutronix.de, festevam@gmail.com, linux-imx@nxp.com, tony@atomide.com, khilman@kernel.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, bcain@quicinc.com, chenhuacai@kernel.org, kernel@xen0n.name, geert@linux-m68k.org, sammy@sammy.net, monstr@monstr.eu, tsbogend@alpha.franken.de, dinguyen@kernel.org, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, richard@nod.at, anton.ivanov@cambridgegreys.com, johannes@sipsolutions.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, acme@kernel.org, mark.rutland@arm.com, alexander.shishkin@linux.intel.com, jolsa@kernel.org, namhyung@kernel.org, jgross@suse.com, srivatsa@csail.mit.edu, amakhalov@vmware.com, pv-drivers@vmware.com, boris.ostrovsky@oracle.com, chris@zankel.net, jcmvbkbc@gmail.com, rafael@kernel.org, lenb@kernel.org, pavel@ucw.cz, gregkh@linuxfoundation.org, mturquette@baylibre.com, sboyd@kernel.org, daniel.lezcano@linaro.org, lpieralisi@kernel.org, sudeep.holla@arm.com, agross@kernel.org, bjorn.andersson@linaro.org, anup@brainfault.org, thierry.reding@gmail.com, jonathanh@nvidia.com, jacob.jun.pan@linux.intel.com, Arnd Bergmann <arnd@arndb.de>, yury.norov@gmail.com, andriy.shevchenko@linux.intel.com, linux@rasmusvillemoes.dk, rostedt@goodmis.org, senozhatsky@chromium.org, john.ogness@linutronix.de, paulmck@kernel.org, frederic@kernel.org, quic_neeraju@quicinc.com, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, joel@joelfernandes.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, jpoimboe@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-perf-users@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-xtensa@linux-xtensa.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-clk@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, rcu@vger.kernel.org

On Wed 2022-06-08 16:27:47, Peter Zijlstra wrote:
> The problem, per commit fc98c3c8c9dc ("printk: use rcuidle console
> tracepoint"), was printk usage from the cpuidle path where RCU was
> already disabled.
> 
> Per the patches earlier in this series, this is no longer the case.

My understanding is that this series reduces a lot the amount
of code called with RCU disabled. As a result the particular printk()
call mentioned by commit fc98c3c8c9dc ("printk: use rcuidle console
tracepoint") is called with RCU enabled now. Hence this particular
problem is fixed better way now.

But is this true in general?
Does this "prevent" calling printk() a safe way in code with
RCU disabled?

I am not sure if anyone cares. printk() is the best effort
functionality because of the consoles code anyway. Also I wonder
if anyone uses this trace_console().

Therefore if this patch allows to remove some tricky tracing
code then it might be worth it. But if trace_console_rcuidle()
variant is still going to be available then I would keep using it.

Best Regards,
Petr

> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  kernel/printk/printk.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -2238,7 +2238,7 @@ static u16 printk_sprint(char *text, u16
>  		}
>  	}
>  
> -	trace_console_rcuidle(text, text_len);
> +	trace_console(text, text_len);
>  
>  	return text_len;
>  }
> 
