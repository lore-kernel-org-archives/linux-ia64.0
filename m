From: dann frazier <dannf@hp.com>
Date: Mon, 16 Aug 2004 03:29:37 +0000
Subject: Re: [PATCH] fix generic build when CONFIG_SMP=n
Message-Id: <20040816032937.GA3240@jale>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131559.59229.jbarnes@engr.sgi.com>
In-Reply-To: <200408131559.59229.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 13, 2004 at 03:59:59PM -0700, Jesse Barnes wrote:
> This patch fixes the issues I saw with CONFIG_SMP=n when building a generic 
> kernel with CONFIG_NUMA=y and CONFIG_DISCONTIGMEM=y.  It's still pretty 
> rough, but I'd appreciate comments and testing on other platforms.  The 
> per-cpu fixes are still pretty ugly--I'm sure I'm missing something that 
> would make abstracting out per_cpu(cpu_info, cpu).node_data = 
> mem_data[node].node_data much nicer looking.
> 
> Fixing the build of generic kernels w/o CONFIG_NUMA or CONFIG_DISCONTIGMEM is 
> left as an exercise for the reader. :)

Here's the results of some 2.6.8 boot testing:

-----------------------------------------------------------------------------
 generic-no-smp-2    generic_defconfig                                     
    patch?                delta               machine           results    
-----------------------------------------------------------------------------
     No               ITANIUM=y                HP i2000            OK
-----------------------------------------------------------------------------
     Yes              ITANIUM=y                HP i2000            OK
-----------------------------------------------------------------------------
     Yes              ITANIUM=y                   N/A         build fails [1]
                      SMP=n
-----------------------------------------------------------------------------
     Yes              ITANIUM=y                   N/A         build fails [2]
                      SMP=n
                      CYCLONE=n
-----------------------------------------------------------------------------
     Yes              ITANIUM=y                   N/A              OK
                      SMP=n
                      CYCLONE=n                HP i2000
                      SERIAL_SGI_L1_CONSOLE=n
-----------------------------------------------------------------------------
     Yes                                       HP rx2600           OK
-----------------------------------------------------------------------------
     Yes              SMP=n                    HP rx2600           OK
                      CYCLONE=n
                      SERIAL_SGI_L1_CONSOLE=n
[1]
  CC      arch/ia64/kernel/cyclone.o
arch/ia64/kernel/cyclone.c:13: error: parse error before "cyclone_setup"
arch/ia64/kernel/cyclone.c:14: warning: return type defaults to `int'
arch/ia64/kernel/cyclone.c: In function `get_offset_cyclone':
arch/ia64/kernel/cyclone.c:29: warning: implicit declaration of function `readl'arch/ia64/kernel/cyclone.c: At top level:
arch/ia64/kernel/cyclone.c:78: error: parse error before "init_cyclone_clock"
arch/ia64/kernel/cyclone.c:79: warning: return type defaults to `int'
arch/ia64/kernel/cyclone.c: In function `init_cyclone_clock':
arch/ia64/kernel/cyclone.c:92: warning: implicit declaration of function `ioremap_nocache'
arch/ia64/kernel/cyclone.c:92: warning: cast to pointer from integer of different size
arch/ia64/kernel/cyclone.c:98: warning: implicit declaration of function `readq'arch/ia64/kernel/cyclone.c:104: warning: implicit declaration of function `iounmap'
arch/ia64/kernel/cyclone.c:108: warning: cast to pointer from integer of different size
arch/ia64/kernel/cyclone.c:114: warning: implicit declaration of function `writel'
arch/ia64/kernel/cyclone.c:119: warning: cast to pointer from integer of different size
arch/ia64/kernel/cyclone.c:130: warning: cast to pointer from integer of different size
arch/ia64/kernel/cyclone.c: At top level:
arch/ia64/kernel/cyclone.c:157: warning: type defaults to `int' in declaration of `__initcall'
arch/ia64/kernel/cyclone.c:157: warning: parameter names (without types) in function declaration
arch/ia64/kernel/cyclone.c:157: warning: data definition has no type or storage class
make[1]: *** [arch/ia64/kernel/cyclone.o] Error 1
make: *** [arch/ia64/kernel] Error 2

[2]
  CC      drivers/serial/sn_console.o
drivers/serial/sn_console.c: In function `snt_sim_puts':
drivers/serial/sn_console.c:216: warning: implicit declaration of function `writeb'
drivers/serial/sn_console.c: In function `snt_sim_getc':
drivers/serial/sn_console.c:230: warning: implicit declaration of function `readb'
drivers/serial/sn_console.c: At top level:
drivers/serial/sn_console.c:1090: error: parse error before "else"
make[2]: *** [drivers/serial/sn_console.o] Error 1
make[1]: *** [drivers/serial] Error 2
make: *** [drivers] Error 2
