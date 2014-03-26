From: "Jan Beulich" <JBeulich@suse.com>
Date: Wed, 26 Mar 2014 13:31:04 +0000
Subject: Re: [PATCH v3 5/5] xen: Put EFI machinery in place
Message-Id: <5332E4A802000078000025B6@nat28.tlf.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-6-git-send-email-daniel.kiper@oracle.com>
 <20140326131214.GC24856@console-pimps.org>
In-Reply-To: <20140326131214.GC24856@console-pimps.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Fleming <matt@console-pimps.org>
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, jeremy@goop.org, fenghua.yu@intel.com, matt.fleming@intel.com, tony.luck@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, Daniel Kiper <daniel.kiper@oracle.com>, konrad.wilk@oracle.com, Tang Liang <liang.tang@oracle.com>, eshelton@pobox.com, mingo@redhat.com, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

>>> On 26.03.14 at 14:12, <matt@console-pimps.org> wrote:
> On Tue, 25 Mar, at 09:57:56PM, Daniel Kiper wrote:
>> +static void __init efi_init_xen(void)
>> +{
>> +	efi_char16_t vendor_c16[100];
>> +	char vendor[ARRAY_SIZE(vendor_c16)];
>> +	int ret, i;
>> +	struct xen_platform_op op;
>> +	union xenpf_efi_info *info = &op.u.firmware_info.u.efi_info;
>> +
>> +	efi = efi_xen;
>> +	op.cmd = XENPF_firmware_info;
>> +	op.u.firmware_info.type = XEN_FW_EFI_INFO;
>> +
>> +	/*
>> +	 * Show what we know for posterity
>> +	 */
>> +	op.u.firmware_info.index = XEN_FW_EFI_VENDOR;
>> +	info->vendor.bufsz = sizeof(vendor_c16);
>> +	set_xen_guest_handle(info->vendor.name, vendor_c16);
>> +	ret = HYPERVISOR_dom0_op(&op);
>> +	if (!ret) {
>> +		for (i = 0; i < sizeof(vendor) - 1 && vendor_c16[i]; ++i)
>> +			vendor[i] = vendor_c16[i];
>> +		vendor[i] = '\0';
>> +	} else
>> +		pr_err("Could not get the firmware vendor!\n");
>> +
> 
> Is there a reason that you can't just populate an efi_system_table_t
> object, which could be used by efi_init(), so that we can save you the
> trouble of duplicating all of this code?

Would the generic function cope with all other fields being NULL (or
equivalent)?

>> +/*
>> + * Convenience functions to obtain memory types and attributes
>> + */
>> +static u32 efi_mem_type_xen(unsigned long phys_addr)
>> +{
>> +	struct xen_platform_op op;
>> +	union xenpf_efi_info *info = &op.u.firmware_info.u.efi_info;
>> +
>> +	op.cmd = XENPF_firmware_info;
>> +	op.u.firmware_info.type = XEN_FW_EFI_INFO;
>> +	op.u.firmware_info.index = XEN_FW_EFI_MEM_INFO;
>> +	info->mem.addr = phys_addr;
>> +	info->mem.size = 0;
>> +	return HYPERVISOR_dom0_op(&op) ? 0 : info->mem.type;
>> +}
> 
> Same idea here. Unless you expect the EFI memory map to change at runtime
> (and it's not clear to me whether that wouldn't cause other things to
> explode) you'd be better off building a struct efi_memory_map and using
> the existing generic functions.

As said in another reply to this series - the memory map isn't being
(and shouldn't be) exposed to Dom0.

Jan

