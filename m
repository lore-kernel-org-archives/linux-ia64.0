From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sat, 20 Mar 2021 19:01:09 +0000
Subject: Re: [PATCH] IA64: Trivial spelling fixes
Message-Id: <a3f98ec2-46e4-c7be-5e73-96c768a35bef@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210320182347.21440-1-unixbhaskar@gmail.com>
In-Reply-To: <20210320182347.21440-1-unixbhaskar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bhaskar Chowdhury <unixbhaskar@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: rdunlap@infradead.org

Hi Bhaskar!

On 3/20/21 7:23 PM, Bhaskar Chowdhury wrote:
> 
> s/seralize/serialize/ .....three different places
> 
> Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>
> ---
>  arch/ia64/kernel/pal.S | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
> index d3e22c018b68..06d01a070aae 100644
> --- a/arch/ia64/kernel/pal.S
> +++ b/arch/ia64/kernel/pal.S
> @@ -86,7 +86,7 @@ GLOBAL_ENTRY(ia64_pal_call_static)
>  	mov ar.pfs = loc1
>  	mov rp = loc0
>  	;;
> -	srlz.d				// seralize restoration of psr.l
> +	srlz.d				// serialize restoration of psr.l
>  	br.ret.sptk.many b0
>  END(ia64_pal_call_static)
>  EXPORT_SYMBOL(ia64_pal_call_static)
> @@ -194,7 +194,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_static)
>  	mov rp = loc0
>  	;;
>  	mov ar.rsc=loc4			// restore RSE configuration
> -	srlz.d				// seralize restoration of psr.l
> +	srlz.d				// serialize restoration of psr.l
>  	br.ret.sptk.many b0
>  END(ia64_pal_call_phys_static)
>  EXPORT_SYMBOL(ia64_pal_call_phys_static)
> @@ -252,7 +252,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
>  	mov rp = loc0
>  	;;
>  	mov ar.rsc=loc4			// restore RSE configuration
> -	srlz.d				// seralize restoration of psr.l
> +	srlz.d				// serialize restoration of psr.l
>  	br.ret.sptk.many b0
>  END(ia64_pal_call_phys_stacked)
>  EXPORT_SYMBOL(ia64_pal_call_phys_stacked)
> --
> 2.26.2

Thanks for fixing this. Btw, we usually use all-lowercase letters for architecture
names in the Linux kernel, so it should probably be "ia64: Trivial spelling fixes".

And the easiest way to get those fixes into the kernel would be through Andrew Morton's
tree.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
