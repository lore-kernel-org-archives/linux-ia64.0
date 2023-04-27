From: "Arnd Bergmann" <arnd@arndb.de>
Date: Thu, 27 Apr 2023 10:20:32 +0000
Subject: Re: [PATCH 0/5] fbdev: Move framebuffer I/O helpers to <asm/fb.h>
Message-Id: <173a9a6c-d47d-487c-b61a-66d021548f5a@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230426130420.19942-1-tzimmermann@suse.de>
 <20230426192110.GA3791243@ravnborg.org>
 <3e33ab1d-b478-fdf5-6fbe-6580000182d1@suse.de>
In-Reply-To: <3e33ab1d-b478-fdf5-6fbe-6580000182d1@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Sam Ravnborg <sam@ravnborg.org>
Cc: Helge Deller <deller@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On Thu, Apr 27, 2023, at 08:22, Thomas Zimmermann wrote:
> Am 26.04.23 um 21:21 schrieb Sam Ravnborg:
>> On Wed, Apr 26, 2023 at 03:04:15PM +0200, Thomas Zimmermann wrote:
>>> Fbdev provides helpers for framebuffer I/O, such as fb_readl(),
>>> fb_writel() or fb_memcpy_to_fb(). The implementation of each helper
>>> depends on the architecture. It's still all located in fbdev's main
>>> header file <linux/fb.h>. Move all of it into each archtecture's
>>> <asm/fb.h>, with shared code in <asm-generic/fb.h>.
>> 
>> For once I think this cleanup is moving things in the wrong direction.
>> 
>> The fb_* helpers predates the generic io.h support and try to
>> add a generic layer for read read / write operations.
>> 
>> The right fix would be to migrate fb_* to use the io helpers
>> we have today - so we use the existing way to handle the architecture
>> specific details.
>
> I looked through the existing versions of the fb_() I/O helpers. They 
> can apparently be implemented with the regular helpers of similar names.
>
> I'm not sure, but even Sparc looks compatible. At least these sbus_ 
> functions seem to be equivalent to the __raw_() I/O helpers of similar 
> names. Do you still have that Sparc emulator?

I looked at the current code and came to the same conclusion: all
architectures we support today do the same thing in __raw_readl()
and fb_readl() etc, so we can completely remove the latter without
changing semantics.

I think the original list was necessary since not all architectures
supported the __raw_ accessors in the past, so they were open-coded
here for the rest. I thought there were also architectures on which
__raw_readl() does a byteswap to reverse the swap done in a PCI
host bridge, but it apears that none of those remain now, if we ever
had them.

     Arnd
