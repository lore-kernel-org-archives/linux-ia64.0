From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 20 May 2021 13:12:24 +0000
Subject: Re: [PATCH v1 1/1] kernel.h: split out panic and oops helpers (ia64 fix)
Message-Id: <f2420178-53d7-a1e4-eea7-5e1773835411@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210520130557.55277-1-andriy.shevchenko@linux.intel.com>
In-Reply-To: <20210520130557.55277-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel test robot <lkp@intel.com>

Hello Andy!

On 5/20/21 3:05 PM, Andy Shevchenko wrote:
> Note, this patch is untested. I have no ia64 compiler at hand.
> 
>  arch/ia64/include/asm/pal.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/ia64/include/asm/pal.h b/arch/ia64/include/asm/pal.h
> index 5c51fceedaf9..e6b652f9e45e 100644
> --- a/arch/ia64/include/asm/pal.h
> +++ b/arch/ia64/include/asm/pal.h
> @@ -99,6 +99,7 @@
>  
>  #include <linux/types.h>
>  #include <asm/fpu.h>
> +#include <asm/intrinsics.h>
>  
>  /*
>   * Data types needed to pass information into PAL procedures and
> 

I can test it later today.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
