From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Tue, 30 Nov 2021 06:22:23 +0000
Subject: Re: [PATCH RFC 2/4] mm: percpu: Add pcpu_fc_cpu_to_node_fn_t typedef
Message-Id: <17a7ad25-d61d-d23d-29a2-c66ed7db02cc@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211121093557.139034-1-wangkefeng.wang@huawei.com>
 <20211121093557.139034-3-wangkefeng.wang@huawei.com>
 <YaVW8ZNQMUnnoWEB@fedora>
In-Reply-To: <YaVW8ZNQMUnnoWEB@fedora>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dennis Zhou <dennis@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, gregkh@linuxfoundation.org, cl@linux.com, catalin.marinas@arm.com, will@kernel.org, tsbogend@alpha.franken.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, x86@kernel.org


On 2021/11/30 6:40, Dennis Zhou wrote:
> On Sun, Nov 21, 2021 at 05:35:55PM +0800, Kefeng Wang wrote:
>> Add pcpu_fc_cpu_to_node_fn_t and pass it into pcpu_fc_alloc_fn_t,
>> pcpu first chunk allocation will call it to alloc memblock on the
>> corresponding node by it.
>>
>> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
>> ---
>>   arch/mips/mm/init.c            | 12 +++++++++---
>>   arch/powerpc/kernel/setup_64.c | 14 +++++++++++---
>>   arch/sparc/kernel/smp_64.c     |  8 +++++---
>>   arch/x86/kernel/setup_percpu.c | 18 +++++++++++++-----
>>   drivers/base/arch_numa.c       |  8 +++++---
>>   include/linux/percpu.h         |  7 +++++--
>>   mm/percpu.c                    | 14 +++++++++-----
>>   7 files changed, 57 insertions(+), 24 deletions(-)
>>
>> diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
...
>> diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
>> index 6052f5d5ded3..9a5609c821df 100644
>> --- a/arch/powerpc/kernel/setup_64.c
>> +++ b/arch/powerpc/kernel/setup_64.c
>> @@ -771,6 +771,12 @@ void __init emergency_stack_init(void)
>>   }
>>   
>>   #ifdef CONFIG_SMP
>> +
>> +static __init int pcpu_cpu_to_node(int cpu)
>> +{
>> +	return IS_ENABLED(CONFIG_NUMA) ? early_cpu_to_node(cpu) : NUMA_NO_NODE;
>> +}
>> +
>>   /**
>>    * pcpu_alloc_bootmem - NUMA friendly alloc_bootmem wrapper for percpu
>>    * @cpu: cpu to allocate for
>> @@ -784,12 +790,12 @@ void __init emergency_stack_init(void)
>>    * RETURNS:
>>    * Pointer to the allocated area on success, NULL on failure.
>>    */
>> -static void * __init pcpu_alloc_bootmem(unsigned int cpu, size_t size,
>> -					size_t align)
>> +static void * __init pcpu_alloc_bootmem(unsigned int cpu, size_t size, size_t align,
>> +					pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn)
>>   {
>>   	const unsigned long goal = __pa(MAX_DMA_ADDRESS);
>>   #ifdef CONFIG_NUMA
>> -	int node = early_cpu_to_node(cpu);
>> +	int node = cpu_to_nd_fun(cpu);
> ^ typo - cpu_to_nd_fn().

Will fix.

...

>>   	if (rc < 0)
>> diff --git a/include/linux/percpu.h b/include/linux/percpu.h
>> index ae4004e7957e..41bb54715b0c 100644
>> --- a/include/linux/percpu.h
>> +++ b/include/linux/percpu.h
>> @@ -94,8 +94,9 @@ extern const char * const pcpu_fc_names[PCPU_FC_NR];
>>   
>>   extern enum pcpu_fc pcpu_chosen_fc;
>>   
>> -typedef void * (*pcpu_fc_alloc_fn_t)(unsigned int cpu, size_t size,
>> -				     size_t align);
>> +typedef int (pcpu_fc_cpu_to_node_fn_t)(int cpu);
>> +typedef void * (*pcpu_fc_alloc_fn_t)(unsigned int cpu, size_t size, size_t align,
>> +				     pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn);
>>   typedef void (*pcpu_fc_free_fn_t)(void *ptr, size_t size);
>>   typedef void (*pcpu_fc_populate_pte_fn_t)(unsigned long addr);
>>   typedef int (pcpu_fc_cpu_distance_fn_t)(unsigned int from, unsigned int to);
>> @@ -111,6 +112,7 @@ extern void __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>>   extern int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>>   				size_t atom_size,
>>   				pcpu_fc_cpu_distance_fn_t cpu_distance_fn,
>> +				pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn,
>>   				pcpu_fc_alloc_fn_t alloc_fn,
>>   				pcpu_fc_free_fn_t free_fn);
>>   #endif
>> @@ -119,6 +121,7 @@ extern int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>>   extern int __init pcpu_page_first_chunk(size_t reserved_size,
>>   				pcpu_fc_alloc_fn_t alloc_fn,
>>   				pcpu_fc_free_fn_t free_fn,
>> +				pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn,
>>   				pcpu_fc_populate_pte_fn_t populate_pte_fn);
>>   #endif
> Be consistent here. In pcpu_setup_first_chunk() you add the
> cpu_to_node() before alloc()/free() and then in pcpu_embed_first_chunk()
> you add it after. I'd prefer to add it before as to keep the
> cpu_distance()/cpu_to_node() grouping.
Sure, will adjust the order.
