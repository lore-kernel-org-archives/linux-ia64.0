From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 17 Nov 2022 09:08:15 +0000
Subject: Re: [RFC PATCH v2 4/8] smp: Trace IPIs sent via arch_send_call_function_ipi_mask()
Message-Id: <Y3X5/65o8127DgZl@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221102182949.3119584-1-vschneid@redhat.com>
 <20221102183336.3120536-3-vschneid@redhat.com>
In-Reply-To: <20221102183336.3120536-3-vschneid@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <vschneid@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, "Paul E. McKenney" <paulmck@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Guo Ren <guoren@kernel.org>, "David S. Miller" <davem@davemloft.net>

On Wed, Nov 02, 2022 at 06:33:32PM +0000, Valentin Schneider wrote:
> This simply wraps around the arch function and prepends it with a
> tracepoint, similar to send_call_function_single_ipi().
> 
> Signed-off-by: Valentin Schneider <vschneid@redhat.com>
> ---
>  kernel/smp.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/smp.c b/kernel/smp.c
> index e2ca1e2f31274..c4d561cf50d45 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -160,6 +160,13 @@ void __init call_function_init(void)
>  	smpcfd_prepare_cpu(smp_processor_id());
>  }
>  
> +static inline void

Given the use of _RET_IP_, I would strongly recommend you use
__always_inline.

> +send_call_function_ipi_mask(const struct cpumask *mask)
> +{
> +	trace_ipi_send_cpumask(mask, _RET_IP_, func);

What's func?

> +	arch_send_call_function_ipi_mask(mask);
> +}
