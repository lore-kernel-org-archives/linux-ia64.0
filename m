From: Sui Jingfeng <15330273260@189.cn>
Date: Thu, 04 May 2023 11:30:15 +0000
Subject: Re: [v4,2/6] ipu-v3: Include <linux/io.h>
Message-Id: <4c3444e2-390b-8c9e-e136-bf888fccd10f@189.cn>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230504074539.8181-3-tzimmermann@suse.de>
In-Reply-To: <20230504074539.8181-3-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@HansenPartnership.com, arnd@arndb.de, sam@ravnborg.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org


Reviewed-by: Sui Jingfeng <suijingfeng@loongson.cn>


On 2023/5/4 15:45, Thomas Zimmermann wrote:
> The code uses readl() and writel(). Include the header file to
> get the declarations.
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
> ---
>   drivers/gpu/ipu-v3/ipu-prv.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/gpu/ipu-v3/ipu-prv.h b/drivers/gpu/ipu-v3/ipu-prv.h
> index 291ac1bab66d..d4621b1ea7f1 100644
> --- a/drivers/gpu/ipu-v3/ipu-prv.h
> +++ b/drivers/gpu/ipu-v3/ipu-prv.h
> @@ -8,6 +8,7 @@
>   
>   struct ipu_soc;
>   
> +#include <linux/io.h>
>   #include <linux/types.h>
>   #include <linux/device.h>
>   #include <linux/clk.h>
