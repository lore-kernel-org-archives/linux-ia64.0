From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 22 Apr 2005 06:38:30 +0000
Subject: Re: [ACPI] [RFC/PATCH 1/3] ACPI based I/O APIC hot-plug
Message-Id: <42689BE6.4040004@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD13.5080900@jp.fujitsu.com> <1114104091.2784.40.camel@eeyore>
In-Reply-To: <1114104091.2784.40.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, Len Brown <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Greg KH <greg@kroah.com>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net

Hi Bjorn,

Thank you very much for comments.
I'll update my patches based on your comments.

Regards,
Kenji Kaneshige


Bjorn Helgaas wrote:
>>+++ linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c	2005-04-20 10:51:30.136299152 +0900
>>@@ -892,4 +892,21 @@ acpi_map_iosapic (acpi_handle handle, u3
>> 	return AE_OK;
>> }
>> #endif /* CONFIG_NUMA */
>>+
>>+int
>>+acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
>>+{
>>+	/* TBD */
>>+	return -EINVAL;
>>+}
>>+EXPORT_SYMBOL(acpi_register_ioapic);
>>+
>>+int
>>+acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base)
> 
> 
> Nitpick: these declarations should follow the style of the rest
> of the file, i.e., add a space between the function name and the
> opening parenthesis.
> 
> 

