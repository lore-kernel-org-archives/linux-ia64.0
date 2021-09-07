From: LEROY Christophe <christophe.leroy@csgroup.eu>
Date: Tue, 07 Sep 2021 15:55:58 +0000
Subject: RE: [PATCH v3] ftrace: Cleanup ftrace_dyn_arch_init()
Message-Id: <MRZP264MB298824D80E6C0ADCB5EA1D9AEDD39@MRZP264MB2988.FRAP264.PROD.OUTLOOK.COM>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210907100524.1454928-1-o451686892@gmail.com>
In-Reply-To: <20210907100524.1454928-1-o451686892@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Weizhao Ouyang <o451686892@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rich Felker <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Guo Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, Vincent Chen <deanbo422@gmail.com>, Will Deacon <will@kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Helge Deller <deller@gmx.de>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Albert Ou <aou@eecs.berkeley.edu>, Vasily Gorbik <gor@linux.ibm.com>, Heiko Carstens <hca@linux.ibm.com>, Borislav Petkov <bp@alien8.de>, Greentime Hu <green.hu@gmail.com>, Paul Walmsley <paul.walmsley@sifive.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, Nick Hu <nickhu@andestech.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, Paul Mackerras <paulus@samba.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>



> -----Message d'origine-----
> De : Linuxppc-dev <linuxppc-dev-
> bounces+christophe.leroy=csgroup.eu@lists.ozlabs.org> De la part de Weizhao
> Ouyang
>
> Most of ARCHs use empty ftrace_dyn_arch_init(), introduce a weak common
> ftrace_dyn_arch_init() to cleanup them.
>
> Signed-off-by: Weizhao Ouyang <o451686892@gmail.com>
> Acked-by: Heiko Carstens <hca@linux.ibm.com> (s390)
> Acked-by: Helge Deller <deller@gmx.de> (parisc)
>
> ---
> Changes in v3:
> -- fix unrecognized opcode on PowerPC
>
> Changes in v2:
> -- correct CONFIG_DYNAMIC_FTRACE on PowerPC
> -- add Acked-by tag
>
> ---
>  arch/arm/kernel/ftrace.c          | 5 -----
>  arch/arm64/kernel/ftrace.c        | 5 -----
>  arch/csky/kernel/ftrace.c         | 5 -----
>  arch/ia64/kernel/ftrace.c         | 6 ------
>  arch/microblaze/kernel/ftrace.c   | 5 -----
>  arch/mips/include/asm/ftrace.h    | 2 ++
>  arch/nds32/kernel/ftrace.c        | 5 -----
>  arch/parisc/kernel/ftrace.c       | 5 -----
>  arch/powerpc/include/asm/ftrace.h | 4 ++++
>  arch/riscv/kernel/ftrace.c        | 5 -----
>  arch/s390/kernel/ftrace.c         | 5 -----
>  arch/sh/kernel/ftrace.c           | 5 -----
>  arch/sparc/kernel/ftrace.c        | 5 -----
>  arch/x86/kernel/ftrace.c          | 5 -----
>  include/linux/ftrace.h            | 1 -
>  kernel/trace/ftrace.c             | 5 +++++
>  16 files changed, 11 insertions(+), 62 deletions(-)
>
> diff --git a/arch/mips/include/asm/ftrace.h b/arch/mips/include/asm/ftrace.h
> index b463f2aa5a61..ed013e767390 100644
> --- a/arch/mips/include/asm/ftrace.h
> +++ b/arch/mips/include/asm/ftrace.h
> @@ -76,6 +76,8 @@ do {                                                \
>
>
>  #ifdef CONFIG_DYNAMIC_FTRACE
> +int __init ftrace_dyn_arch_init(void);
> +

Why ?


>  static inline unsigned long ftrace_call_adjust(unsigned long addr)
>  {
>       return addr;
> diff --git a/arch/powerpc/include/asm/ftrace.h
> b/arch/powerpc/include/asm/ftrace.h
> index debe8c4f7062..b05c43f13a4d 100644
> --- a/arch/powerpc/include/asm/ftrace.h
> +++ b/arch/powerpc/include/asm/ftrace.h
> @@ -126,6 +126,10 @@ static inline void this_cpu_enable_ftrace(void) { }
>  static inline void this_cpu_set_ftrace_enabled(u8 ftrace_enabled) { }
>  static inline u8 this_cpu_get_ftrace_enabled(void) { return 1; }
>  #endif /* CONFIG_PPC64 */
> +
> +#ifdef CONFIG_DYNAMIC_FTRACE
> +int __init ftrace_dyn_arch_init(void);
> +#endif /* CONFIG_DYNAMIC_FTRACE */

Why ?

>  #endif /* !__ASSEMBLY__ */
>
>  #endif /* _ASM_POWERPC_FTRACE */
> diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
> index 832e65f06754..f1eca123d89d 100644
> --- a/include/linux/ftrace.h
> +++ b/include/linux/ftrace.h
> @@ -573,7 +573,6 @@ ftrace_set_early_filter(struct ftrace_ops *ops, char
> *buf, int enable);
>
>  /* defined in arch */
>  extern int ftrace_ip_converted(unsigned long ip);
> -extern int ftrace_dyn_arch_init(void);

Why removing that ?

Have you tried to build kernel/trace/ftrace.o with C=2 ? It will likely tell you that the function is not declared and that it should be static

We could eventually consider that in the past, this generic declaration was unrelevant because the definitions where in the arch specific sections.
Now that you are implementing a generic weak version of this function, it would make sense to have a generic declaration as well.

I really don't see the point in duplicating the declaration of the function in the arch specific headers.

>  extern void ftrace_replace_code(int enable);
>  extern int ftrace_update_ftrace_func(ftrace_func_t func);
>  extern void ftrace_caller(void);

Christophe

CS Group - Document Interne
