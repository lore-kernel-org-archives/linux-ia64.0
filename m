From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 06 Feb 2009 08:19:00 +0000
Subject: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1233385816.17794.16.camel@localhost.localdomain>
In-Reply-To: <1233385816.17794.16.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>

> diff --git a/arch/ia64/include/asm/fpu.h b/arch/ia64/include/asm/fpu.h
> index 3859558..b6395ad 100644
> --- a/arch/ia64/include/asm/fpu.h
> +++ b/arch/ia64/include/asm/fpu.h
> @@ -6,7 +6,7 @@
>   *	David Mosberger-Tang <davidm@hpl.hp.com>
>   */
>  
> -#include <asm/types.h>
> +#include <linux/types.h>

this change break ia64 build perfectly.
this patch seems don't tested at all.

Ingo, I hope you ask patch author how to test posted patch ;-)

=
Subject: [PATCH] revert headers_check fix: ia64, fpu.h

commit fa9ea6c7abd94482ecd84e130676b6a1b3e61c2c break ia64 build perfectly.
it because ia64 has following include file dependency.

entry.S
 -> asm/processor.h
    -> asm/ptrace.h
       -> asm/fpu.h

Then, above commit introduce below dependency.

entry.S
 -> asm/processor.h
    -> asm/ptrace.h
       -> asm/fpu.h
          -> linux/types.h
             -> linux/posix_types.h
                -> linux/stddef.h

Then, assembler can't intepret following statement in stddef.h

enum {
        false   = 0,
        true    = 1
};


Therefore, >100 line tons error was outputed.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-next <linux-next@vger.kernel.org>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/asm/fpu.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/arch/ia64/include/asm/fpu.h
=================================--- a/arch/ia64/include/asm/fpu.h
+++ b/arch/ia64/include/asm/fpu.h
@@ -6,7 +6,7 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
-#include <linux/types.h>
+#include <asm/types.h>
 
 /* floating point status register: */
 #define FPSR_TRAP_VD	(1 << 0)	/* invalid op trap disabled */


