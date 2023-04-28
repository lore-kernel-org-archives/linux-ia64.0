From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 28 Apr 2023 13:07:02 +0000
Subject: Re: [PATCH v2 4/5] fbdev: Include <linux/io.h> in drivers
Message-Id: <20230428130702.GD3995435@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-5-tzimmermann@suse.de>
In-Reply-To: <20230428092711.406-5-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On Fri, Apr 28, 2023 at 11:27:10AM +0200, Thomas Zimmermann wrote:
> Fbdev's main header file, <linux/fb.h>, includes <asm/io.h> to get
> declarations of I/O helper functions. From these declaratons, it later
> defines framebuffer I/O helpers, such as fb_{read,write}[bwlq]() or
> fb_memset().
> 
> The framebuffer I/O helpers pre-date Linux' current I/O code and will
> be replaced by regular I/O helpers. Prepare this change by adding an
> include statement for <linux/io.h> to all source files that use the
> framebuffer I/O helpers. They will still get declarations of the I/O
> functions even after <linux/fb.h> has been cleaned up.
When fb.h uses a symbol from io.h, then it shall include that
file so it is self contained.
So it is wrong to push the io.h include to the users of
fb_{read,write,xxx}. Maybe fb.h only uses macros as is the case here,
but that is no excuse nt to include io.h.

Drop these changes.

> Driver source
> files that already include <asm/io.h> convert to <linux/io.h>.
This is a nice cleanup - we should keep that.

	Sam
