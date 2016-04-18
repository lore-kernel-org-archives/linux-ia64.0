From: Baoquan He <bhe@redhat.com>
Date: Mon, 18 Apr 2016 10:32:58 +0000
Subject: Re: [PATCH 3/3] kexec: arrange for paddr_vmcoreinfo_note() to return phys_addr_t
Message-Id: <20160418103258.GE3602@x1.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160414195938.GV19428@n2100.arm.linux.org.uk>
 <E1aqnQy-0001U9-SR@rmk-PC.arm.linux.org.uk>
 <20160418053820.GC3602@x1.redhat.com>
 <20160418083601.GY19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160418083601.GY19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org

On 04/18/16 at 09:36am, Russell King - ARM Linux wrote:
> On Mon, Apr 18, 2016 at 01:38:20PM +0800, Baoquan He wrote:
> > On 04/14/16 at 09:00pm, Russell King wrote:
> > > On PAE systems (eg, ARM LPAE) the vmcore note may be located above
> > > 4GB physical on 32-bit architectures, so we need a wider type than
> > > "unsigned long" here.  Arrange for paddr_vmcoreinfo_note() to return
> > > a phys_addr_t, thereby allowing it to be located above 4GB.
> > 
> > At first glance, it sounds great. But I can't imagine a scenario where
> > on pae system kernel can be located above 4G. As far as I know i386 and
> > its pae can't do this because the current linux VM implementation can't
> > allow that. I am not familiar with arm system. So please correct me if
> > I was wrong.
> 
> You are wrong.  That's precisely why this patch exists.

I don't know arm is different then i386. On i386 the kernel text mapping
is linear, just as follow:

#define __phys_addr_nodebug(x)  ((x) - PAGE_OFFSET)


But arm seems not linear. 
static inline phys_addr_t __virt_to_phys(unsigned long x)
{
        phys_addr_t t;

        if (sizeof(phys_addr_t) = 4) {
                __pv_stub(x, t, "add", __PV_BITS_31_24);
        } else {
                __pv_stub_mov_hi(t);
                __pv_add_carry_stub(x, t);
        }
        return t;
}

So on arm PAE this change makes sense.

Besides, I checked kexec/arch/arm/kexec-zImage-arm.c and found function
locate_hole() is used to find position for arm kernel. 

unsigned long locate_hole(struct kexec_info *info,
        unsigned long hole_size, unsigned long hole_align,
        unsigned long hole_min, unsigned long hole_max, 
        int hole_end)

The type unsigned long for hole_max limit the region where arm kernel is
loaded. So withough modifying this I doubt arm PAE can really be loaded
above 4G.

Thanks
Baoquan

> 
> -- 
> RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
