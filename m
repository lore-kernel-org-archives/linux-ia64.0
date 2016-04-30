From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sat, 30 Apr 2016 08:25:47 +0000
Subject: Re: [PATCH 03/12] ARM: kexec: remove 512MB restriction on kexec crashdump
Message-Id: <20160430082547.GH19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <E1aviEp-0000ir-7s@rmk-PC.arm.linux.org.uk>
 <CAHB_GuqOvRof94QdHztPy2B2kKuyKzQ-9uxXHY_g+i5WxsexZg@mail.gmail.com>
 <20160429181008.GV19428@n2100.arm.linux.org.uk>
 <CAHB_GuoQM9dzgyd+67QPOReLW4HYNqyuzKGzB7Fzq=dpWYHf_w@mail.gmail.com>
In-Reply-To: <CAHB_GuoQM9dzgyd+67QPOReLW4HYNqyuzKGzB7Fzq=dpWYHf_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pratyush Anand <panand@redhat.com>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Sat, Apr 30, 2016 at 09:06:19AM +0530, Pratyush Anand wrote:
> On Fri, Apr 29, 2016 at 11:40 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > On Fri, Apr 29, 2016 at 07:49:45PM +0530, Pratyush Anand wrote:
> >> On Thu, Apr 28, 2016 at 2:57 PM, Russell King
> >> <rmk+kernel@arm.linux.org.uk> wrote:
> >> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> >> > ---
> >> >  arch/arm/kernel/setup.c | 5 +----
> >> >  1 file changed, 1 insertion(+), 4 deletions(-)
> >> >
> >> > diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
> >> > index 77b54c461c52..d9317eec1eba 100644
> >> > --- a/arch/arm/kernel/setup.c
> >> > +++ b/arch/arm/kernel/setup.c
> >> > @@ -943,7 +943,6 @@ late_initcall(init_machine_late);
> >> >   * zImage relocating below the reserved region.
> >> >   */
> >> >  #define CRASH_ALIGN    (128 << 20)
> >> > -#define CRASH_ADDR_MAX (PHYS_OFFSET + (512 << 20))
> >> >
> >> >  static inline unsigned long long get_total_mem(void)
> >> >  {
> >> > @@ -973,9 +972,7 @@ static void __init reserve_crashkernel(void)
> >> >                 return;
> >> >
> >> >         if (crash_base <= 0) {
> >> > -               unsigned long long crash_max = CRASH_ADDR_MAX;
> >> > -               if (crash_max > (u32)~0)
> >> > -                       crash_max = (u32)~0;
> >> > +               unsigned long long crash_max = idmap_to_phys((u32)~0);
> >> >                 crash_base = memblock_find_in_range(CRASH_ALIGN, crash_max,
> >> >                                                     crash_size, CRASH_ALIGN);
> >> >                 if (!crash_base) {
> >>
> >> Reviewed-by: Pratyush Anand <panand@redhat.com>
> >>
> >> Unrelated to these modification:
> >> In function arch/arm/mm/init.c: arm_memblock_steal() may be  following
> >> would be more appropriate?
> >> memblock_alloc_base(size, align, idmap_to_phys(MEMBLOCK_ALLOC_ANYWHERE));
> >
> > No, arm_memblock_steal() is totally unsuitable.  arm_memblock_steal()
> > *removes* the memory range from memblock, including removing the
> > mapping of that memory.  It will make the memory range inaccessible to
> > the kernel.
> >
> > Since kexec wants to write directly to this memory, using
> > arm_memblock_steal() will have the cause the kernel to OOPS when
> > it hits the resulting hole.
> >
> 
> Sorry, I was not trying to say that we should use arm_memblock_steal()
> here. As I said, this comment is totally unrelated to this patch
> series. In arm_memblock_steal() we pass MEMBLOCK_ALLOC_ANYWHERE as
> max_addr. Probably,  it would be good to pass
> idmap_to_phys(MEMBLOCK_ALLOC_ANYWHERE).

No.

	idmap_to_phys((u32)~0)

This returns the maximum running-view physical address that corresponds
with the top of the boot-view physical address space.  That's exactly
what we want, not "any physical address".  In any case,
MEMBLOCK_ALLOC_ANYWHERE is a 64-bit physical address consisting of all-
ones.  The compiler will truncate it down to a 32-bit address due to
idmap_to_phys()'s prototype, but that's really not the point - it's the
wrong constant to be used here.  This isn't a memblock function, and
it shouldn't be passed a 64-bit address.

The difference is that arm_memblock_steal() is about stealing memory
from the system which can be allocated in the running-view.  It's got
nothing to do with boot-view stuff.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
