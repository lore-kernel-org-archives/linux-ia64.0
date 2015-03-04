From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Wed, 04 Mar 2015 22:48:24 +0000
Subject: Re: [PATCH v3 7/9] ACPI: enable arch-specific compilation for _OSI and the blacklist
Message-Id: <15870247.dI8jiUeRfk@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org> <1424824585-6405-8-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-8-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: al.stone@linaro.org
Cc: lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Tuesday, February 24, 2015 05:36:23 PM al.stone@linaro.org wrote:
> From: Al Stone <al.stone@linaro.org>
> 
> Whether arch-specific functions are used or not now depends on the config
> option CONFIG_ARCH_SPECIFIC_ACPI_OSI.  By default, this is set false which
> causes the x86/ia64 versions to be used, just as is done today.  Setting
> this option true causes architecture-specific implementations to be built
> instead; this patch also provides arm64 implementations.
> 
> For x86/ia64, there is no functional change.  Other architectures will have
> to add files to provide their specific functionality.
> 
> Signed-off-by: Al Stone <al.stone@linaro.org>

This one is fine by me.

> ---
>  drivers/acpi/Kconfig  | 3 +++
>  drivers/acpi/Makefile | 7 ++++++-
>  include/linux/acpi.h  | 8 ++++++++
>  3 files changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index b340509..4d91f22 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -53,6 +53,9 @@ config ACPI_SLEEP
>  	depends on SUSPEND || HIBERNATION
>  	default y
>  
> +config ARCH_SPECIFIC_ACPI_OSI
> +	def_bool n
> +
>  config ACPI_PROCFS_POWER
>  	bool "Deprecated power /proc/acpi directories"
>  	depends on PROC_FS
> diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
> index 97191eb..1428464 100644
> --- a/drivers/acpi/Makefile
> +++ b/drivers/acpi/Makefile
> @@ -18,9 +18,14 @@ obj-y				+= acpi.o \
>  					acpica/
>  
>  # All the builtin files are in the "acpi." module_param namespace.
> -acpi-y				+= osl.o utils.o reboot.o osi.o
> +acpi-y				+= osl.o utils.o reboot.o
>  acpi-y				+= nvs.o
>  
> +# _OSI related files
> +ifneq ($(CONFIG_ARCH_SPECIFIC_ACPI_OSI), y)
> +acpi-y				+= osi.o
> +endif
> +
>  # Power management related files
>  acpi-y				+= wakeup.o
>  acpi-y				+= sleep.o
> diff --git a/include/linux/acpi.h b/include/linux/acpi.h
> index 71cdeb6..97185a1 100644
> --- a/include/linux/acpi.h
> +++ b/include/linux/acpi.h
> @@ -279,9 +279,17 @@ static inline int acpi_video_display_switch_support(void)
>  #endif /* defined(CONFIG_ACPI_VIDEO) || defined(CONFIG_ACPI_VIDEO_MODULE) */
>  
>  extern int acpi_blacklisted(void);
> +
> +#ifdef CONFIG_ARCH_SPECIFIC_ACPI_OSI
> +static inline void __init acpi_dmi_osi_linux(int enable,
> +					     const struct dmi_system_id *d) { }
> +static inline void __init acpi_osi_setup(char *str) { }
> +#else
>  extern void __init acpi_dmi_osi_linux(int enable,
>  				      const struct dmi_system_id *d);
>  extern void __init acpi_osi_setup(char *str);
> +#endif
> +
>  extern u32 acpi_osi_handler(acpi_string interface, u32 supported);
>  
>  #ifdef CONFIG_ACPI_NUMA
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
