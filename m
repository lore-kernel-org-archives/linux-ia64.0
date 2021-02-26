From: Chris Down <chris@chrisdown.name>
Date: Fri, 26 Feb 2021 12:47:58 +0000
Subject: Re: [PATCH] ia64: Depend on non-static printk for cmpxchg debug
Message-Id: <YDjt/lI82VzZcCgq@chrisdown.name>
List-Id: <linux-ia64.vger.kernel.org>
References: <YCflN5zTvo5mxvKY@chrisdown.name>
In-Reply-To: <YCflN5zTvo5mxvKY@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

+ akpm, linux-mm

Hey folks,

Chris Down writes:
>With !CONFIG_PRINTK, printk() is static in the header, but ia64's
>cmpxchg.h with CONFIG_IA64_DEBUG_CMPXCHG doesn't take this into account
>before trying to use it as extern, resulting in a compiler error:
>
>    ./include/linux/printk.h:219:5: error: static declaration of 'printk' follows non-static declaration
>    219 | int printk(const char *s, ...)
>	|     ^~~~~~
>    ./arch/ia64/include/uapi/asm/cmpxchg.h:142:14: note: previous declaration of 'printk' was here
>    142 |   extern int printk(const char *fmt, ...);  \
>	|              ^~~~~~
>
>Make CONFIG_IA64_DEBUG_CMPXCHG dependent on CONFIG_PRINTK to avoid this.
>
>Signed-off-by: Chris Down <chris@chrisdown.name>
>Reported-by: kernel test robot <lkp@intel.com>
>Cc: Tony Luck <tony.luck@intel.com>
>Cc: Fenghua Yu <fenghua.yu@intel.com>
>Cc: linux-ia64@vger.kernel.org

I now see that last month ia64 was marked as orphaned, so I'm going to send 
this over to Andrew/-mm.

Andrew, any chance you can take this in your tree? It's causing spurious LKP 
noise for some recent work on printk and would be great to have in -next.

Thanks,

Chris

>---
> arch/ia64/Kconfig.debug | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/arch/ia64/Kconfig.debug b/arch/ia64/Kconfig.debug
>index 40ca23bd228d..2ce008e2d164 100644
>--- a/arch/ia64/Kconfig.debug
>+++ b/arch/ia64/Kconfig.debug
>@@ -39,7 +39,7 @@ config DISABLE_VHPT
>
> config IA64_DEBUG_CMPXCHG
> 	bool "Turn on compare-and-exchange bug checking (slow!)"
>-	depends on DEBUG_KERNEL
>+	depends on DEBUG_KERNEL && PRINTK
> 	help
> 	  Selecting this option turns on bug checking for the IA-64
> 	  compare-and-exchange instructions.  This is slow!  Itaniums
>-- 
>2.30.1
>
