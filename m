From: Simon Horman <horms@verge.net.au>
Date: Mon, 06 Sep 2021 07:03:46 +0000
Subject: Re: [PATCH 1/3] ia64: Fix #endif comment for reserve_elfcorehdr()
Message-Id: <20210906070346.GB19281@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1629884459.git.geert+renesas@glider.be>
 <77b4c0648f200cab7e1c2c5171c06763e09362aa.1629884459.git.geert+renesas@glider.be>
In-Reply-To: <77b4c0648f200cab7e1c2c5171c06763e09362aa.1629884459.git.geert+renesas@glider.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Jay Lan <jlan@sgi.com>, Magnus Damm <magnus.damm@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, devicetree@vger.kernel.org

On Wed, Aug 25, 2021 at 01:48:27PM +0200, Geert Uytterhoeven wrote:
> The definition of reserve_elfcorehdr() depends on CONFIG_CRASH_DUMP, not
> CONFIG_PROC_VMCORE.
> 
> Fixes: d9a9855d0b06ca6d ("always reserve elfcore header memory in crash kernel")
> Fixes: 17c1f07ed70afa4f ("[IA64] Reserve elfcorehdr memory in CONFIG_CRASH_DUMP")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  arch/ia64/kernel/setup.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
> index dd595fbd800651fe..fbd931f1eb270d98 100644
> --- a/arch/ia64/kernel/setup.c
> +++ b/arch/ia64/kernel/setup.c
> @@ -546,7 +546,7 @@ int __init reserve_elfcorehdr(u64 *start, u64 *end)
>  	return 0;
>  }
>  
> -#endif /* CONFIG_PROC_VMCORE */
> +#endif /* CONFIG_CRASH_DUMP */
>  
>  void __init
>  setup_arch (char **cmdline_p)
> -- 
> 2.25.1
> 
