From: Rajesh Shah <rajesh.shah@intel.com>
Date: Wed, 06 Apr 2005 23:16:18 +0000
Subject: Re: tiger_defconfig build fails for 2.6.12-rc2-mm1
Message-Id: <20050406161617.A32116@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405165047.A21553@unix-os.sc.intel.com>
In-Reply-To: <20050405165047.A21553@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 06, 2005 at 03:48:38PM -0700, Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > Do we know what the problem was with
> > add-a-clear_pages-function-to-clear-pages-of-higher.patch?  Was it a build
> > error or a compile error?
> 
> err, s/build/runtime/

That was a compile error too:

arch/ia64/kernel/ia64_ksyms.c:41: error: `clear_page' undeclared here (not in a function)
arch/ia64/kernel/ia64_ksyms.c:41: error: initializer element is not constant
arch/ia64/kernel/ia64_ksyms.c:41: error: (near initialization for `__ksymtab_clear_page.value')
arch/ia64/kernel/ia64_ksyms.c:41: error: __ksymtab_clear_page causes a section type conflict
make[1]: *** [arch/ia64/kernel/ia64_ksyms.o] Error 1

After reverting the patch, the resulting kernel booted fine for
me. 

By the way, I noticed that the automated OSDL PLM compile
failed too:
http://www.osdl.org/plm-cgi/plm?module=patch_info&patch_idC61

Their .config was different from mine but it had both the compile
failures I saw, plus some more.

Rajesh
