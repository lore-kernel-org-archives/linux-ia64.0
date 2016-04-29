From: Pratyush Anand <panand@redhat.com>
Date: Fri, 29 Apr 2016 14:31:45 +0000
Subject: Re: [PATCH 03/12] ARM: kexec: remove 512MB restriction on kexec crashdump
Message-Id: <CAHB_GuqOvRof94QdHztPy2B2kKuyKzQ-9uxXHY_g+i5WxsexZg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
	<E1aviEp-0000ir-7s@rmk-PC.arm.linux.org.uk>
In-Reply-To: <E1aviEp-0000ir-7s@rmk-PC.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Thu, Apr 28, 2016 at 2:57 PM, Russell King
<rmk+kernel@arm.linux.org.uk> wrote:
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  arch/arm/kernel/setup.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
> index 77b54c461c52..d9317eec1eba 100644
> --- a/arch/arm/kernel/setup.c
> +++ b/arch/arm/kernel/setup.c
> @@ -943,7 +943,6 @@ late_initcall(init_machine_late);
>   * zImage relocating below the reserved region.
>   */
>  #define CRASH_ALIGN    (128 << 20)
> -#define CRASH_ADDR_MAX (PHYS_OFFSET + (512 << 20))
>
>  static inline unsigned long long get_total_mem(void)
>  {
> @@ -973,9 +972,7 @@ static void __init reserve_crashkernel(void)
>                 return;
>
>         if (crash_base <= 0) {
> -               unsigned long long crash_max = CRASH_ADDR_MAX;
> -               if (crash_max > (u32)~0)
> -                       crash_max = (u32)~0;
> +               unsigned long long crash_max = idmap_to_phys((u32)~0);
>                 crash_base = memblock_find_in_range(CRASH_ALIGN, crash_max,
>                                                     crash_size, CRASH_ALIGN);
>                 if (!crash_base) {

Reviewed-by: Pratyush Anand <panand@redhat.com>

Unrelated to these modification:
In function arch/arm/mm/init.c: arm_memblock_steal() may be  following
would be more appropriate?
memblock_alloc_base(size, align, idmap_to_phys(MEMBLOCK_ALLOC_ANYWHERE));
