From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Wed, 11 May 2016 08:52:03 +0000
Subject: Re: [PATCH 00/12] Fixing TI Keystone2 kexec
Message-Id: <20160511085203.GN19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <20160511082923.GC8995@dhcp-128-65.nay.redhat.com>
In-Reply-To: <20160511082923.GC8995@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Young <dyoung@redhat.com>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Wed, May 11, 2016 at 04:29:23PM +0800, Dave Young wrote:
> Hi, Russell
> 
> On 04/28/16 at 10:26am, Russell King - ARM Linux wrote:
> > These changes are required for TI Keystone2 kexec to be functional.  TI
> > Keystone2 has the run-time view of physical memory above 4GiB, but with
> > a boot time alias below 4GiB which can only be used during the early
> > boot.
> > 
> > This means we need to translate run-time physical addresses (which the
> > kernel uses) to boot-time physical addresses, which, having discussed
> > with Eric, is what the kexec tools and kexec kernel API requires.
> > 
> > We publish a special set of boot time resources in /proc/iomem, which
> > the (modified) kexec tools look for in preference to the normal resources.
> > Hence, if these are found, the kexec tools make use of these resources,
> > and thus kexec tools use the boot-time view of physical memory.
> 
> I think getting memory ranges from device tree will be better than
> adding more stuff to /proc/iomem. Geoff's arm64 kexec patches is using dtb
> you can refer to the patchset.

I think you're confusing things.  DT doesn't contain the boot alias
memory ranges - it's not a separate chunk of memory.  It's an alias
of the same physical address space found higher in the physical
address range.

If we put it in DT, then we need a way to also describe that it is an
alias of some other bit of physical memory.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
