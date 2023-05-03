From: Sam Ravnborg <sam@ravnborg.org>
Date: Wed, 03 May 2023 19:06:17 +0000
Subject: Re: [PATCH v3 6/6] fbdev: Rename fb_mem*() helpers
Message-Id: <20230503190617.GB422961@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de>
 <20230502130223.14719-7-tzimmermann@suse.de>
 <20230502200813.GC319489@ravnborg.org>
 <828664d0-3562-56cc-019d-1bb8a55826b5@suse.de>
In-Reply-To: <828664d0-3562-56cc-019d-1bb8a55826b5@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas,

On Wed, May 03, 2023 at 10:15:46AM +0200, Thomas Zimmermann wrote:
> Hi
> 
> Am 02.05.23 um 22:08 schrieb Sam Ravnborg:
> > Hi Thomas.
> > 
> > On Tue, May 02, 2023 at 03:02:23PM +0200, Thomas Zimmermann wrote:
> > > Update the names of the fb_mem*() helpers to be consistent with their
> > > regular counterparts. Hence, fb_memset() now becomes fb_memset_io(),
> > > fb_memcpy_fromfb() now becomes fb_memcpy_fromio() and fb_memcpy_tofb()
> > > becomes fb_memcpy_toio(). No functional changes.
> > > 
> > > Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> > > ---
> > ...
> > > -#ifndef fb_memcpy_fromfb
> > > -static inline void fb_memcpy_fromfb(void *to, const volatile void __iomem *from, size_t n)
> > > +#ifndef fb_memcpy_fromio
> > > +static inline void fb_memcpy_fromio(void *to, const volatile void __iomem *from, size_t n)
> > >   {
> > >   	memcpy_fromio(to, from, n);
> > >   }
> > > -#define fb_memcpy_fromfb fb_memcpy_fromfb
> > > +#define fb_memcpy_fromio fb_memcpy_fromio
> > >   #endif
> > > -#ifndef fb_memcpy_tofb
> > > -static inline void fb_memcpy_tofb(volatile void __iomem *to, const void *from, size_t n)
> > > +#ifndef fb_memcpy_toio
> > > +static inline void fb_memcpy_toio(volatile void __iomem *to, const void *from, size_t n)
> > >   {
> > >   	memcpy_toio(to, from, n);
> > >   }
> > > -#define fb_memcpy_tofb fb_memcpy_tofb
> > > +#define fb_memcpy_toio fb_memcpy_toio
> > >   #endif
> > >   #ifndef fb_memset
> > > -static inline void fb_memset(volatile void __iomem *addr, int c, size_t n)
> > > +static inline void fb_memset_io(volatile void __iomem *addr, int c, size_t n)
> > >   {
> > >   	memset_io(addr, c, n);
> > >   }
> > > -#define fb_memset fb_memset
> > > +#define fb_memset fb_memset_io
> > 
> > The static inlines wrappers does not provide any value, and could be replaced by
> > direct calls to memcpy_fromio(), memcpy_toio(), memset_io().
> > 
> > If you decide to keep the wrappers I will not hold you back, so the
> > patch has my:
> > Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
> > 
> > But I prefer the direct calls without the wrappers....
> 
> At first I was also skeptical if those fb_mem*() wrappers are needed. But
> Arnd mentioned that there are subtle differences between the current code
> and Linux' mem*_io() functions. Keeping the wrappers might be needed.
Saw the dialog, and agree that keeping current behaviour is the way to
go for now even if this is more code and wrappers.

	Sam
