From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 17 Apr 2023 14:13:33 +0000
Subject: Re: [PATCH v3 16/19] arch/sh: Implement <asm/fb.h> with generic helpers
Message-Id: <0b07fbadce4512e4696750cf69cf3fbbf38355a3.camel@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230417125651.25126-1-tzimmermann@suse.de>
	 <20230417125651.25126-17-tzimmermann@suse.de>
	 <3c188e948506dc97112dcc070cf16e36209c6cc5.camel@physik.fu-berlin.de>
	 <132f1185-d61f-b8c7-8d6e-4e4280a1a4ad@suse.de>
In-Reply-To: <132f1185-d61f-b8c7-8d6e-4e4280a1a4ad@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>

Hi Thomas!

On Mon, 2023-04-17 at 16:06 +0200, Thomas Zimmermann wrote:
> Hi
> 
> Am 17.04.23 um 15:02 schrieb John Paul Adrian Glaubitz:
> > Hi Thomas!
> > 
> > On Mon, 2023-04-17 at 14:56 +0200, Thomas Zimmermann wrote:
> > > Replace the architecture's fbdev helpers with the generic
> > > ones from <asm-generic/fb.h>. No functional changes.
> > > 
> > > v2:
> > > 	* use default implementation for fb_pgprotect() (Arnd)
> > > 
> > > Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> > > Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> > > Cc: Rich Felker <dalias@libc.org>
> > > Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> > > ---
> > >   arch/sh/include/asm/fb.h | 15 +--------------
> > >   1 file changed, 1 insertion(+), 14 deletions(-)
> > > 
> > > diff --git a/arch/sh/include/asm/fb.h b/arch/sh/include/asm/fb.h
> > > index 9a0bca2686fd..19df13ee9ca7 100644
> > > --- a/arch/sh/include/asm/fb.h
> > > +++ b/arch/sh/include/asm/fb.h
> > > @@ -2,19 +2,6 @@
> > >   #ifndef _ASM_FB_H_
> > >   #define _ASM_FB_H_
> > >   
> > > -#include <linux/fb.h>
> > > -#include <linux/fs.h>
> > > -#include <asm/page.h>
> > > -
> > > -static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
> > > -				unsigned long off)
> > > -{
> > > -	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
> > > -}
> > 
> > Looking at the macro in asm-generic/fb.h, fb_pgprotect() is being replaced with
> > a no-op function. Is that intentional? Can you briefly explain the background
> > for this change?
> 
> Patch 01 of this patchset changes the generic fb_pgprotect() to set 
> pgprot_writecombine(). So on SH, there should be no change at all.
> 

Ah, I missed that, thanks for the explanation. Let me check and Ack your patch
then. I assume you will be taking this patch as part of the whole series through
your own tree?

Thanks,
Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer
`. `'   Physicist
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
