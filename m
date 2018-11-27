From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 27 Nov 2018 10:34:29 +0000
Subject: Re: [PATCH v2 16/15] syscall_get_arch: add "struct task_struct *" argument
Message-Id: <87in0ihkqy.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181107042751.3b519062@akathisia>
 <CALCETrV1v-DPRfDRwiH=xn29bxWxiHdZtAH1nw=dsmDtnT0YGQ@mail.gmail.com>
 <20181120001128.GA11300@altlinux.org> <20181121004422.GA29053@altlinux.org>
In-Reply-To: <20181121004422.GA29053@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dmitry V. Levin" <ldv@altlinux.org>, Andy Lutomirski <luto@kernel.org>, Eric Paris <eparis@redhat.com>, Paul Moore <paul@paul-moore.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Eugene Syromyatnikov <esyr@redhat.com>, Elvira Khabirova <lineprinter@altlinux.org>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, linux-audit@redhat.com, linux-alpha@vger.kernel.org, nios2-dev@lists.rocketboards.org, linuxppc-dev@lists.ozlabs.org

"Dmitry V. Levin" <ldv@altlinux.org> writes:

> diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/asm/syscall.h
> index ab9f3f0a8637..d88b34179118 100644
> --- a/arch/powerpc/include/asm/syscall.h
> +++ b/arch/powerpc/include/asm/syscall.h
> @@ -100,9 +100,15 @@ static inline void syscall_set_arguments(struct task_struct *task,
>  		regs->orig_gpr3 = args[0];
>  }
>  
> -static inline int syscall_get_arch(void)
> +static inline int syscall_get_arch(struct task_struct *task)
>  {
> -	int arch = is_32bit_task() ? AUDIT_ARCH_PPC : AUDIT_ARCH_PPC64;
> +	int arch;
> +
> +	if (IS_ENABLED(CONFIG_PPC64) && !test_tsk_thread_flag(task, TIF_32BIT))
> +		arch = AUDIT_ARCH_PPC64;
> +	else
> +		arch = AUDIT_ARCH_PPC;
> +
>  #ifdef __LITTLE_ENDIAN__
>  	arch |= __AUDIT_ARCH_LE;
>  #endif

LGTM.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers
