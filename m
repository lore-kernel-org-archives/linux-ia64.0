From: Simon Horman <horms@verge.net.au>
Date: Mon, 05 Nov 2007 03:23:19 +0000
Subject: Re: [PATCH 2/6] IA64: fix memset size error
Message-Id: <20071105032319.GA15262@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472E7D34.1040509@cn.fujitsu.com>
In-Reply-To: <472E7D34.1040509@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Mon, Nov 05, 2007 at 10:17:24AM +0800, Li Zefan wrote:
> The size arguments passing to memset is wrong.
> 
> Signed-off-by Li Zefan <lizf@cn.fujitsu.com>

This looks correct to me. Acked.

> ---
>  drivers/video/ps3fb.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/video/ps3fb.c b/drivers/video/ps3fb.c
> index b3463dd..75836aa 100644
> --- a/drivers/video/ps3fb.c
> +++ b/drivers/video/ps3fb.c
> @@ -727,7 +727,7 @@ static int ps3fb_blank(int blank, struct fb_info *info)
>  
>  static int ps3fb_get_vblank(struct fb_vblank *vblank)
>  {
> -	memset(vblank, 0, sizeof(&vblank));
> +	memset(vblank, 0, sizeof(*vblank));
>  	vblank->flags = FB_VBLANK_HAVE_VSYNC;
>  	return 0;
>  }
> -- 
> 1.5.3.rc7
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

