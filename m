From: Rajesh Shah <rajesh.shah@intel.com>
Date: Wed, 06 Apr 2005 23:46:19 +0000
Subject: Re: tiger_defconfig build fails for 2.6.12-rc2-mm1
Message-Id: <20050406164615.B32116@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405165047.A21553@unix-os.sc.intel.com>
In-Reply-To: <20050405165047.A21553@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 06, 2005 at 04:29:24PM -0700, Christoph Lameter wrote:
> On Wed, 6 Apr 2005, Rajesh Shah wrote:
> 
> > arch/ia64/kernel/ia64_ksyms.c:41: error: `clear_page' undeclared here (not in a function)
> > arch/ia64/kernel/ia64_ksyms.c:41: error: initializer element is not constant
> > arch/ia64/kernel/ia64_ksyms.c:41: error: (near initialization for `__ksymtab_clear_page.value')
> > arch/ia64/kernel/ia64_ksyms.c:41: error: __ksymtab_clear_page causes a section type conflict
> > make[1]: *** [arch/ia64/kernel/ia64_ksyms.o] Error 1
> >
> 
> Are you sure that the patch was fully applied? The patch adds clear_page
> to include/asm-ia64/page.h and ia64_ksyms does #include <asm/page.h>

Well, I'd built my -rc2-mm1 tree by applying the -rc2 patch
followed by the -mm1 patch from kernel.org. It applied cleanly
so the problem is probably that the wrong version of your patch
got included in the -mm1 patch.

Rajesh
