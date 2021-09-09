From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 09 Sep 2021 23:36:55 +0000
Subject: Re: [PATCH v4] ftrace: Cleanup ftrace_dyn_arch_init()
Message-Id: <20210909193655.7bc715af@gandalf.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210909090216.1955240-1-o451686892@gmail.com>
In-Reply-To: <20210909090216.1955240-1-o451686892@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Weizhao Ouyang <o451686892@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S.
 Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Thu,  9 Sep 2021 17:02:16 +0800
Weizhao Ouyang <o451686892@gmail.com> wrote:

> Most of ARCHs use empty ftrace_dyn_arch_init(), introduce a weak common
> ftrace_dyn_arch_init() to cleanup them.

FYI,

I'm not ignoring this patch. I just wont be able to look at it until the
merge window is over.

-- Steve


> 
> Signed-off-by: Weizhao Ouyang <o451686892@gmail.com>
> Acked-by: Heiko Carstens <hca@linux.ibm.com> (s390)
> Acked-by: Helge Deller <deller@gmx.de> (parisc)
> 
> ---
> Changes in v4:
> -- revert the generic declaration
> 
> Changes in v3:
> -- fix unrecognized opcode on PowerPC
> 
> Changes in v2:
> -- correct CONFIG_DYNAMIC_FTRACE on PowerPC
> -- add Acked-by tag
> 
> ---
>  arch/arm/kernel/ftrace.c        | 5 -----
>  arch/arm64/kernel/ftrace.c      | 5 -----
>  arch/csky/kernel/ftrace.c       | 5 -----
>  arch/ia64/kernel/ftrace.c       | 6 ------
>  arch/microblaze/kernel/ftrace.c | 5 -----
>  arch/nds32/kernel/ftrace.c      | 5 -----
>  arch/parisc/kernel/ftrace.c     | 5 -----
>  arch/riscv/kernel/ftrace.c      | 5 -----
>  arch/s390/kernel/ftrace.c       | 5 -----
>  arch/sh/kernel/ftrace.c         | 5 -----
>  arch/sparc/kernel/ftrace.c      | 5 -----
>  arch/x86/kernel/ftrace.c        | 5 -----
>  kernel/trace/ftrace.c           | 5 +++++
>  13 files changed, 5 insertions(+), 61 deletions(-)
> 
>
