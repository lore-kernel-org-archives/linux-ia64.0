From: Jeremy Higdon <jeremy@sgi.com>
Date: Thu, 23 Aug 2007 01:09:48 +0000
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory would be corrupted
Message-Id: <20070823010948.GK89849@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822091959.aa38fd3e.akpm@linux-foundation.org> <20070822172541.GA8058@bingen.suse.de> <46CC811C.9010600@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2D39@scsmsx411.amr.corp.intel.com> <46CCB79E.7070109@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2F6A@scsmsx411.amr.corp.intel.com> <20070822231111.GD89849@sgi.com> <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com> <20070822235445.GG89849@sgi.com> <617E1C2C70743745A92448908E030B2A023B307D@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A023B307D@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org

On Wed, Aug 22, 2007 at 05:05:54PM -0700, Luck, Tony wrote:
> > Hmm.  Must be something else going on then.  It should be less than 1MB
> > per ioc plus whatever is used for streaming I/O.
> >
> > | mptbase: Initiating ioc2 bringup                              | GSI 16 (level, low) -> CPU 2 (0xc418) vector 50
> > | ioc2: LSI53C1030 C0: Capabilities={Initiator}                 | ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) ->
> > | DMA: Out of SW-IOMMU space for 263200 bytes at device ?       | uhci_hcd 0000:00:1d.0: UHCI Host Controller
> > | Kernel panic - not syncing: DMA: Memory would be corrupted    | uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus n
> 
> I traced the pci_alloc_consistent calls from PrimeIocFifos on my
> system.  There are two calls for each ioc.  The first is for
> 266368 bytes, the second for 16320 bytes.
> 
> I wonder why Kamalesh's system wants the slightly different
> amount (263200 bytes) from what my system asks for?
> 
> It also looks to be a little unfriendly to swiotlb to ask for
> more than 256K at a time (see IO_TLB_SEGSIZE) in swiotlb.c
> 
> -Tony

I believe those would vary a bit based on the exact firmware
rev and perhaps nvram settings.  Also driver settings, but
those are presumably the same.

jeremy
