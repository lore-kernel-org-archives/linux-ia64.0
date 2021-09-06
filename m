From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 06 Sep 2021 14:22:46 +0000
Subject: Re: [PATCH v2] ftrace: Cleanup ftrace_dyn_arch_init()
Message-Id: <87v93dn5qh.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210906111626.1259867-1-o451686892@gmail.com>
In-Reply-To: <20210906111626.1259867-1-o451686892@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Weizhao Ouyang <o451686892@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Weizhao Ouyang <o451686892@gmail.com>

Weizhao Ouyang <o451686892@gmail.com> writes:
> Most of ARCHs use empty ftrace_dyn_arch_init(), introduce a weak common
> ftrace_dyn_arch_init() to cleanup them.
>
> Signed-off-by: Weizhao Ouyang <o451686892@gmail.com>
> Acked-by: Heiko Carstens <hca@linux.ibm.com> (s390)
>
> ---
>
> Changes in v2:
> -- correct CONFIG_DYNAMIC_FTRACE on PowerPC
> -- add Acked-by tag

> diff --git a/arch/powerpc/include/asm/ftrace.h b/arch/powerpc/include/asm/ftrace.h
> index debe8c4f7062..d59f67c0225f 100644
> --- a/arch/powerpc/include/asm/ftrace.h
> +++ b/arch/powerpc/include/asm/ftrace.h
> @@ -61,6 +61,10 @@ struct dyn_arch_ftrace {
>  };
>  #endif /* __ASSEMBLY__ */
>  
> +#ifdef CONFIG_DYNAMIC_FTRACE
> +int __init ftrace_dyn_arch_init(void);
> +#endif /* CONFIG_DYNAMIC_FTRACE */
> +
>  #ifdef CONFIG_DYNAMIC_FTRACE_WITH_REGS
>  #define ARCH_SUPPORTS_FTRACE_OPS 1
>  #endif

That breaks the build for powerpc:

  /linux/arch/powerpc/include/asm/ftrace.h: Assembler messages:
  /linux/arch/powerpc/include/asm/ftrace.h:65: Error: unrecognized opcode: `int'
  make[4]: *** [/linux/scripts/Makefile.build:352: arch/powerpc/kernel/trace/ftrace_64.o] Error 1
  make[3]: *** [/linux/scripts/Makefile.build:514: arch/powerpc/kernel/trace] Error 2
  make[2]: *** [/linux/scripts/Makefile.build:514: arch/powerpc/kernel] Error 2
  make[1]: *** [/linux/Makefile:1861: arch/powerpc] Error 2
  make[1]: *** Waiting for unfinished jobs....

It needs to be inside an #ifndef __ASSEMBLY__ section.

cheers
