From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Wed, 11 May 2016 09:32:55 +0000
Subject: Re: [PATCH 00/12] Fixing TI Keystone2 kexec
Message-Id: <20160511093255.GO19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <20160511082923.GC8995@dhcp-128-65.nay.redhat.com>
 <20160511085203.GN19428@n2100.arm.linux.org.uk>
 <20160511091338.GC10825@dhcp-128-65.nay.redhat.com>
In-Reply-To: <20160511091338.GC10825@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Young <dyoung@redhat.com>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Wed, May 11, 2016 at 05:13:38PM +0800, Dave Young wrote:
> On 05/11/16 at 09:52am, Russell King - ARM Linux wrote:
> > I think you're confusing things.  DT doesn't contain the boot alias
> > memory ranges - it's not a separate chunk of memory.  It's an alias
> > of the same physical address space found higher in the physical
> > address range.
> 
> Hmm, if we forget about kexec how does the 1st kernel get boot memory?
> not from DT?

Just like any other ARM system, it pulls itself up by its shoe laces.

The kernel assumes that it has been placed into RAM with at least 32KiB
of writable memory below it, which it uses for the initial page tables.
It "guesses" that the executing address, rounded down to I-forget-what-
boundary gives the base address of physical memory.

It sets the page table up using that assumption.  The kernel gets going
with C code, and only _then_ parses the DTB.

If we then find that we're running on TI Keystone 2, part of the early
platform initialisation specifies to the ARM core code that the kernel
is to switch a high physical address space > 4GiB, and this provokes
a "dance" where we tear the MMU back down, run some more assembly code
to fix up the page tables, and re-initialise the MMU before returning
to the kernel C code, this time running in the high physical address
space.  This break-modify-make is an architecture requirement.  We
also record the physical address delta between the original physical
address space and the high physical address space so that we can reverse
the translation for code which needs identity mapping (eg, SMP bringup.)

The DTB only contains the high physical address space memory information,
and the kernel now parses the DTB, and sets the page tables up properly
for the running system.

> > If we put it in DT, then we need a way to also describe that it is an
> > alias of some other bit of physical memory.
> 
> I may missed the background, I just want kexec to get infomation just like
> the normal kernel.

See above.  What you're asking for isn't really possible.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
