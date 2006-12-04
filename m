From: Jay Lan <jlan@sgi.com>
Date: Mon, 04 Dec 2006 17:05:38 +0000
Subject: Re: [Fastboot] IA64: kexec seg fault at xrealloc
Message-Id: <45745562.5000109@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061204110510.fde8bcdb.akiyama.nobuyuk@jp.fujitsu.com>
In-Reply-To: <20061204110510.fde8bcdb.akiyama.nobuyuk@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Nan-hai and Akiyama San,

Thanks for your patch. Nan-hai's patch fixed the problem!

Cheers,
 - jay


Zou Nan hai wrote:
> On Mon, 2006-12-04 at 10:05, Akiyama, Nobuyuki wrote:
>> Hi Jay,
>>
>> The attacked patch fixes the problem.
>> Please try.
>>
>> diff -Nurp kexec-tools-1.101.org/kexec/arch/ia64/crashdump-ia64.c
>> kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c
>> --- kexec-tools-1.101.org/kexec/arch/ia64/crashdump-ia64.c     
>> 2006-11-09 19:40:52.000000000 +0900
>> +++ kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c  2006-11-13
>> 19:17:15.000000000 +0900
>> @@ -316,9 +316,13 @@ int load_crashdump_segments(struct kexec
>>         int nr_ranges;
>>         size_t size;
>>         void *tmp;
>> +       long int nr_cpus = 0;
>> +       if ((nr_cpus = sysconf(_SC_NPROCESSORS_CONF)) < 0)
>> +               return -1;
>>         if (info->kexec_flags & KEXEC_ON_CRASH ) {
>>                 if (get_crash_memory_ranges(&mem_range, &nr_ranges) =
>> 0) {
>>                         size =  sizeof(Elf64_Ehdr) +
>> +                               (nr_cpus + 1) * sizeof(Elf64_Phdr) +
>>                                 (nr_ranges + 1) * sizeof(Elf64_Phdr);
>>                         size = (size + EFI_PAGE_SIZE - 1) &
>> ~(EFI_PAGE_SIZE - 1);
>>                         tmp = xmalloc(size);
>>
> 
>  Hi, 
> 	Thanks for finding the is bug, I missed percpu notes segments in size
> calculation here. However I think we should also include the nr_ranges
> in calculation.
> 
> 	--- a/kexec/arch/ia64/crashdump-ia64.c	2006-12-04 04:19:42.000000000 -0500
> +++ b/kexec/arch/ia64/crashdump-ia64.c	2006-12-04 04:21:23.000000000 -0500
> @@ -313,13 +313,15 @@ int load_crashdump_segments(struct kexec
>  {
>  	//struct memory_range *mem_range, *memmap_p;
>  	struct memory_range *mem_range;
> -	int nr_ranges;
> +	int nr_ranges, nr_cpus;
>  	size_t size;
>  	void *tmp;
> +        if ((nr_cpus = sysconf(_SC_NPROCESSORS_CONF)) < 0)
> +		return -1;
>  	if (info->kexec_flags & KEXEC_ON_CRASH ) {
>  		if (get_crash_memory_ranges(&mem_range, &nr_ranges) = 0) {
>  			size =  sizeof(Elf64_Ehdr) +
> -				(nr_ranges + 1) * sizeof(Elf64_Phdr);
> +				(nr_ranges + nr_cpus + 1) * sizeof(Elf64_Phdr);
>  			size = (size + EFI_PAGE_SIZE - 1) & ~(EFI_PAGE_SIZE - 1);
>  			tmp = xmalloc(size);
>  			memset(tmp, 0, size);
> 
> 
>  
>  Thanks
>  Zou Nan hai
> 
>> Thanks,
>> Akiyama, Nobuyuki
>>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

