From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 09 Sep 2008 05:19:03 +0000
Subject: Re: [PATCH]Export the symbol ia64_patch_imm64.
Message-Id: <20080909051903.GT2772@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01923FC8@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01923FC8@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 09, 2008 at 01:11:33PM +0800, Zhang, Xiantao wrote:
> diff --git a/arch/ia64/kernel/ia64_ksyms.c
> b/arch/ia64/kernel/ia64_ksyms.c
> index 6da1f20..b872f54 100644
> --- a/arch/ia64/kernel/ia64_ksyms.c
> +++ b/arch/ia64/kernel/ia64_ksyms.c
> @@ -86,6 +86,9 @@ EXPORT_SYMBOL(ia64_save_scratch_fpregs);
>  #include <asm/unwind.h>
>  EXPORT_SYMBOL(unw_init_running);
>  
> +#include <asm/patch.h>
> +EXPORT_SYMBOL_GPL(ia64_patch_imm64);

This shouldn't be exported in ia64_ksyms.c, it should be exported from
arch/ia64/kernel/patch.c.  See Documentation/CodingStyle, chapter 6.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
