From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 06 Feb 2023 11:10:22 +0000
Subject: Re: [PATCH 12/22] powerpc/cpu: Mark start_secondary_resume() __noreturn
Message-Id: <87v8kfdp7l.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1675461757.git.jpoimboe@kernel.org>
 <b5d065218265e79daa23f82bb84efc6a7ea120fc.1675461757.git.jpoimboe@kernel.org>
In-Reply-To: <b5d065218265e79daa23f82bb84efc6a7ea120fc.1675461757.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@kernel.org>, linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

Josh Poimboeuf <jpoimboe@kernel.org> writes:
> start_secondary_resume() doesn't return.  Annotate it as such.  By
> extension this also makes arch_cpu_idle_dead() noreturn.

Can we also mark arch_cpu_idle_dead() (the C function) __noreturn ?

Seems like it would be good documentation, even if it's not required
once the generic prototype is __noreturn.

But not a show-stopper.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

> diff --git a/arch/powerpc/include/asm/smp.h b/arch/powerpc/include/asm/smp.h
> index f63505d74932..cfd42ca8765c 100644
> --- a/arch/powerpc/include/asm/smp.h
> +++ b/arch/powerpc/include/asm/smp.h
> @@ -66,7 +66,7 @@ void start_secondary(void *unused);
>  extern int smp_send_nmi_ipi(int cpu, void (*fn)(struct pt_regs *), u64 delay_us);
>  extern int smp_send_safe_nmi_ipi(int cpu, void (*fn)(struct pt_regs *), u64 delay_us);
>  extern void smp_send_debugger_break(void);
> -extern void start_secondary_resume(void);
> +extern void __noreturn start_secondary_resume(void);
>  extern void smp_generic_give_timebase(void);
>  extern void smp_generic_take_timebase(void);
>  
> -- 
> 2.39.0
