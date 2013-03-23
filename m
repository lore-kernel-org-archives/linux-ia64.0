From: Eduardo Cruz <eduardohmdacruz@gmail.com>
Date: Sat, 23 Mar 2013 23:13:34 +0000
Subject: Re: remap kernel static memory to user space
Message-Id: <CAHG_u-mTY0tq4MR3MHWh-Q5uvrpfpRP7T=Y6YtGx2g0ocuT+xA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAHG_u-=ChwiQ72O-9z1eD5Pex-niYMaRwMUOQOryYuPO154G=A@mail.gmail.com>
	<alpine.LNX.2.00.1303231423420.14373@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303231423420.14373@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hughd@google.com>
Cc: Clemens Ladisch <clemens@ladisch.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Man, it worked!
You saved my life kkkkkkkkkkkkkkk.
Thank you very much!

2013/3/23 Hugh Dickins <hughd@google.com>:
> On Wed, 20 Mar 2013, Eduardo Cruz wrote:
>
>> Hello.
>>
>> I'm trying to remap some kernel static memory to user space using
>> remap_pfn_range.
>> For that, I wrote a module that initializes a device, which later I
>> use mknod, etc.
>>
>> When I allocate the memory with kmalloc, everything works:   (where
>> user_space_shared was allocated with kmalloc)
>>
>> if ((ret = remap_pfn_range(vma, vma->vm_start,
>> virt_to_phys(user_space_shared) >> PAGE_SHIFT, length,
>> vma->vm_page_prot)) < 0)
>
> I have no ia64 experience, but my guess is that your problem is with
> that virt_to_phys(user_space_shared).
>
> virt_to_phys() expects to be given an address from the kernel's direct
> map of physical memory; whereas if you declare user_space_shared[] in
> kernel static memory, I believe ia64 places that in a different region.
>
> Try changing that to virt_to_phys(ia64_imva(user_space_shared))
> and I expect it will then work: see comment above ia64_imva()
> in arch/ia64/include/asm/processor.h.
>
> Hugh
>
>>
>> In the application in user space:
>> kstc = mmap(0, sizeof(user_space_shared_t), PROT_READ|PROT_WRITE,
>> MAP_SHARED| MAP_LOCKED, fd, 0);
>>
>> With user_space_shared allocated using kmalloc, it is working.
>> The application is able to read the data I wrote in the kernel module.
>>
>> However, when I define and allocate that var in arch/ia64/mm/fault.c:
>>
>> unsigned char user_space_shared[ sizeof(user_space_shared_t) +
>> PAGE_SIZE ] __attribute__((aligned(PAGE_SIZE)));
>> EXPORT_SYMBOL(user_space_shared);
>>
>> And access that var from the module:
>>
>> extern unsigned char user_space_shared[ sizeof(user_space_shared_t) +
>> PAGE_SIZE ];
>>
>> There is no error message, but I can't read the contents i wrote
>> inside the kernel module from the application.
>>
>> Your help would be appreciated.
>>
>> ps:
>> I am taking care of page offsets/boundaries.
>> I'm using kernel 2.6.32 for ia64.
>>
>>
>> --
>> Eduardo Henrique Molina da Cruz
>> PhD student
>> Parallel and Distributed Processing Group
>> Federal University of Rio Grande do Sul (UFRGS)



-- 
Eduardo Henrique Molina da Cruz
PhD student
Parallel and Distributed Processing Group
Federal University of Rio Grande do Sul (UFRGS)
