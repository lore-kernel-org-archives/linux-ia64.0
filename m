From: "Chen, Yian" <yian.chen@intel.com>
Date: Wed, 16 Oct 2019 17:21:24 +0000
Subject: Re: [PATCH] iommu/vt-d: Check VT-d RMRR region in BIOS is reported as reserved
Message-Id: <b1ebbf77-ced7-be22-d8d8-a7d4e19ad261@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191015164932.18185-1-yian.chen@intel.com>
 <20191016075120.GB32232@8bytes.org>
In-Reply-To: <20191016075120.GB32232@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>, "Mehta, Sohil" <sohil.mehta@intel.com>, "Luck, Tony" <tony.luck@intel.com>



On 10/16/2019 12:51 AM, Joerg Roedel wrote:
> Hi,
>
> On Tue, Oct 15, 2019 at 09:49:32AM -0700, Yian Chen wrote:
>> VT-d RMRR (Reserved Memory Region Reporting) regions are reserved
>> for device use only and should not be part of allocable memory pool of OS.
>>
>> BIOS e820_table reports complete memory map to OS, including OS usable
>> memory ranges and BIOS reserved memory ranges etc.
>>
>> x86 BIOS may not be trusted to include RMRR regions as reserved type
>> of memory in its e820 memory map, hence validate every RMRR entry
>> with the e820 memory map to make sure the RMRR regions will not be
>> used by OS for any other purposes.
> Are there real systems in the wild where this is a problem?
Firmware reports e820 and RMRR in separate structure. The system will 
not work stably
if RMRR is not in the e820 table as reserved type mem and can be used 
for other purposes.
In system engineering phase, I practiced with some kind bugs from BIOS, 
but not yet exactly same as
the one here. Please consider this is a generic patch to avoid 
subsequent failure at runtime.
>> +static inline int __init
>> +arch_rmrr_sanity_check(struct acpi_dmar_reserved_memory *rmrr)
>> +{
>> +	u64 start = rmrr->base_address;
>> +	u64 end = rmrr->end_address + 1;
>> +
>> +	if (e820__mapped_all(start, end, E820_TYPE_RESERVED))
>> +		return 0;
>> +
>> +	pr_err(FW_BUG "No firmware reserved region can cover this RMRR [%#018Lx-%#018Lx], contact BIOS vendor for fixes\n",
>> +	       start, end - 1);
>> +	return -EFAULT;
>> +}
> Why -EFAULT, there is no fault involved? Usibg -EINVAL seems to be a better choice.
-EFAULT could be used for address related errors.
For this case, I agree, -EINVAL seems better while
consider it as an input problem from firmware. I will make change.
