From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 12 Apr 2023 06:17:59 +0000
Subject: Re: [PATCH v2 15/19] arch/powerpc: Implement <asm/fb.h> with generic helpers
Message-Id: <87r0spipyg.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de>
 <20230406143019.6709-16-tzimmermann@suse.de>
In-Reply-To: <20230406143019.6709-16-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Thomas Zimmermann <tzimmermann@suse.de>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>

Thomas Zimmermann <tzimmermann@suse.de> writes:
> Replace the architecture's fb_is_primary_device() with the generic
> one from <asm-generic/fb.h>. No functional changes.
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/powerpc/include/asm/fb.h | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)

Looks fine.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

> diff --git a/arch/powerpc/include/asm/fb.h b/arch/powerpc/include/asm/fb.h
> index 6541ab77c5b9..5f1a2e5f7654 100644
> --- a/arch/powerpc/include/asm/fb.h
> +++ b/arch/powerpc/include/asm/fb.h
> @@ -2,8 +2,8 @@
>  #ifndef _ASM_FB_H_
>  #define _ASM_FB_H_
>  
> -#include <linux/fb.h>
>  #include <linux/fs.h>
> +
>  #include <asm/page.h>
>  
>  static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
> @@ -13,10 +13,8 @@ static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
>  						 vma->vm_end - vma->vm_start,
>  						 vma->vm_page_prot);
>  }
> +#define fb_pgprotect fb_pgprotect
>  
> -static inline int fb_is_primary_device(struct fb_info *info)
> -{
> -	return 0;
> -}
> +#include <asm-generic/fb.h>
>  
>  #endif /* _ASM_FB_H_ */
> -- 
> 2.40.0
