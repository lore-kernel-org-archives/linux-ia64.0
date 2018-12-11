From: Christoph Hellwig <hch@lst.de>
Date: Tue, 11 Dec 2018 17:15:04 +0000
Subject: Re: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <20181211171504.GA13624@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de> <20181210215113.GA22180@agluck-desk> <20181211065112.GA13668@lst.de> <3908561D78D1C84285E8C5FCA982C28F7D4922D6@ORSMSX110.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7D4922D6@ORSMSX110.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "Busch, Keith" <keith.busch@intel.com>, "Derrick, Jonathan" <jonathan.derrick@intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Dec 11, 2018 at 05:13:30PM +0000, Luck, Tony wrote:
> > But that might not be your fault. My ancient system is getting flaky. A v4.19 build that
> > has booted before is also resetting :-(
> 
> After a power-cycle (and some time to let the machine cool off). System now boots
> with your patch series plus the __phys_to_pfn() #define
> 
> So if you can figure the right way to fix that, you are good to go.
> 
> Tested-by: Tony Luck <tony.luck@intel.com>

Thanks.  I'll just replace the __phys_to_pfn with PHYS_PFN for now,
and see if I can find time to get the whole kernel to agree to
one version of this macro eventually..
