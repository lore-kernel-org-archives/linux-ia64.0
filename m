From: "H. Peter Anvin" <hpa@linux.intel.com>
Date: Fri, 29 Mar 2013 21:50:51 +0000
Subject: Re: drivers/acpi/bgrt.c:undefined reference to `bgrt_tab' (defined in arch/x86/platform/efi/efi-bgrt
Message-Id: <51560CBB.2010408@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130327005555.GA14974@localhost>
In-Reply-To: <20130327005555.GA14974@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 03/29/2013 02:50 PM, Tony Luck wrote:
> 
> 
> 
> On Tue, Mar 26, 2013 at 5:55 PM, Fengguang Wu <fengguang.wu@intel.com
> <mailto:fengguang.wu@intel.com>> wrote:
> 
> 
>     The problem is, drivers/acpi/bgrt.c references bgrt_tab etc. variables
>     defined in arch/x86/platform/efi/efi-bgrt.c which is obviously not
>     available in ia64.
> 
> 
> So perhaps the solution is to not let the user configure
> this on IA64.  I don't think we have platforms with
> boot graphics support (many ia64 machines are headless
> so have *no* graphics at all!).
> 
> gmail will whitespace destroy this patch - but easier to type
> in the half dozen extra characters anyway:
> 
>  diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index 4fc0ffc..8fcae6d 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -395,7 +395,7 @@ config ACPI_CUSTOM_METHOD
>  
>  config ACPI_BGRT
>         bool "Boottime Graphics Resource Table support"
> -       depends on EFI
> +       depends on EFI && X86
>          help
>           This driver adds support for exposing the ACPI Boottime Graphics
>           Resource Table, which allows the operating system to obtain
> 

Makes sense to me.

Acked-by: H. Peter Anvin <hpa@zytor.com>

	-hpa

