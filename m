From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 27 Apr 2023 17:17:29 +0000
Subject: Re: [PATCH 0/5] fbdev: Move framebuffer I/O helpers to <asm/fb.h>
Message-Id: <20230427171729.GA3899979@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230426130420.19942-1-tzimmermann@suse.de>
 <20230426192110.GA3791243@ravnborg.org>
 <3e33ab1d-b478-fdf5-6fbe-6580000182d1@suse.de>
In-Reply-To: <3e33ab1d-b478-fdf5-6fbe-6580000182d1@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas,

On Thu, Apr 27, 2023 at 09:22:47AM +0200, Thomas Zimmermann wrote:
> Hi Sam
> 
> Am 26.04.23 um 21:21 schrieb Sam Ravnborg:
> > Hi Thomas.
> > 
> > On Wed, Apr 26, 2023 at 03:04:15PM +0200, Thomas Zimmermann wrote:
> > > Fbdev provides helpers for framebuffer I/O, such as fb_readl(),
> > > fb_writel() or fb_memcpy_to_fb(). The implementation of each helper
> > > depends on the architecture. It's still all located in fbdev's main
> > > header file <linux/fb.h>. Move all of it into each archtecture's
> > > <asm/fb.h>, with shared code in <asm-generic/fb.h>.
> > 
> > For once I think this cleanup is moving things in the wrong direction.
> > 
> > The fb_* helpers predates the generic io.h support and try to
> > add a generic layer for read read / write operations.
> > 
> > The right fix would be to migrate fb_* to use the io helpers
> > we have today - so we use the existing way to handle the architecture
> > specific details.
> 
> I looked through the existing versions of the fb_() I/O helpers. They can
> apparently be implemented with the regular helpers of similar names.
> 
> I'm not sure, but even Sparc looks compatible. At least these sbus_
> functions seem to be equivalent to the __raw_() I/O helpers of similar
> names.

> Do you still have that Sparc emulator?
I used qemu the last time I played with sparc and saved the instructions
somewhere how to redo it - but that would use to bohcs driver only I think.
I have saprc machines, but none of these are easy to get operational.
We can always ask on sparclinux to get some testing feedback.

> 
> > 
> >  From a quick look there seems to be some challenges but the current
> > helpers that re-do part of io.h is not the way forward and hiding them
> > in arch/include/asm/fb.h seems counter productive.
> 
> Which challenges did you see?
sparc was the main thing - but maybe I did not look close enough.
And then I tried to map the macros to some of the more highlevel ones
from io.h, but as Arnd says the __raw* is the way to go here.

	Sam
