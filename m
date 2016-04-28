From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Thu, 28 Apr 2016 08:56:54 +0000
Subject: Re: [PATCH 3/3] kexec: arrange for paddr_vmcoreinfo_note() to return phys_addr_t
Message-Id: <20160428085654.GV19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160414195938.GV19428@n2100.arm.linux.org.uk>
 <E1aqnQy-0001U9-SR@rmk-PC.arm.linux.org.uk>
 <20160418053820.GC3602@x1.redhat.com>
 <20160418083601.GY19428@n2100.arm.linux.org.uk>
 <20160418103258.GE3602@x1.redhat.com>
 <20160418105236.GB19428@n2100.arm.linux.org.uk>
 <20160418112815.GF3602@x1.redhat.com>
In-Reply-To: <20160418112815.GF3602@x1.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baoquan He <bhe@redhat.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org

What's the status of these three patches then?  It's been a fortnight
since they were sent, and I've heard nothing about whether they're
going to be applied or not.


On Mon, Apr 18, 2016 at 07:28:15PM +0800, Baoquan He wrote:
> On 04/18/16 at 11:52am, Russell King - ARM Linux wrote:
> > On Mon, Apr 18, 2016 at 06:32:58PM +0800, Baoquan He wrote:
> > > On 04/18/16 at 09:36am, Russell King - ARM Linux wrote:
> > > > On Mon, Apr 18, 2016 at 01:38:20PM +0800, Baoquan He wrote:
> > > > > On 04/14/16 at 09:00pm, Russell King wrote:
> > > > > > On PAE systems (eg, ARM LPAE) the vmcore note may be located above
> > > > > > 4GB physical on 32-bit architectures, so we need a wider type than
> > > > > > "unsigned long" here.  Arrange for paddr_vmcoreinfo_note() to return
> > > > > > a phys_addr_t, thereby allowing it to be located above 4GB.
> > > > > 
> > > > > At first glance, it sounds great. But I can't imagine a scenario where
> > > > > on pae system kernel can be located above 4G. As far as I know i386 and
> > > > > its pae can't do this because the current linux VM implementation can't
> > > > > allow that. I am not familiar with arm system. So please correct me if
> > > > > I was wrong.
> > > > 
> > > > You are wrong.  That's precisely why this patch exists.
> > > 
> > > I don't know arm is different then i386. On i386 the kernel text mapping
> > > is linear, just as follow:
> > > 
> > > #define __phys_addr_nodebug(x)  ((x) - PAGE_OFFSET)
> > > 
> > > 
> > > But arm seems not linear. 
> > > static inline phys_addr_t __virt_to_phys(unsigned long x)
> > > {
> > >         phys_addr_t t;
> > > 
> > >         if (sizeof(phys_addr_t) = 4) {
> > >                 __pv_stub(x, t, "add", __PV_BITS_31_24);
> > >         } else {
> > >                 __pv_stub_mov_hi(t);
> > >                 __pv_add_carry_stub(x, t);
> > >         }
> > >         return t;
> > > }
> > > 
> > > So on arm PAE this change makes sense.
> > 
> > No.  This has nothing to do with whether memory is linear or not.  The
> > above code has nothing to do with that either.  The above code you quote
> > allows us to efficiently runtime modify the virtual to physical
> > translation offset, nothing more.
> 
> OK, thanks for telling this. Learned it.
> 
> > 
> > > Besides, I checked kexec/arch/arm/kexec-zImage-arm.c and found function
> > > locate_hole() is used to find position for arm kernel. 
> > > 
> > > unsigned long locate_hole(struct kexec_info *info,
> > >         unsigned long hole_size, unsigned long hole_align,
> > >         unsigned long hole_min, unsigned long hole_max, 
> > >         int hole_end)
> > > 
> > > The type unsigned long for hole_max limit the region where arm kernel is
> > > loaded. So withough modifying this I doubt arm PAE can really be loaded
> > > above 4G.
> > 
> > Please, stop "doubting" the patches.
> > 
> > I have here a machine which requires these patches, and they're all
> > tested.  Without these patches, it doesn't work - and in fact trying
> > to use kexec on the platform takes out userspace due to the OOM killer.
> > With these patches, it does work - fully.  It has the start of system
> > memory above 4GB physical, with a non-DMA coherent boot time alias
> > below 4GB.
> > 
> > On a running system, the kernel ignores the boot alias below 4GB.
> > Having discussed with Eric, kexec is designed to use the boot time
> > alias, and we need to teach kexec about the difference between the
> > boot time alias and the running system memory layout.
> > 
> > That's what these patches are all about.
> > 
> > I've been discussing the problem with Eric on and off over the last
> > six months, and he's the one who suggested in part the solution
> > implemented in this series.
> 
> Got it. Just pass by to have a look:) Since Erci suggested these I stop
> making noise right now.
> 
> Thanks for telling above knowledge about arm.
> 
> Thanks
> Baoquan

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
