From: "Arnd Bergmann" <arnd@arndb.de>
Date: Thu, 06 Apr 2023 14:51:14 +0000
Subject: Re: [PATCH v2 09/19] arch/mips: Implement <asm/fb.h> with generic helpers
Message-Id: <cfa36e9a-7e19-4c43-b9b4-1ae4f9ef51c3@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de>
 <20230406143019.6709-10-tzimmermann@suse.de>
In-Reply-To: <20230406143019.6709-10-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Daniel Vetter <daniel.vetter@ffwll.ch>, Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Thomas Bogendoerfer <tsbogend@alpha.franken.de>

On Thu, Apr 6, 2023, at 16:30, Thomas Zimmermann wrote:
> Replace the architecture's fb_is_primary_device() with the generic
> one from <asm-generic/fb.h>. No functional changes.
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

I think you should at least mention that the existing
fb_pgprotect() function is probably incorrect and should
be replaced with the generic version.

For reference, the fb_pgprotect function using pgprot_uncached()
was introduced in 2.6.22 along with all the other ones, but
the pgprot_writecombine function was only added in commit
4b050ba7a66c ("MIPS: pgtable.h: Implement the pgprot_writecombine
function for MIPS") for 3.18.

     Arnd
