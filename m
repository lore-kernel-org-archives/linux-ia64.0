From: Sui Jingfeng <15330273260@189.cn>
Date: Thu, 04 May 2023 11:31:24 +0000
Subject: Re: [v4,3/6] fbdev: Include <linux/io.h> in various drivers
Message-Id: <58d2bd17-3b51-bd24-2f30-d849d3f72b0e@189.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230504074539.8181-4-tzimmermann@suse.de>
In-Reply-To: <20230504074539.8181-4-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@HansenPartnership.com, arnd@arndb.de, sam@ravnborg.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org


Reviewed-by: Sui Jingfeng <suijingfeng@loongson.cn>


On 2023/5/4 15:45, Thomas Zimmermann wrote:
> The code uses writel() and similar I/O-memory helpers. Include
> the header file to get the declarations.
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
> ---
>   drivers/video/fbdev/arcfb.c       | 1 +
>   drivers/video/fbdev/aty/atyfb.h   | 2 ++
>   drivers/video/fbdev/wmt_ge_rops.c | 2 ++
>   3 files changed, 5 insertions(+)
>
> diff --git a/drivers/video/fbdev/arcfb.c b/drivers/video/fbdev/arcfb.c
> index 45e64016db32..d631d53f42ad 100644
> --- a/drivers/video/fbdev/arcfb.c
> +++ b/drivers/video/fbdev/arcfb.c
> @@ -41,6 +41,7 @@
>   #include <linux/vmalloc.h>
>   #include <linux/delay.h>
>   #include <linux/interrupt.h>
> +#include <linux/io.h>
>   #include <linux/fb.h>
>   #include <linux/init.h>
>   #include <linux/arcfb.h>
> diff --git a/drivers/video/fbdev/aty/atyfb.h b/drivers/video/fbdev/aty/atyfb.h
> index 465f55beb97f..30da3e82ed3c 100644
> --- a/drivers/video/fbdev/aty/atyfb.h
> +++ b/drivers/video/fbdev/aty/atyfb.h
> @@ -3,8 +3,10 @@
>    *  ATI Frame Buffer Device Driver Core Definitions
>    */
>   
> +#include <linux/io.h>
>   #include <linux/spinlock.h>
>   #include <linux/wait.h>
> +
>       /*
>        *  Elements of the hardware specific atyfb_par structure
>        */
> diff --git a/drivers/video/fbdev/wmt_ge_rops.c b/drivers/video/fbdev/wmt_ge_rops.c
> index 42255d27a1db..99c7b0aea615 100644
> --- a/drivers/video/fbdev/wmt_ge_rops.c
> +++ b/drivers/video/fbdev/wmt_ge_rops.c
> @@ -9,7 +9,9 @@
>   
>   #include <linux/module.h>
>   #include <linux/fb.h>
> +#include <linux/io.h>
>   #include <linux/platform_device.h>
> +
>   #include "core/fb_draw.h"
>   #include "wmt_ge_rops.h"
>   
