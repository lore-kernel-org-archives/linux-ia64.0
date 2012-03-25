From: Randy Dunlap <rdunlap@xenotime.net>
Date: Sun, 25 Mar 2012 16:23:07 +0000
Subject: Re: [PATCH] Documentation/kernel-parameters: remove inttest parameter
Message-Id: <4F6F466B.6040204@xenotime.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1332365148-3898-1-git-send-email-sebastian@breakpoint.cc>
In-Reply-To: <1332365148-3898-1-git-send-email-sebastian@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 03/21/2012 02:25 PM, Sebastian Andrzej Siewior wrote:

> According to grep I see no users:
> | #git grep inttest
> | Documentation/kernel-parameters.txt:    inttest=        [IA-64]
> 
> The parameters itself has no description what it supposed to do.
> According to the history tree, it was introduced in "[PATCH] Updated
> Documentation/kernel-parameters.txt" ("10414c6ddb"). By that time that
> parameter had an user. It was removed later by "[PATCH] ia64: SGI SN
> update" ("c6bacd5010ec") by Jesse Barnes himself.
> 
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>


Applied.  Thanks.

> ---
>  Documentation/kernel-parameters.txt |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index d99fd9c..f65de8f 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1071,8 +1071,6 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			no_x2apic_optout
>  				BIOS x2APIC opt-out request will be ignored
>  
> -	inttest=	[IA-64]
> -
>  	iomem=		Disable strict checking of access to MMIO memory
>  		strict	regions from userspace.
>  		relaxed



-- 
~Randy
