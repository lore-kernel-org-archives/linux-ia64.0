From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 31 Jan 2007 19:46:19 +0000
Subject: Re: [PATCH] EFI x86: pass firmware call parameters on the stack
Message-Id: <200701311246.19582.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070130201600.GA10526@lists.us.dell.com>
In-Reply-To: <20070130201600.GA10526@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 30 January 2007 13:16, Matt Domsch wrote:
> FYI, this was sent to lkml.  I haven't reviewed yet.

I objected to the original LKML patch.  Frederic then posted
a different one that adds x86 wrappers, similar to what ia64
already has.  That one affects only x86, and seems fine to me.

Bjorn

> ----- Forwarded message from Fr?d?ric Riss <frederic.riss@gmail.com> -----
> 
> Subject: [PATCH] EFI x86: pass firmware call parameters on the stack
> From: Fr?d?ric Riss <frederic.riss@gmail.com>
> To: linux-kernel@vger.kernel.org
> Cc: artiom.myaskouvskey@intel.com, bjorn.helgaas@hp.com, akpm@osdl.org,
> 	Linus Torvalds <torvalds@linux-foundation.org>
> Date: 	Tue, 30 Jan 2007 20:01:18 +0100
> 
> 
> When calling into an EFI firmware, the parameters need to be passed on
> the stack. The recent change to use -mregparm=3 breaks x86 EFI support.
> This patch is needed to allow the new Intel-based Macs to suspend to ram
> when run in EFI mode (efi.get_time is called during the suspend phase).
> 
> Signed-off-by: Frederic Riss <frederic.riss@gmail.com>
> 
> ---
> 
> [As I couldn't find an official maintainer for the linux/efi.h file and
> the file header is quite old, I'm Cc:ing the last 2 commiters.]
> 
> This patch fixes the issue for x86, but the file is also used by IA64. I
> would have used asmlinkage to force arguments on the stack, but it has a
> special meaning on IA64, thus I used a raw regparm(0) GCC attribute.
> This attribute is documented only for x86, I hope it has no side effect
> on other archs.
> 
> diff --git a/include/linux/efi.h b/include/linux/efi.h
> index df1c918..1db5321 100644
> --- a/include/linux/efi.h
> +++ b/include/linux/efi.h
> @@ -157,25 +157,35 @@ typedef struct {
>  	unsigned long reset_system;
>  } efi_runtime_services_t;
>  
> -typedef efi_status_t efi_get_time_t (efi_time_t *tm, efi_time_cap_t *tc);
> -typedef efi_status_t efi_set_time_t (efi_time_t *tm);
> +typedef efi_status_t efi_get_time_t (efi_time_t *tm, efi_time_cap_t *tc)
> +			__attribute__((regparm(0)));
> +typedef efi_status_t efi_set_time_t (efi_time_t *tm)
> +			__attribute__((regparm(0)));
>  typedef efi_status_t efi_get_wakeup_time_t (efi_bool_t *enabled, efi_bool_t *pending,
> -					    efi_time_t *tm);
> -typedef efi_status_t efi_set_wakeup_time_t (efi_bool_t enabled, efi_time_t *tm);
> +					    efi_time_t *tm)
> +			__attribute__((regparm(0)));
> +typedef efi_status_t efi_set_wakeup_time_t (efi_bool_t enabled, efi_time_t *tm)
> +			__attribute__((regparm(0)));
>  typedef efi_status_t efi_get_variable_t (efi_char16_t *name, efi_guid_t *vendor, u32 *attr,
> -					 unsigned long *data_size, void *data);
> +					 unsigned long *data_size, void *data)
> +			__attribute__((regparm(0)));
>  typedef efi_status_t efi_get_next_variable_t (unsigned long *name_size, efi_char16_t *name,
> -					      efi_guid_t *vendor);
> +					      efi_guid_t *vendor)
> +			__attribute__((regparm(0)));
>  typedef efi_status_t efi_set_variable_t (efi_char16_t *name, efi_guid_t *vendor, 
>  					 unsigned long attr, unsigned long data_size, 
> -					 void *data);
> -typedef efi_status_t efi_get_next_high_mono_count_t (u32 *count);
> +					 void *data)
> +			__attribute__((regparm(0)));
> +typedef efi_status_t efi_get_next_high_mono_count_t (u32 *count)
> +			__attribute__((regparm(0)));
>  typedef void efi_reset_system_t (int reset_type, efi_status_t status,
> -				 unsigned long data_size, efi_char16_t *data);
> +				 unsigned long data_size, efi_char16_t *data)
> +			__attribute__((regparm(0)));
>  typedef efi_status_t efi_set_virtual_address_map_t (unsigned long memory_map_size,
>  						unsigned long descriptor_size,
>  						u32 descriptor_version,
> -						efi_memory_desc_t *virtual_map);
> +						efi_memory_desc_t *virtual_map)
> +			__attribute__((regparm(0)));
>  
>  /*
>   *  EFI Configuration Table and GUID definitions
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> ----- End forwarded message -----
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
