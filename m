From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 17 Nov 2022 09:12:42 +0000
Subject: Re: [RFC PATCH v2 6/8] treewide: Trace IPIs sent via smp_send_reschedule()
Message-Id: <Y3X7CijMXpqQIHhk@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221102182949.3119584-1-vschneid@redhat.com>
 <20221102183336.3120536-5-vschneid@redhat.com>
In-Reply-To: <20221102183336.3120536-5-vschneid@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <vschneid@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, Guo Ren <guoren@kernel.org>, "Paul E. McKenney" <paulmck@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, "David S. Miller" <davem@davemloft.net>

On Wed, Nov 02, 2022 at 06:33:34PM +0000, Valentin Schneider wrote:

> diff --git a/kernel/smp.c b/kernel/smp.c
> index c4d561cf50d45..44fa4b9b1f46b 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -167,6 +167,14 @@ send_call_function_ipi_mask(const struct cpumask *mask)
>  	arch_send_call_function_ipi_mask(mask);
>  }
>  
> +void smp_send_reschedule(int cpu)
> +{
> +	/* XXX scheduler_ipi is inline :/ */
> +	trace_ipi_send_cpumask(cpumask_of(cpu), _RET_IP_, NULL);
> +	arch_smp_send_reschedule(cpu);
> +}
> +EXPORT_SYMBOL_GPL(smp_send_reschedule);

Yeah, no.. I see some crazy archs do this, but no we're not exporting
this in generic.
