From: "Arnd Bergmann" <arnd@arndb.de>
Date: Thu, 06 Apr 2023 14:43:56 +0000
Subject: Re: [PATCH v2 02/19] arch/arc: Implement <asm/fb.h> with generic helpers
Message-Id: <27c1210f-4e40-4bbc-905b-155427465e00@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de>
 <20230406143019.6709-3-tzimmermann@suse.de>
In-Reply-To: <20230406143019.6709-3-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Daniel Vetter <daniel.vetter@ffwll.ch>, Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Vineet Gupta <vgupta@kernel.org>

On Thu, Apr 6, 2023, at 16:30, Thomas Zimmermann wrote:
> +
>  static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
>  				unsigned long off)
>  {
>  	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
>  }
> +#define fb_pgprotect fb_pgprotect

I still feel that for architectures like arc that don't have
pgprot_writecombine(), it would b best to go with the
generic implementation that currently behaves the exact
same way. If pgprot_writecombine() gets added in the future,
it would cause the architecture to behave as expected rather
than introducing the same bug that mips has.

      Arnd
