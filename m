From: Sui Jingfeng <15330273260@189.cn>
Date: Thu, 04 May 2023 11:34:15 +0000
Subject: Re: [v4,4/6] fbdev: Include <linux/fb.h> instead of <asm/fb.h>
Message-Id: <348508a2-1640-46b1-2ac9-72a7d5d4f859@189.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230504074539.8181-5-tzimmermann@suse.de>
In-Reply-To: <20230504074539.8181-5-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@HansenPartnership.com, arnd@arndb.de, sam@ravnborg.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org


Reviewed-by: Sui Jingfeng <suijingfeng@loongson.cn>


On 2023/5/4 15:45, Thomas Zimmermann wrote:
> Replace include statements for <asm/fb.h> with <linux/fb.h>. Fixes
> the coding style: if a header is available in asm/ and linux/, it
> is preferable to include the header from linux/. This only affects
> a few source files, most of which already include <linux/fb.h>.
>
> Suggested-by: Sam Ravnborg <sam@ravnborg.org>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> ---
>   arch/parisc/video/fbdev.c        | 3 +--
>   arch/sparc/video/fbdev.c         | 1 -
>   arch/x86/video/fbdev.c           | 2 --
>   drivers/staging/sm750fb/sm750.c  | 2 +-
>   drivers/video/fbdev/core/fbcon.c | 1 -
>   drivers/video/fbdev/core/fbmem.c | 2 --
>   include/linux/fb.h               | 2 ++
>   7 files changed, 4 insertions(+), 9 deletions(-)
>
> diff --git a/arch/parisc/video/fbdev.c b/arch/parisc/video/fbdev.c
> index 4a0ae08fc75b..137561d98246 100644
> --- a/arch/parisc/video/fbdev.c
> +++ b/arch/parisc/video/fbdev.c
> @@ -5,10 +5,9 @@
>    * Copyright (C) 2001-2002 Thomas Bogendoerfer <tsbogend@alpha.franken.de>
>    */
>   
> +#include <linux/fb.h>
>   #include <linux/module.h>
>   
> -#include <asm/fb.h>
> -
>   #include <video/sticore.h>
>   
>   int fb_is_primary_device(struct fb_info *info)
> diff --git a/arch/sparc/video/fbdev.c b/arch/sparc/video/fbdev.c
> index dadd5799fbb3..25837f128132 100644
> --- a/arch/sparc/video/fbdev.c
> +++ b/arch/sparc/video/fbdev.c
> @@ -4,7 +4,6 @@
>   #include <linux/fb.h>
>   #include <linux/module.h>
>   
> -#include <asm/fb.h>
>   #include <asm/prom.h>
>   
>   int fb_is_primary_device(struct fb_info *info)
> diff --git a/arch/x86/video/fbdev.c b/arch/x86/video/fbdev.c
> index 57ee3c158f97..f41a17ebac48 100644
> --- a/arch/x86/video/fbdev.c
> +++ b/arch/x86/video/fbdev.c
> @@ -7,8 +7,6 @@
>    *
>    */
>   
> -#include <asm/fb.h>
> -
>   #include <linux/fb.h>
>   #include <linux/module.h>
>   #include <linux/pci.h>
> diff --git a/drivers/staging/sm750fb/sm750.c b/drivers/staging/sm750fb/sm750.c
> index 22ace3168723..55e302a27847 100644
> --- a/drivers/staging/sm750fb/sm750.c
> +++ b/drivers/staging/sm750fb/sm750.c
> @@ -16,7 +16,7 @@
>   #include <linux/pagemap.h>
>   #include <linux/screen_info.h>
>   #include <linux/console.h>
> -#include <asm/fb.h>
> +
>   #include "sm750.h"
>   #include "sm750_accel.h"
>   #include "sm750_cursor.h"
> diff --git a/drivers/video/fbdev/core/fbcon.c b/drivers/video/fbdev/core/fbcon.c
> index eb565a10e5cd..c6c9d040bdec 100644
> --- a/drivers/video/fbdev/core/fbcon.c
> +++ b/drivers/video/fbdev/core/fbcon.c
> @@ -75,7 +75,6 @@
>   #include <linux/interrupt.h>
>   #include <linux/crc32.h> /* For counting font checksums */
>   #include <linux/uaccess.h>
> -#include <asm/fb.h>
>   #include <asm/irq.h>
>   
>   #include "fbcon.h"
> diff --git a/drivers/video/fbdev/core/fbmem.c b/drivers/video/fbdev/core/fbmem.c
> index 3fd95a79e4c3..38f7e83fa6e3 100644
> --- a/drivers/video/fbdev/core/fbmem.c
> +++ b/drivers/video/fbdev/core/fbmem.c
> @@ -37,8 +37,6 @@
>   #include <linux/mem_encrypt.h>
>   #include <linux/pci.h>
>   
> -#include <asm/fb.h>
> -
>   #include <video/nomodeset.h>
>   #include <video/vga.h>
>   
> diff --git a/include/linux/fb.h b/include/linux/fb.h
> index 08cb47da71f8..c0f97160ebbf 100644
> --- a/include/linux/fb.h
> +++ b/include/linux/fb.h
> @@ -15,6 +15,8 @@
>   #include <linux/list.h>
>   #include <linux/backlight.h>
>   #include <linux/slab.h>
> +
> +#include <asm/fb.h>
>   #include <asm/io.h>
>   
>   struct vm_area_struct;
