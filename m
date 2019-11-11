From: Joerg Roedel <joro@8bytes.org>
Date: Mon, 11 Nov 2019 15:06:31 +0000
Subject: Re: [PATCH v2] iommu/vt-d: Check VT-d RMRR region in BIOS is reported as reserved
Message-Id: <20191111150630.GF18333@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191017113919.25424-1-yian.chen@intel.com>
In-Reply-To: <20191017113919.25424-1-yian.chen@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yian Chen <yian.chen@intel.com>
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, Ashok Raj <ashok.raj@intel.com>, Sohil Mehta <sohil.mehta@intel.com>, Tony Luck <tony.luck@intel.com>, Lu Baolu <baolu.lu@linux.intel.com>, Ravi Shankar <ravi.v.shankar@intel.com>

On Thu, Oct 17, 2019 at 04:39:19AM -0700, Yian Chen wrote:
> VT-d RMRR (Reserved Memory Region Reporting) regions are reserved
> for device use only and should not be part of allocable memory pool of OS.
> 
> BIOS e820_table reports complete memory map to OS, including OS usable
> memory ranges and BIOS reserved memory ranges etc.
> 
> x86 BIOS may not be trusted to include RMRR regions as reserved type
> of memory in its e820 memory map, hence validate every RMRR entry
> with the e820 memory map to make sure the RMRR regions will not be
> used by OS for any other purposes.
> 
> ia64 EFI is working fine so implement RMRR validation as a dummy function
> 
> Reviewed-by: Lu Baolu <baolu.lu@linux.intel.com>
> Reviewed-by: Sohil Mehta <sohil.mehta@intel.com>
> Signed-off-by: Yian Chen <yian.chen@intel.com>
> ---
> v2:
> - return -EINVAL instead of -EFAULT when there is an error
> ---
>  arch/ia64/include/asm/iommu.h |  5 +++++
>  arch/x86/include/asm/iommu.h  | 18 ++++++++++++++++++
>  drivers/iommu/intel-iommu.c   |  8 +++++++-
>  3 files changed, 30 insertions(+), 1 deletion(-)

Applied, thanks.
