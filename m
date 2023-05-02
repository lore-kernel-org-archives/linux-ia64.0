From: "Arnd Bergmann" <arnd@arndb.de>
Date: Tue, 02 May 2023 20:06:10 +0000
Subject: Re: [PATCH v3 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <67d6a188-041f-4604-99a3-548c41af0693@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de>
 <20230502130223.14719-6-tzimmermann@suse.de>
In-Reply-To: <20230502130223.14719-6-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Helge Deller <deller@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Sam Ravnborg <sam@ravnborg.org>
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On Tue, May 2, 2023, at 15:02, Thomas Zimmermann wrote:
> Implement framebuffer I/O helpers, such as fb_read*() and fb_write*(),
> in the architecture's <asm/fb.h> header file or the generic one.
>
> The common case has been the use of regular I/O functions, such as
> __raw_readb() or memset_io(). A few architectures used plain system-
> memory reads and writes. Sparc used helpers for its SBus.
>
> The architectures that used special cases provide the same code in
> their __raw_*() I/O helpers. So the patch replaces this code with the
> __raw_*() functions and moves it to <asm-generic/fb.h> for all
> architectures.
>
> v3:
> 	* implement all architectures with generic helpers
> 	* support reordering and native byte order (Geert, Arnd)

This looks good for the read/write helpers, but I'm a little
worried about the memset and memcpy functions, since they do
change behavior on some architectures:

- on sparc64, fb_mem{set,cpy} uses ASI_PHYS_BYPASS_EC_E (like __raw_readb)
  while mem{set_,cpy_from,cpy_to} uses ASI_PHYS_BYPASS_EC_E_L (like readb)
  I don't know the effect of that, but it seems intentional

- on loongarch and csky, the _io variants avoid unaligned access,
  while the normal memcpy/memset is probably broken, so your
  patch is a bugfix

- on ia64, the _io variants use bytewise access and avoid any longer
  loads and stores, so your patch probably makes things slower.

It's probably safe to deal with all the above by either adding
architecture specific overrides to the current version, or
by doing the semantic changes before the move to asm/fb.h, but
one way or the other I'd prefer this to be separate from the
consolidation patch that should not have any changes in behavior.

     Arnd
