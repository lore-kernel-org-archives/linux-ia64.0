From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Date: Wed, 02 Jul 2014 14:02:31 +0000
Subject: Re: [PATCH v7 07/10] xen: Define EFI related stuff
Message-Id: <alpine.DEB.2.02.1407021502070.8923@kaball.uk.xensource.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com> <1404150784-27921-8-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1404150784-27921-8-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Kiper <daniel.kiper@oracle.com>
Cc: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org, andrew.cooper3@citrix.com, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, mjg59@srcf.ucam.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

On Mon, 30 Jun 2014, Daniel Kiper wrote:
> Define constants and structures which are needed to properly
> execute EFI related hypercall in Xen dom0.
> 
> This patch is based on Jan Beulich and Tang Liang work.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> Signed-off-by: Tang Liang <liang.tang@oracle.com>
> Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Acked-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>


> v6 - suggestions/fixes:
>    - fix indentation
>      (suggested by David Vrabel).
> 
> v5 - suggestions/fixes:
>    - improve commit message
>      (suggested by David Vrabel).
> 
> v4 - suggestions/fixes:
>    - change some types from generic to Xen specific ones
>      (suggested by Stefano Stabellini),
>    - do some formating changes
>      (suggested by Jan Beulich).
> ---
>  include/xen/interface/platform.h |  123 ++++++++++++++++++++++++++++++++++++++
>  1 file changed, 123 insertions(+)
> 
> diff --git a/include/xen/interface/platform.h b/include/xen/interface/platform.h
> index f1331e3..5cc49ea 100644
> --- a/include/xen/interface/platform.h
> +++ b/include/xen/interface/platform.h
> @@ -108,11 +108,113 @@ struct xenpf_platform_quirk {
>  };
>  DEFINE_GUEST_HANDLE_STRUCT(xenpf_platform_quirk_t);
>  
> +#define XENPF_efi_runtime_call    49
> +#define XEN_EFI_get_time                      1
> +#define XEN_EFI_set_time                      2
> +#define XEN_EFI_get_wakeup_time               3
> +#define XEN_EFI_set_wakeup_time               4
> +#define XEN_EFI_get_next_high_monotonic_count 5
> +#define XEN_EFI_get_variable                  6
> +#define XEN_EFI_set_variable                  7
> +#define XEN_EFI_get_next_variable_name        8
> +#define XEN_EFI_query_variable_info           9
> +#define XEN_EFI_query_capsule_capabilities   10
> +#define XEN_EFI_update_capsule               11
> +
> +struct xenpf_efi_runtime_call {
> +	uint32_t function;
> +	/*
> +	 * This field is generally used for per sub-function flags (defined
> +	 * below), except for the XEN_EFI_get_next_high_monotonic_count case,
> +	 * where it holds the single returned value.
> +	 */
> +	uint32_t misc;
> +	xen_ulong_t status;
> +	union {
> +#define XEN_EFI_GET_TIME_SET_CLEARS_NS 0x00000001
> +		struct {
> +			struct xenpf_efi_time {
> +				uint16_t year;
> +				uint8_t month;
> +				uint8_t day;
> +				uint8_t hour;
> +				uint8_t min;
> +				uint8_t sec;
> +				uint32_t ns;
> +				int16_t tz;
> +				uint8_t daylight;
> +			} time;
> +			uint32_t resolution;
> +			uint32_t accuracy;
> +		} get_time;
> +
> +		struct xenpf_efi_time set_time;
> +
> +#define XEN_EFI_GET_WAKEUP_TIME_ENABLED 0x00000001
> +#define XEN_EFI_GET_WAKEUP_TIME_PENDING 0x00000002
> +		struct xenpf_efi_time get_wakeup_time;
> +
> +#define XEN_EFI_SET_WAKEUP_TIME_ENABLE      0x00000001
> +#define XEN_EFI_SET_WAKEUP_TIME_ENABLE_ONLY 0x00000002
> +		struct xenpf_efi_time set_wakeup_time;
> +
> +#define XEN_EFI_VARIABLE_NON_VOLATILE       0x00000001
> +#define XEN_EFI_VARIABLE_BOOTSERVICE_ACCESS 0x00000002
> +#define XEN_EFI_VARIABLE_RUNTIME_ACCESS     0x00000004
> +		struct {
> +			GUEST_HANDLE(void) name;  /* UCS-2/UTF-16 string */
> +			xen_ulong_t size;
> +			GUEST_HANDLE(void) data;
> +			struct xenpf_efi_guid {
> +				uint32_t data1;
> +				uint16_t data2;
> +				uint16_t data3;
> +				uint8_t data4[8];
> +			} vendor_guid;
> +		} get_variable, set_variable;
> +
> +		struct {
> +			xen_ulong_t size;
> +			GUEST_HANDLE(void) name;  /* UCS-2/UTF-16 string */
> +			struct xenpf_efi_guid vendor_guid;
> +		} get_next_variable_name;
> +
> +		struct {
> +			uint32_t attr;
> +			uint64_t max_store_size;
> +			uint64_t remain_store_size;
> +			uint64_t max_size;
> +		} query_variable_info;
> +
> +		struct {
> +			GUEST_HANDLE(void) capsule_header_array;
> +			xen_ulong_t capsule_count;
> +			uint64_t max_capsule_size;
> +			uint32_t reset_type;
> +		} query_capsule_capabilities;
> +
> +		struct {
> +			GUEST_HANDLE(void) capsule_header_array;
> +			xen_ulong_t capsule_count;
> +			uint64_t sg_list; /* machine address */
> +		} update_capsule;
> +	} u;
> +};
> +DEFINE_GUEST_HANDLE_STRUCT(xenpf_efi_runtime_call);
> +
> +#define  XEN_FW_EFI_VERSION        0
> +#define  XEN_FW_EFI_CONFIG_TABLE   1
> +#define  XEN_FW_EFI_VENDOR         2
> +#define  XEN_FW_EFI_MEM_INFO       3
> +#define  XEN_FW_EFI_RT_VERSION     4
> +
>  #define XENPF_firmware_info       50
>  #define XEN_FW_DISK_INFO          1 /* from int 13 AH/41/48 */
>  #define XEN_FW_DISK_MBR_SIGNATURE 2 /* from MBR offset 0x1b8 */
>  #define XEN_FW_VBEDDC_INFO        3 /* from int 10 AXO15 */
> +#define XEN_FW_EFI_INFO           4 /* from EFI */
>  #define XEN_FW_KBD_SHIFT_FLAGS    5 /* Int16, Fn02: Get keyboard shift flags. */
> +
>  struct xenpf_firmware_info {
>  	/* IN variables. */
>  	uint32_t type;
> @@ -144,6 +246,26 @@ struct xenpf_firmware_info {
>  			GUEST_HANDLE(uchar) edid;
>  		} vbeddc_info; /* XEN_FW_VBEDDC_INFO */
>  
> +		union xenpf_efi_info {
> +			uint32_t version;
> +			struct {
> +				uint64_t addr;   /* EFI_CONFIGURATION_TABLE */
> +				uint32_t nent;
> +			} cfg;
> +			struct {
> +				uint32_t revision;
> +				uint32_t bufsz;  /* input, in bytes */
> +				GUEST_HANDLE(void) name;
> +				/* UCS-2/UTF-16 string */
> +			} vendor;
> +			struct {
> +				uint64_t addr;
> +				uint64_t size;
> +				uint64_t attr;
> +				uint32_t type;
> +			} mem;
> +		} efi_info; /* XEN_FW_EFI_INFO */
> +
>  		uint8_t kbd_shift_flags; /* XEN_FW_KBD_SHIFT_FLAGS */
>  	} u;
>  };
> @@ -362,6 +484,7 @@ struct xen_platform_op {
>  		struct xenpf_read_memtype      read_memtype;
>  		struct xenpf_microcode_update  microcode;
>  		struct xenpf_platform_quirk    platform_quirk;
> +		struct xenpf_efi_runtime_call  efi_runtime_call;
>  		struct xenpf_firmware_info     firmware_info;
>  		struct xenpf_enter_acpi_sleep  enter_acpi_sleep;
>  		struct xenpf_change_freq       change_freq;
> -- 
> 1.7.10.4
> 
