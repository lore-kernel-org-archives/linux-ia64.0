From: Joerg Roedel <joro@8bytes.org>
Date: Wed, 27 May 2020 14:45:21 +0000
Subject: Re: [PATCH 1/2] ia64: Hide the archdata.iommu field behind generic IOMMU_API
Message-Id: <20200527144521.GL5221@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200518120855.27822-1-krzk@kernel.org>
In-Reply-To: <20200518120855.27822-1-krzk@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org

On Mon, May 18, 2020 at 02:08:54PM +0200, Krzysztof Kozlowski wrote:
> There is a generic, kernel wide configuration symbol for enabling the
> IOMMU specific bits: CONFIG_IOMMU_API.  Implementations (including
> INTEL_IOMMU driver) select it so use it here as well.
> 
> This makes the conditional archdata.iommu field consistent with other
> platforms and also fixes any compile test builds of other IOMMU drivers,
> when INTEL_IOMMU is not selected).
> 
> For the case when INTEL_IOMMU and COMPILE_TEST are not selected, this
> should create functionally equivalent code/choice.  With COMPILE_TEST
> this field could appear if other IOMMU drivers are chosen but
> INTEL_IOMMU not.
> 
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>
> 
> ---
> 
> See:
> https://lore.kernel.org/lkml/202005181412.frC4juFy%25lkp@intel.com/
> ---
>  arch/ia64/include/asm/device.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Applied both to iommu/fixes.
