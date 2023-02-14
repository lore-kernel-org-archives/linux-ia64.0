From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Tue, 14 Feb 2023 07:55:32 +0000
Subject: Re: [PATCH v2 19/24] xtensa/cpu: Make sure cpu_die() doesn't return
Message-Id: <1b4afd82-83cb-0060-7cab-8e16d2e69ff9@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <cca346b5c87693499e630291d78fb0bf12c24290.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <cca346b5c87693499e630291d78fb0bf12c24290.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@kernel.org>, linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

Hi Josh,

On 14/2/23 08:05, Josh Poimboeuf wrote:
> cpu_die() doesn't return.  Make that more explicit with a BUG().
> 
> BUG() is preferable to unreachable() because BUG() is a more explicit
> failure mode and avoids undefined behavior like falling off the edge of
> the function into whatever code happens to be next.
> 
> Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
> ---
>   arch/xtensa/kernel/smp.c | 2 ++
>   1 file changed, 2 insertions(+)
> 
> diff --git a/arch/xtensa/kernel/smp.c b/arch/xtensa/kernel/smp.c
> index 4dc109dd6214..7bad78495536 100644
> --- a/arch/xtensa/kernel/smp.c
> +++ b/arch/xtensa/kernel/smp.c

Can you update the documentation along? Currently we have:

   /*
    * Called from the idle thread for the CPU which has been shutdown.
    *
    * Note that we disable IRQs here, but do not re-enable them
    * before returning to the caller. This is also the behaviour
    * of the other hotplug-cpu capable cores, so presumably coming
    * out of idle fixes this.
    */

> @@ -341,6 +341,8 @@ void __ref cpu_die(void)
>   	__asm__ __volatile__(
>   			"	movi	a2, cpu_restart\n"
>   			"	jx	a2\n");
> +
> +	BUG();
>   }
>   
>   #endif /* CONFIG_HOTPLUG_CPU */
