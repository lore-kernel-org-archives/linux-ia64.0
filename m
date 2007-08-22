From: Jeremy Higdon <jeremy@sgi.com>
Date: Wed, 22 Aug 2007 23:54:45 +0000
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory would be corrupted
Message-Id: <20070822235445.GG89849@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46CC48FD.4000607@linux.vnet.ibm.com> <20070822091959.aa38fd3e.akpm@linux-foundation.org> <20070822172541.GA8058@bingen.suse.de> <46CC811C.9010600@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2D39@scsmsx411.amr.corp.intel.com> <46CCB79E.7070109@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2F6A@scsmsx411.amr.corp.intel.com> <20070822231111.GD89849@sgi.com> <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org

On Wed, Aug 22, 2007 at 04:27:09PM -0700, Luck, Tony wrote:
> > The more ioc's you have, the more space you will use.
> 
> Default SW IOTLB allocation is 64MB ... how much should we see
> used per ioc?


Hmm.  Must be something else going on then.  It should be less than 1MB
per ioc plus whatever is used for streaming I/O.

| mptbase: Initiating ioc2 bringup                              | GSI 16 (level, low) -> CPU 2 (0xc418) vector 50
| ioc2: LSI53C1030 C0: Capabilities={Initiator}                 | ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) ->
| DMA: Out of SW-IOMMU space for 263200 bytes at device ?       | uhci_hcd 0000:00:1d.0: UHCI Host Controller
| Kernel panic - not syncing: DMA: Memory would be corrupted    | uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus n
