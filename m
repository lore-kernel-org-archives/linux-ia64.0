From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 02 May 2023 19:54:29 +0000
Subject: Re: [PATCH v3 4/6] fbdev: Include <linux/io.h> via <asm/fb.h>
Message-Id: <20230502195429.GA319489@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de>
 <20230502130223.14719-5-tzimmermann@suse.de>
In-Reply-To: <20230502130223.14719-5-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas,

On Tue, May 02, 2023 at 03:02:21PM +0200, Thomas Zimmermann wrote:
> Fbdev's main header file, <linux/fb.h>, includes <asm/io.h> to get
> declarations for I/O helper functions. From these declarations, it
> later defines framebuffer I/O helpers, such as fb_{read,write}[bwlq]()
> or fb_memset().
> 
> The framebuffer I/O helpers depend on the system architecture and
> will therefore be moved into <asm/fb.h>. Prepare this change by first
> adding an include statement for <linux/io.h> to <asm-generic/fb.h>.
> Include <asm/fb.h> in all source files that use the framebuffer I/O
> helpers, so that they still get the necessary I/O functions.
> 
...
> 
> diff --git a/drivers/video/fbdev/arkfb.c b/drivers/video/fbdev/arkfb.c
> index 60a96fdb5dd8..fd38e8a073b8 100644
> --- a/drivers/video/fbdev/arkfb.c
> +++ b/drivers/video/fbdev/arkfb.c
> @@ -27,6 +27,8 @@
>  #include <linux/console.h> /* Why should fb driver call console functions? because console_lock() */
>  #include <video/vga.h>
>  
> +#include <asm/fb.h>

When we have a header like linux/fb.h - it is my understanding that it is
preferred to include that file, and not the asm/fb.h variant.

This is assuming the linux/fb.h contains the generic stuff, and includes
asm/fb.h for the architecture specific parts.

So drivers will include linux/fb.h and then they automatically get the
architecture specific parts from asm/fb.h.

In other words, drivers are not supposed to include asm/fb.h, if
linux.fb.h exists - and linux/fb.h shall include the asm/fb.h.

If the above holds true, then it is wrong and not needed to add asm/fb.h
as seen above.


There are countless examples where the above are not followed,
but to my best understanding the above it the preferred way to do it.

	Sam
