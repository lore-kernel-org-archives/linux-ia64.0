From: Sam Ravnborg <sam@ravnborg.org>
Date: Wed, 26 Apr 2023 19:21:10 +0000
Subject: Re: [PATCH 0/5] fbdev: Move framebuffer I/O helpers to <asm/fb.h>
Message-Id: <20230426192110.GA3791243@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230426130420.19942-1-tzimmermann@suse.de>
In-Reply-To: <20230426130420.19942-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas.

On Wed, Apr 26, 2023 at 03:04:15PM +0200, Thomas Zimmermann wrote:
> Fbdev provides helpers for framebuffer I/O, such as fb_readl(),
> fb_writel() or fb_memcpy_to_fb(). The implementation of each helper
> depends on the architecture. It's still all located in fbdev's main
> header file <linux/fb.h>. Move all of it into each archtecture's
> <asm/fb.h>, with shared code in <asm-generic/fb.h>.

For once I think this cleanup is moving things in the wrong direction.

The fb_* helpers predates the generic io.h support and try to
add a generic layer for read read / write operations.

The right fix would be to migrate fb_* to use the io helpers
we have today - so we use the existing way to handle the architecture
specific details.

From a quick look there seems to be some challenges but the current
helpers that re-do part of io.h is not the way forward and hiding them
in arch/include/asm/fb.h seems counter productive.

	Sam
