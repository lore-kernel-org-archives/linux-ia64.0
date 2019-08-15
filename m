From: Joerg Roedel <joro@8bytes.org>
Date: Thu, 15 Aug 2019 07:19:54 +0000
Subject: Re: [PATCH 06/10] iommu: Remember when default domain type was set on kernel command line
Message-Id: <20190815071954.GD22669@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190814133841.7095-1-joro@8bytes.org>
 <20190814133841.7095-7-joro@8bytes.org>
 <754a526e-a6d4-8a3f-0b35-9dd3def5d24b@linux.intel.com>
In-Reply-To: <754a526e-a6d4-8a3f-0b35-9dd3def5d24b@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lu Baolu <baolu.lu@linux.intel.com>
Cc: corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

Hey Lu Baolu,

thanks for your review!

On Thu, Aug 15, 2019 at 01:01:57PM +0800, Lu Baolu wrote:
> > +#define IOMMU_CMD_LINE_DMA_API		(1 << 0)
> 
> Prefer BIT() micro?

Yes, I'll change that.

> > +	iommu_set_cmd_line_dma_api();
> 
> IOMMU command line is also set in other places, for example,
> iommu_setup() (arch/x86/kernel/pci-dma.c). Need to call this there as
> well?

You are right, I'll better add a 'bool cmd_line' parameter to the
iommu_set_default_*() functions and tell the IOMMU core this way. That
will also fix iommu=pt/nopt.

Thanks,

	Joerg
