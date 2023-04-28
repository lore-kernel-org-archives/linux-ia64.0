From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 28 Apr 2023 13:13:33 +0000
Subject: Re: [PATCH v2 0/5] fbdev: Use regular I/O function for framebuffers
Message-Id: <20230428131333.GF3995435@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
In-Reply-To: <20230428092711.406-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org

Hi Thomas,

On Fri, Apr 28, 2023 at 11:27:06AM +0200, Thomas Zimmermann wrote:
> (was: fbdev: Move framebuffer I/O helpers to <asm/fb.h>)
> 
> Fbdev provides helpers for framebuffer I/O, such as fb_readl(),
> fb_writel() or fb_memcpy_to_fb(). The implementation of each helper
> depends on the architecture, but they all come down to regular I/O
> functions of similar names. So use the regular functions instead.
> 
> The first patch a simple whitespace cleanup.
> 
> Until now, <linux/fb.h> contained an include of <asm/io.h>. As this
> will go away patches 2 to 4 prepare include statements in the various
> drivers. Source files that use regular I/O helpers, such as readl(),
> now include <linux/io.h>. Source files that use framebuffer I/O
> helpers, such as fb_readl(), also include <linux/io.h>.
> 
> Patch 5 replaces the architecture-based if-else branching in 
> <linux/fb.h> by define statements that map to Linux' I/O fucntions.
> 
> After this change has been merged and included in a few release
> without complains, we can update the drivers to regular I/O functions
> and remove the fbdev-specific defines.
> 
> The patchset has been built for a variety of platforms, such as x86-64,
> arm, aarch64, ppc64, parisc, m64k, mips and sparc.
> 
> v2:
> 	* use Linux I/O helpers (Sam, Arnd)
Much better, thanks!

	Sam
