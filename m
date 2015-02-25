From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Wed, 25 Feb 2015 12:55:41 +0000
Subject: Re: [PATCH v3 2/9] ACPI: clear up warnings on use of printk reported by checkpatch.pl
Message-Id: <54EDC64D.8040301@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org> <1424824585-6405-3-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-3-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: al.stone@linaro.org, rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, linaro-acpi@lists.linaro.org, patches@linaro.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, devel@acpica.org

On 2015年02月25日 08:36, al.stone@linaro.org wrote:
> From: Al Stone <al.stone@linaro.org>
>
> In preparation for later splitting out some of the arch-dependent code from
> osl.c, clear up all the warnings reported by checkpatch.pl where pr_* should
> be used instead of printk(KERN_* ...).
>
> Signed-off-by: Al Stone <al.stone@linaro.org>
> ---
>   drivers/acpi/osl.c | 46 +++++++++++++++++++---------------------------
>   1 file changed, 19 insertions(+), 27 deletions(-)
>
> diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
> index 1dc3a3b..865317c 100644
> --- a/drivers/acpi/osl.c
> +++ b/drivers/acpi/osl.c
> @@ -141,7 +141,7 @@ static u32 acpi_osi_handler(acpi_string interface, u32 supported)
>   {
>   	if (!strcmp("Linux", interface)) {
>
> -		printk_once(KERN_NOTICE FW_BUG PREFIX
> +		pr_notice_once(FW_BUG PREFIX

I think you can use pr_fmt() and then remove all the PREFIX in
this patch, just

#define pr_fmt(fmt) "ACPI: " fmt

in top of this file before all #includes.

Thanks
Hanjun
