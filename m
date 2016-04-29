From: Pratyush Anand <panand@redhat.com>
Date: Fri, 29 Apr 2016 14:33:42 +0000
Subject: Re: [PATCH 04/12] ARM: provide arm_has_idmap_alias() helper
Message-Id: <CAHB_Guoj5ywYZGJ441MK9tBu-L_e4skCbhHyRkeXEXn8vaytXQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
	<E1aviEu-0000ix-C1@rmk-PC.arm.linux.org.uk>
In-Reply-To: <E1aviEu-0000ix-C1@rmk-PC.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Thu, Apr 28, 2016 at 2:58 PM, Russell King
<rmk+kernel@arm.linux.org.uk> wrote:
> Provide a helper to indicate whether we need to perform special handling
> for boot identity mapping aliases or not.
>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  arch/arm/include/asm/memory.h | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
> index ca208335fde6..31c07a2cc100 100644
> --- a/arch/arm/include/asm/memory.h
> +++ b/arch/arm/include/asm/memory.h
> @@ -295,6 +295,11 @@ extern long long arch_phys_to_idmap_offset;
>   * of physical memory for idmap purposes.  Most cases should leave these
>   * untouched.  Note: this can only return addresses less than 4GiB.
>   */
> +static inline bool arm_has_idmap_alias(void)
> +{
> +       return IS_ENABLED(CONFIG_MMU) && arch_phys_to_idmap_offset != 0;
> +}
> +
>  #define IDMAP_INVALID_ADDR ((u32)~0)
>
>  static inline unsigned long phys_to_idmap(phys_addr_t addr)

Reviewed-by: Pratyush Anand <panand@redhat.com>
