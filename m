From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 28 Apr 2023 13:01:04 +0000
Subject: Re: [PATCH v2 2/5] ipu-v3: Include <linux/io.h>
Message-Id: <20230428130104.GB3995435@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-3-tzimmermann@suse.de>
In-Reply-To: <20230428092711.406-3-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On Fri, Apr 28, 2023 at 11:27:08AM +0200, Thomas Zimmermann wrote:
> The code uses readl() and writel(). Include the header file to
> get the declarations.
> 
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
> ---
>  drivers/gpu/ipu-v3/ipu-prv.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/gpu/ipu-v3/ipu-prv.h b/drivers/gpu/ipu-v3/ipu-prv.h
> index 291ac1bab66d..d4621b1ea7f1 100644
> --- a/drivers/gpu/ipu-v3/ipu-prv.h
> +++ b/drivers/gpu/ipu-v3/ipu-prv.h
> @@ -8,6 +8,7 @@
>  
>  struct ipu_soc;
>  
> +#include <linux/io.h>
>  #include <linux/types.h>
>  #include <linux/device.h>
>  #include <linux/clk.h>
> -- 
> 2.40.0
