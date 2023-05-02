From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 02 May 2023 20:03:00 +0000
Subject: Re: [PATCH v3 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <20230502200300.GB319489@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de>
 <20230502130223.14719-6-tzimmermann@suse.de>
In-Reply-To: <20230502130223.14719-6-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas,

On Tue, May 02, 2023 at 03:02:22PM +0200, Thomas Zimmermann wrote:
> Implement framebuffer I/O helpers, such as fb_read*() and fb_write*(),
> in the architecture's <asm/fb.h> header file or the generic one.

In reality they are now all implemented in the generic one.

> 
> The common case has been the use of regular I/O functions, such as
> __raw_readb() or memset_io(). A few architectures used plain system-
> memory reads and writes. Sparc used helpers for its SBus.
> 
> The architectures that used special cases provide the same code in
> their __raw_*() I/O helpers. So the patch replaces this code with the
> __raw_*() functions and moves it to <asm-generic/fb.h> for all
> architectures.
Which is also documented here.

> 
> v3:
> 	* implement all architectures with generic helpers
> 	* support reordering and native byte order (Geert, Arnd)
> 
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> ---
>  include/asm-generic/fb.h | 101 +++++++++++++++++++++++++++++++++++++++
>  include/linux/fb.h       |  53 --------------------
>  2 files changed, 101 insertions(+), 53 deletions(-)
> 
> diff --git a/include/asm-generic/fb.h b/include/asm-generic/fb.h
> index 6922dd248c51..0540eccdbeca 100644
> --- a/include/asm-generic/fb.h
> +++ b/include/asm-generic/fb.h
> @@ -31,4 +31,105 @@ static inline int fb_is_primary_device(struct fb_info *info)
>  }
>  #endif
>  
> +/*
> + * I/O helpers for the framebuffer. Prefer these functions over their
> + * regular counterparts. The regular I/O functions provide in-order
> + * access and swap bytes to/from little-endian ordering. Neither is
> + * required for framebuffers. Instead, the helpers read and write
> + * raw framebuffer data. Independent operations can be reordered for
> + * improved performance.
> + */
> +
> +#ifndef fb_readb
> +static inline u8 fb_readb(const volatile void __iomem *addr)
> +{
> +	return __raw_readb(addr);
> +}
> +#define fb_readb fb_readb
> +#endif

When we need to provide an architecture specific variant the
#ifndef foo
...
#define foo foo
can be added. Right now it is just noise as no architectures provide
their own variants.

But I am missing something somewhere as I cannot see how this builds.
asm-generic now provide the fb_read/fb_write helpers.
But for example sparc has an architecture specifc fb.h so it will not
use the asm-generic variant. So I wonder how sparc get hold of the
asm-generic fb.h file?

Maybe it is obvious, but I miss it.

	Sam
