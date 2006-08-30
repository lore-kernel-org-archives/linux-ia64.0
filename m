From: Jay Lan <jlan@sgi.com>
Date: Wed, 30 Aug 2006 01:37:59 +0000
Subject: Re: [Fastboot] IA64 Kdump patch V3
Message-Id: <44F4EBF7.9060909@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44F4E94E.8090700@sgi.com>
In-Reply-To: <44F4E94E.8090700@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jay Lan wrote:
> Jay Lan wrote:
> 
>> Hi Nanhai,
>>
>> There is a problem in sn2. The sn2 does not have any memory with
>> a predictible offset. It is not possible to specify a memory location
>> at boot.
>>
>> I modified the efi_initialize_iomem_resources() routine in
>> arch/ia64/kernel/efi.c to calculate crashk_res.start and .end on the
>> fly and uses the "A" of crashkernel=A@B as size to find a region
>> that fits.
>>
>> Maybe we should separate A and B as two options?
> 
> 
> The "B" part of the crashkernel boot option is meaningless to sn2
> machine and can be very confusing to sn2 users.
> 
>>
>> I now have memory reserved, but kernal hanged when executing 'kexec'
>> command. There must be similar issues in kexec.
> 
> 
> On further debugging, the kexec dumped core instead at this statement:
> +        elf_rel_set_symbol(&info->rhdr, "__boot_param_base",
> +                        &boot_param_base, sizeof(long));
> 
> of elf_ia64_load() in kexec/arch/ia64/kexec-elf-ia64.c.

Well, need a bit of clarification. :) The code hits a die() since
elf_rel_find_symbol() returned -1. The die() routine would do an
exit(1), but i changed die() to force a core dump to examine the
memory.

Regards,
  - jay


> 
> Examing the memory i found "__boot_param_base" indeed not present in
> the symbol table.
> 
> It seems that purgatory/arch/ia64/entry.S does not have a line
> +DECLARE_DATAB(____boot_param_base).
> Is it not needed in other ia64 machines? How does it work in HP
> machines?
> 
> Thanks,
>  - jay
> 
> 
