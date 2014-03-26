From: "Jan Beulich" <JBeulich@suse.com>
Date: Wed, 26 Mar 2014 13:22:49 +0000
Subject: Re: [PATCH v3 3/5] x86: Call efi_memblock_x86_reserve_range() on native EFI platform only
Message-Id: <5332E2B9020000780000255D@nat28.tlf.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-4-git-send-email-daniel.kiper@oracle.com>
 <20140326130009.GB24856@console-pimps.org>
In-Reply-To: <20140326130009.GB24856@console-pimps.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Fleming <matt@console-pimps.org>
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, jeremy@goop.org, fenghua.yu@intel.com, matt.fleming@intel.com, tony.luck@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, Daniel Kiper <daniel.kiper@oracle.com>, konrad.wilk@oracle.com, eshelton@pobox.com, mingo@redhat.com, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

>>> On 26.03.14 at 14:00, <matt@console-pimps.org> wrote:
> On Tue, 25 Mar, at 09:57:54PM, Daniel Kiper wrote:
>> Call efi_memblock_x86_reserve_range() on native EFI platform only.
>> This is not needed and even it should not be called on platforms
>> which wraps EFI infrastructure like Xen.
>> 
>> Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
>> ---
>>  arch/x86/kernel/setup.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
>> index ce72964..992b67a 100644
>> --- a/arch/x86/kernel/setup.c
>> +++ b/arch/x86/kernel/setup.c
>> @@ -933,7 +933,7 @@ void __init setup_arch(char **cmdline_p)
>>  		set_bit(EFI_64BIT, &x86_efi_facility);
>>  	}
>>  
>> -	if (efi_enabled(EFI_BOOT))
>> +	if (!strncmp((char *)&boot_params.efi_info.efi_loader_signature, "EL", 2))
>>  		efi_memblock_x86_reserve_range();
>>  #endif
> 
> This could do with a little bit more explanation. Why is it not
> necessary to mark the EFI memory map that was passed to the kernel as
> reserved in memblock?

Because that's in memory Dom0 doesn't even see: The EFI memory
map is visible to the hypervisor only.

Jan

