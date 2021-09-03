From: Heiko Carstens <hca@linux.ibm.com>
Date: Fri, 03 Sep 2021 08:21:52 +0000
Subject: Re: [PATCH] ftrace: Cleanup ftrace_dyn_arch_init()
Message-Id: <YTHbIMVw2EhNpDwO@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210903071817.1162938-1-o451686892@gmail.com>
In-Reply-To: <20210903071817.1162938-1-o451686892@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Weizhao Ouyang <o451686892@gmail.com>
Cc: rostedt@goodmis.org, mingo@redhat.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, deanbo422@gmail.com, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, gor@linux.ibm.com, borntraeger@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, bp@alien8.de, x86@kernel.org, hpa@zytor.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Fri, Sep 03, 2021 at 03:18:17PM +0800, Weizhao Ouyang wrote:
> Most ARCHs use empty ftrace_dyn_arch_init(), introduce a weak common
> ftrace_dyn_arch_init() to cleanup them.
> 
> Signed-off-by: Weizhao Ouyang <o451686892@gmail.com>
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

For s390:
Acked-by: Heiko Carstens <hca@linux.ibm.com>
