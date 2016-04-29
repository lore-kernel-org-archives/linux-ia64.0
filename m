From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Fri, 29 Apr 2016 18:10:09 +0000
Subject: Re: [PATCH 03/12] ARM: kexec: remove 512MB restriction on kexec crashdump
Message-Id: <20160429181008.GV19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <E1aviEp-0000ir-7s@rmk-PC.arm.linux.org.uk>
 <CAHB_GuqOvRof94QdHztPy2B2kKuyKzQ-9uxXHY_g+i5WxsexZg@mail.gmail.com>
In-Reply-To: <CAHB_GuqOvRof94QdHztPy2B2kKuyKzQ-9uxXHY_g+i5WxsexZg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pratyush Anand <panand-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Haren Myneni <hbabu-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

On Fri, Apr 29, 2016 at 07:49:45PM +0530, Pratyush Anand wrote:
> On Thu, Apr 28, 2016 at 2:57 PM, Russell King
> <rmk+kernel@arm.linux.org.uk> wrote:
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > ---
> >  arch/arm/kernel/setup.c | 5 +----
> >  1 file changed, 1 insertion(+), 4 deletions(-)
> >
> > diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
> > index 77b54c461c52..d9317eec1eba 100644
> > --- a/arch/arm/kernel/setup.c
> > +++ b/arch/arm/kernel/setup.c
> > @@ -943,7 +943,6 @@ late_initcall(init_machine_late);
> >   * zImage relocating below the reserved region.
> >   */
> >  #define CRASH_ALIGN    (128 << 20)
> > -#define CRASH_ADDR_MAX (PHYS_OFFSET + (512 << 20))
> >
> >  static inline unsigned long long get_total_mem(void)
> >  {
> > @@ -973,9 +972,7 @@ static void __init reserve_crashkernel(void)
> >                 return;
> >
> >         if (crash_base <= 0) {
> > -               unsigned long long crash_max = CRASH_ADDR_MAX;
> > -               if (crash_max > (u32)~0)
> > -                       crash_max = (u32)~0;
> > +               unsigned long long crash_max = idmap_to_phys((u32)~0);
> >                 crash_base = memblock_find_in_range(CRASH_ALIGN, crash_max,
> >                                                     crash_size, CRASH_ALIGN);
> >                 if (!crash_base) {
> 
> Reviewed-by: Pratyush Anand <panand@redhat.com>
> 
> Unrelated to these modification:
> In function arch/arm/mm/init.c: arm_memblock_steal() may be  following
> would be more appropriate?
> memblock_alloc_base(size, align, idmap_to_phys(MEMBLOCK_ALLOC_ANYWHERE));

No, arm_memblock_steal() is totally unsuitable.  arm_memblock_steal()
*removes* the memory range from memblock, including removing the 
mapping of that memory.  It will make the memory range inaccessible to
the kernel.

Since kexec wants to write directly to this memory, using
arm_memblock_steal() will have the cause the kernel to OOPS when
it hits the resulting hole.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
