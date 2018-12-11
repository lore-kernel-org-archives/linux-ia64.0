From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Dec 2018 17:13:30 +0000
Subject: RE: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7D4922D6@ORSMSX110.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
 <20181210215113.GA22180@agluck-desk> <20181211065112.GA13668@lst.de> 
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?iso-8859-1?Q?Toke_H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "Busch, Keith" <keith.busch@intel.com>, "Derrick, Jonathan" <jonathan.derrick@intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> But that might not be your fault. My ancient system is getting flaky. A v4.19 build that
> has booted before is also resetting :-(

After a power-cycle (and some time to let the machine cool off). System now boots
with your patch series plus the __phys_to_pfn() #define

So if you can figure the right way to fix that, you are good to go.

Tested-by: Tony Luck <tony.luck@intel.com>
