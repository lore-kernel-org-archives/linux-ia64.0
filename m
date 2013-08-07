From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Wed, 07 Aug 2013 11:54:58 +0000
Subject: Re: [PATCH v2 2/5] efi: provide a generic efi_config_init()
Message-Id: <20130807115458.GM18151@rocoto.smurfnet.nu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
 <1375462582-16423-3-git-send-email-leif.lindholm@linaro.org>
 <20130805121540.GP2515@console-pimps.org>
In-Reply-To: <20130805121540.GP2515@console-pimps.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Fleming <matt@console-pimps.org>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, patches@linaro.org

On Mon, Aug 05, 2013 at 01:15:40PM +0100, Matt Fleming wrote:
> > +static __init int match_config_table(efi_guid_t *guid,
> > +				     unsigned long table,
> > +				     efi_config_table_type_t *table_types)
> > +{
> > +	u8 str[38];
> 
> Shouldn't this be 37? You get 36 bytes for your GUID, plus a trailing
> NUL? Either way, this should be a #define. The closest thing we have in
> include/linux/efi.h is EFI_VARIABLE_GUID_LEN. Perhaps we need a
> EFI_GUID_LEN that includes the trailing NUL?
 
Err, yes. Don't recall where I decided on that now.
I think EFI_VARIABLE_GUID_LEN + 1 makes enough sense.

> One thing I just noticed that's worth pointing out is that 'pr_fmt'
> isn't defined in drivers/firmware/efi/efi.c. Before your patch series
> you get,
> 
> [    0.000000] efi:  SMBIOS=0xbae41a98  ACPI=0xbac6f000  ACPI 2.0=0xbac6f000  MPS=0xfca90 
> 
> and after,
> 
> [    0.000000]  SMBIOS=0xbae41a98  ACPI=0xbac6f000  ACPI 2.0=0xbac6f000 MPS=0xfca90 
> 
> which isn't the end of the world, but it does mean that the error
> messages are now much less informative, e.g.
 
I had completely missed that - sorry.
Adding in new series.

/
    Leif
