From: Simon Horman <horms@verge.net.au>
Date: Mon, 05 Nov 2007 02:05:57 +0000
Subject: Re: [PATCH] Also iounmap in error path in arch/ia64/kernel/cyclone.c
Message-Id: <20071105020556.GD16909@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472D00A7.1080409@tiscali.nl>
In-Reply-To: <472D00A7.1080409@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Nov 04, 2007 at 12:13:43AM +0100, Roel Kluin wrote:
> base is a local u64. use_cyclone a global int.
> --
> Also iounmap in error path

This seems correct, but doesn't the same problem occur several other
times further down the same function?

> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
> index 790ef0d..d23acf0 100644
> --- a/arch/ia64/kernel/cyclone.c
> +++ b/arch/ia64/kernel/cyclone.c
> @@ -59,13 +59,13 @@ int __init init_cyclone_clock(void)
>  		return -ENODEV;
>  	}
>  	base = readq(reg);
> +	iounmap(reg);
>  	if(!base){
>  		printk(KERN_ERR "Summit chipset: Could not find valid CBAR"
>  				" value.\n");
>  		use_cyclone = 0;
>  		return -ENODEV;
>  	}
> -	iounmap(reg);
>  
>  	/* setup PMCC */
>  	offset = (base + CYCLONE_PMCC_OFFSET);
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

