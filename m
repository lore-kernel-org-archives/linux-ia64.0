From: Sui Jingfeng <15330273260@189.cn>
Date: Wed, 10 May 2023 18:20:31 +0000
Subject: Re: [PATCH v6 1/6] fbdev/matrox: Remove trailing whitespaces
Message-Id: <0e13efbf-9a48-6e70-fdf3-8290f28c6dc7@189.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-1-tzimmermann@suse.de>
 <20230510110557.14343-2-tzimmermann@suse.de>
In-Reply-To: <20230510110557.14343-2-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Thomas Zimmermann <tzimmermann@suse.de>, deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@HansenPartnership.com, arnd@arndb.de, sam@ravnborg.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org

Hi, Thomas


I love your patch, yet something to improve:


On 2023/5/10 19:05, Thomas Zimmermann wrote:
> Fix coding style. No functional changes.
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
> Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
> Reviewed-by: Sui Jingfeng <suijingfeng@loongson.cn>
> Tested-by: Sui Jingfeng <suijingfeng@loongson.cn>
> ---
>   drivers/video/fbdev/matrox/matroxfb_accel.c | 6 +++---
>   drivers/video/fbdev/matrox/matroxfb_base.h  | 4 ++--
>   2 files changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/video/fbdev/matrox/matroxfb_accel.c b/drivers/video/fbdev/matrox/matroxfb_accel.c
> index 9cb0685feddd..ce51227798a1 100644
> --- a/drivers/video/fbdev/matrox/matroxfb_accel.c
> +++ b/drivers/video/fbdev/matrox/matroxfb_accel.c
> @@ -88,7 +88,7 @@
>   
>   static inline void matrox_cfb4_pal(u_int32_t* pal) {
>   	unsigned int i;
> -	
> +
>   	for (i = 0; i < 16; i++) {
>   		pal[i] = i * 0x11111111U;
>   	}
> @@ -96,7 +96,7 @@ static inline void matrox_cfb4_pal(u_int32_t* pal) {
>   
>   static inline void matrox_cfb8_pal(u_int32_t* pal) {
>   	unsigned int i;
> -	
> +
>   	for (i = 0; i < 16; i++) {
>   		pal[i] = i * 0x01010101U;
>   	}
> @@ -482,7 +482,7 @@ static void matroxfb_1bpp_imageblit(struct matrox_fb_info *minfo, u_int32_t fgx,
>   			/* Tell... well, why bother... */
>   			while (height--) {
>   				size_t i;
> -				
> +
>   				for (i = 0; i < step; i += 4) {
>   					/* Hope that there are at least three readable bytes beyond the end of bitmap */
>   					fb_writel(get_unaligned((u_int32_t*)(chardata + i)),mmio.vaddr);
> diff --git a/drivers/video/fbdev/matrox/matroxfb_base.h b/drivers/video/fbdev/matrox/matroxfb_base.h
> index 958be6805f87..c93c69bbcd57 100644
> --- a/drivers/video/fbdev/matrox/matroxfb_base.h
> +++ b/drivers/video/fbdev/matrox/matroxfb_base.h
> @@ -301,9 +301,9 @@ struct matrox_altout {
>   	int		(*verifymode)(void* altout_dev, u_int32_t mode);
>   	int		(*getqueryctrl)(void* altout_dev,
>   					struct v4l2_queryctrl* ctrl);

Noticed that there are plenty of coding style problems in matroxfb_base.h,

why you only fix a few of them?   Take this two line as an example, 
shouldn't

they be fixed also as following?


  	int		(*verifymode)(void *altout_dev, u_int32_t mode);
  	int		(*getqueryctrl)(void *altout_dev,
  					struct v4l2_queryctrl *ctrl);


> -	int		(*getctrl)(void* altout_dev,
> +	int		(*getctrl)(void *altout_dev,
>   				   struct v4l2_control* ctrl);
> -	int		(*setctrl)(void* altout_dev,
> +	int		(*setctrl)(void *altout_dev,
>   				   struct v4l2_control* ctrl);
>   };
>   
