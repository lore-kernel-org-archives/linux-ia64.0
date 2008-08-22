From: Robin Holt <holt@sgi.com>
Date: Fri, 22 Aug 2008 03:31:08 +0000
Subject: Re: linux-next: ia64 allmodconfig
Message-Id: <20080822033108.GL26567@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080820233526.14c44ea6.akpm@linux-foundation.org>
In-Reply-To: <20080820233526.14c44ea6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Argh,  I forgot to add the relavent people.

Robin

On Thu, Aug 21, 2008 at 10:29:31PM -0500, Robin Holt wrote:
> [holt@robinlt allmodconfig]$ git-bisect good
> e63352fa06fb8c476e56e51323d80f2e7baee67f is first bad commit
> commit e63352fa06fb8c476e56e51323d80f2e7baee67f
> Author: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> Date:   Tue Aug 19 20:43:26 2008 +0300
> 
>     kmemtrace: SLUB hooks.
>     
>     This adds hooks for the SLUB allocator, to allow tracing with kmemtrace.
>     
>     Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
>     Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> :040000 040000 913348ac82982bd048439179f5d9e2231cc42ee6 984c6232d4eb257d8b31fe104e8731d8d5d6af18 M	include
> :040000 040000 eca09754017963bda58bc53e2863f59431df0ea7 92bc3efb5a7b9bc254f17def2c31b3c0a030122e M	mm
> 
> 
> To sum up, This commit when compiled for IA64 using Andrew's gcc 3.4.5
> cross compiler and allmodconfig results in a build failure with:
> 
> arch/ia64/kernel/built-in.o(.text+0x4852): In function `efi_initialize_iomem_resources':
> /work/git-linus/allmodconfig/arch/ia64/kernel/efi.c:1200: undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x12992): In function `pfm_context_create':
> /work/git-linus/allmodconfig/arch/ia64/kernel/perfmon.c:2683: undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x1ba22): In function `sys_perfmonctl':
> /work/git-linus/allmodconfig/arch/ia64/kernel/perfmon.c:4808: undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x379a2): In function `dup_state_stack':
> /work/git-linus/allmodconfig/arch/ia64/kernel/unwind.c:645: undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x37ec2): In function `desc_prologue':
> /work/git-linus/allmodconfig/arch/ia64/kernel/unwind.c:809: undefined reference to `__ia64_save_stack_nonlocal'
> arch/ia64/kernel/built-in.o(.text+0x3a822):/work/git-linus/allmodconfig/arch/ia64/kernel/unwind_decoder.c:368: more undefined references to `__ia64_save_stack_nonlocal' follow
> 
> With gcc 4.1.2 it compiles fine.
> 
> Thanks,
> Robin
> 
> 
> On Thu, Aug 21, 2008 at 05:23:46PM -0700, Luck, Tony wrote:
> > > The resulting binary should be faster, though. ;-)
> > 
> > Ah, but I spend much more time compiling kernels than I do
> > running them ... so this isn't a good tradeoff for me ;-)
> > 
> > > How about giving
> > > GCC 4.3 a try, by the way?  IIRC, GCC 4.2 has some aliasing issues
> > > that have been addressed.
> > 
> > I tried 4.3.1 and got:
> > 
> > configure: error: Building GCC requires GMP 4.1+ and MPFR 2.3.0+.
> > 
> > So I'll have to do some other upgrading and installing on my
> > ancient build box to make this work :-(
> > 
> > -Tony
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
