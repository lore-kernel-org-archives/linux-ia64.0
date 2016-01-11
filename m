From: Matt Fleming <matt@codeblueprint.co.uk>
Date: Mon, 11 Jan 2016 14:40:04 +0000
Subject: Re: [PATCH] efi: add conditional include of asm/early_ioremap.h
Message-Id: <20160111144004.GD2644@codeblueprint.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452456249-2974-1-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1452456249-2974-1-git-send-email-ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

(Cc'ing ia64 maintainers)

On Sun, 10 Jan, at 09:04:09PM, Ard Biesheuvel wrote:
> The code in efi.c uses early_memremap(), but relies on a transitive
> include rather than including asm/early_ioremap.h directly.
> Unfortunately, this header does not exist on ia64, so it cannot be
> included directly.
> 
> Commit f7d924894265 ("arm64/efi: refactor EFI init and runtime code
> for reuse by 32-bit ARM") attempted to work around this by including
> asm/efi.h, which transitively includes asm/early_ioremap.h on most
> architectures. However, since asm/efi.h does not exist on ia64 either,
> this is not much of an improvement.
> 
> So instead, just include asm/early_ioremap.h directly, unless CONFIG_IA64
> is defined.
> 
> Fixes: f7d924894265 ("arm64/efi: refactor EFI init and runtime code for reuse by 32-bit ARM")
> Cc: Will Deacon <will.deacon@arm.com>
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  drivers/firmware/efi/efi.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
> index cffa89b3317b..53f71177824f 100644
> --- a/drivers/firmware/efi/efi.c
> +++ b/drivers/firmware/efi/efi.c
> @@ -25,7 +25,9 @@
>  #include <linux/io.h>
>  #include <linux/platform_device.h>
>  
> -#include <asm/efi.h>
> +#ifndef CONFIG_IA64
> +#include <asm/early_ioremap.h>
> +#endif
>  
>  struct efi __read_mostly efi = {
>  	.mps			= EFI_INVALID_TABLE_ADDR,

I certainly can't think of a better way to fix this right now. Tony,
Fenghua do you guys have any suggestions?

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
