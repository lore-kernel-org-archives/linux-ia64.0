From: Sam Ravnborg <sam@ravnborg.org>
Date: Wed, 03 May 2023 19:03:17 +0000
Subject: Re: [PATCH v3 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <20230503190317.GA422961@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de>
 <20230502130223.14719-6-tzimmermann@suse.de>
 <20230502200300.GB319489@ravnborg.org>
 <df767237-2bae-f299-9cbb-1543f76c9c3a@suse.de>
In-Reply-To: <df767237-2bae-f299-9cbb-1543f76c9c3a@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, arnd@arndb.de, deller@gmx.de, chenhuacai@kernel.org, javierm@redhat.com, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, linux-m68k@lists.linux-m68k.org, geert@linux-m68k.org, linux-parisc@vger.kernel.org, vgupta@kernel.org, sparclinux@vger.kernel.org, kernel@xen0n.name, linux-snps-arc@lists.infradead.org, davem@davemloft.net, linux-arm-kernel@lists.infradead.org

Hi Thomas,

> > But I am missing something somewhere as I cannot see how this builds.
> > asm-generic now provide the fb_read/fb_write helpers.
> > But for example sparc has an architecture specifc fb.h so it will not
> > use the asm-generic variant. So I wonder how sparc get hold of the
> > asm-generic fb.h file?
> 
> All architecture's <asm/fb.h> files include <asm-generic/fb.h>, so that they
> all get the interfaces which they don't define themselves. For Sparc, this
> is at [1].
> 
> Best regards
> Thomas
> 
> 
> [1]
> https://cgit.freedesktop.org/drm/drm-tip/tree/arch/sparc/include/asm/fb.h#n19
> 
> > 
> > Maybe it is obvious, but I miss it.

OK, it was obvious and I missed it.
I looked at the mainline kernel, and not the drm-tip variant.
Sorry for the noise.

	Sam
