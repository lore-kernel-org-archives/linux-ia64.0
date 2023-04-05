From: "Arnd Bergmann" <arnd@arndb.de>
Date: Wed, 05 Apr 2023 15:53:03 +0000
Subject: Re: [PATCH 01/18] fbdev: Prepare generic architecture helpers
Message-Id: <92fe3838-41f0-4e27-8467-161553ff724f@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230405150554.30540-1-tzimmermann@suse.de>
 <20230405150554.30540-2-tzimmermann@suse.de>
In-Reply-To: <20230405150554.30540-2-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Daniel Vetter <daniel.vetter@ffwll.ch>, Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Wed, Apr 5, 2023, at 17:05, Thomas Zimmermann wrote:
> Generic implementations of fb_pgprotect() and fb_is_primary_device()
> have been in the source code for a long time. Prepare the header file
> to make use of them.
>
> Improve the code by using an inline function for fb_pgprotect() and
> by removing include statements.
>
> Symbols are protected by preprocessor guards. Architectures that
> provide a symbol need to define a preprocessor token of the same
> name and value. Otherwise the header file will provide a generic
> implementation. This pattern has been taken from <asm/io.h>.
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>

Moving this into generic code is good, but I'm not sure
about the default for fb_pgprotect():

> +
> +#ifndef fb_pgprotect
> +#define fb_pgprotect fb_pgprotect
> +static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
> +				unsigned long off)
> +{ }
> +#endif

I think most architectures will want the version we have on
arc, arm, arm64, loongarch, and sh already:

static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
                                unsigned long off)
{
       vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
}

so I'd suggest making that version the default, and treating the
empty ones (m68knommu, sparc32) as architecture specific
workarounds.

I see that sparc64 and parisc use pgprot_uncached here, but as
they don't define a custom pgprot_writecombine, this ends up being
the same, and they can use the above definition as well.

mips defines pgprot_writecombine but uses pgprot_noncached
in fb_pgprotect(), which is probably a mistake and should have
been updated as part of commit 4b050ba7a66c ("MIPS: pgtable.h:
Implement the pgprot_writecombine function for MIPS").

    Arnd
