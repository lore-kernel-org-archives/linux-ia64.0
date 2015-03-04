From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Wed, 04 Mar 2015 22:58:05 +0000
Subject: Re: [PATCH v3 9/9] ACPI: arm64: use "Linux" as ACPI_OS_NAME for _OS on arm64
Message-Id: <1826593.dqIcOSxkcP@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org> <1424824585-6405-10-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-10-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: al.stone@linaro.org
Cc: lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Tuesday, February 24, 2015 05:36:25 PM al.stone@linaro.org wrote:
> From: Al Stone <al.stone@linaro.org>
> 
> ACPI_OS_NAME is globally defined as "Microsoft Windows NT" for now.
> That doesn't make much sense in the ARM context, so set it to "Linux"
> when CONFIG_ARM64.
> 
> If it is necessary to change the return value from \_OS_ (that is, return
> some value other than the default in ACPI_OS_NAME), use the kernel parameter
> "acpi_os_name=<string>".
> 
> Many thanks to Rafael Wysocki for this greatly simplified form of the patch.
> 
> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
> Signed-off-by: Al Stone <al.stone@linaro.org>

Yup, fine by me.

> ---
>  arch/arm64/Kconfig              | 5 +++++
>  include/acpi/acconfig.h         | 2 ++
>  include/acpi/platform/aclinux.h | 4 ++++
>  3 files changed, 11 insertions(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index e441d28..d812113 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -87,6 +87,11 @@ config ARM64
>  config 64BIT
>  	def_bool y
>  
> +config ACPI_OS_NAME
> +	string
> +	default "Linux"
> +	depends on ACPI
> +
>  config ARCH_PHYS_ADDR_T_64BIT
>  	def_bool y
>  
> diff --git a/include/acpi/acconfig.h b/include/acpi/acconfig.h
> index 5a0a3e5..1980bf4 100644
> --- a/include/acpi/acconfig.h
> +++ b/include/acpi/acconfig.h
> @@ -69,7 +69,9 @@
>   * code that will not execute the _OSI method unless _OS matches the string
>   * below.  Therefore, change this string at your own risk.
>   */
> +#ifndef ACPI_OS_NAME
>  #define ACPI_OS_NAME                    "Microsoft Windows NT"
> +#endif
>  
>  /* Maximum objects in the various object caches */
>  
> diff --git a/include/acpi/platform/aclinux.h b/include/acpi/platform/aclinux.h
> index 1ba7c19..a871cdd 100644
> --- a/include/acpi/platform/aclinux.h
> +++ b/include/acpi/platform/aclinux.h
> @@ -69,6 +69,10 @@
>  #define ACPI_REDUCED_HARDWARE 1
>  #endif
>  
> +#ifdef CONFIG_ACPI_OS_NAME
> +#define ACPI_OS_NAME CONFIG_ACPI_OS_NAME
> +#endif
> +
>  #include <linux/string.h>
>  #include <linux/kernel.h>
>  #include <linux/ctype.h>
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
