From: Christoph Hellwig <hch@lst.de>
Date: Tue, 01 Mar 2022 11:43:35 +0000
Subject: Re: [PATCH 08/12] x86: centralize setting SWIOTLB_FORCE when guest memory encryption is enabled
Message-Id: <20220301114335.GA2881@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de> <20220301105311.885699-9-hch@lst.de> <8e623a11-d809-4fab-401c-2ce609a9fc14@citrix.com>
In-Reply-To: <8e623a11-d809-4fab-401c-2ce609a9fc14@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Andrew Cooper <Andrew.Cooper3@citrix.com>
Cc: Christoph Hellwig <hch@lst.de>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-hyperv@vger.kernel.org" <linux-hyperv@vger.kernel.org>, "tboot-devel@lists.sourceforge.net" <tboot-devel@lists.sourceforge.net>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>

On Tue, Mar 01, 2022 at 11:39:29AM +0000, Andrew Cooper wrote:
> This isn't really "must".  The guest is perfectly capable of sharing
> memory with the hypervisor.
> 
> It's just that for now, bounce buffering is allegedly faster, and the
> simple way of getting it working.

Yeah, I guess you щould just share/unshare on demand.  But given that
this isn't implemented it is a must in the current kernel.  But if
you want a different wording suggest one and I'll put it in.
