From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 06 Apr 2005 23:29:24 +0000
Subject: Re: tiger_defconfig build fails for 2.6.12-rc2-mm1
Message-Id: <Pine.LNX.4.58.0504061625160.27785@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405165047.A21553@unix-os.sc.intel.com>
In-Reply-To: <20050405165047.A21553@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 6 Apr 2005, Rajesh Shah wrote:

> That was a compile error too:
>
> arch/ia64/kernel/ia64_ksyms.c:41: error: `clear_page' undeclared here (not in a function)
> arch/ia64/kernel/ia64_ksyms.c:41: error: initializer element is not constant
> arch/ia64/kernel/ia64_ksyms.c:41: error: (near initialization for `__ksymtab_clear_page.value')
> arch/ia64/kernel/ia64_ksyms.c:41: error: __ksymtab_clear_page causes a section type conflict
> make[1]: *** [arch/ia64/kernel/ia64_ksyms.o] Error 1
>
> After reverting the patch, the resulting kernel booted fine for
> me.

Are you sure that the patch was fully applied? The patch adds clear_page
to include/asm-ia64/page.h and ia64_ksyms does #include <asm/page.h>
