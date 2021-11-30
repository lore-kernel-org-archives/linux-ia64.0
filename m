From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Tue, 30 Nov 2021 06:27:24 +0000
Subject: Re: [PATCH RFC 3/4] mm: percpu: Add generic pcpu_fc_alloc/free funciton
Message-Id: <ab9b7446-e955-67da-b9f3-1e1c15566fdb@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211121093557.139034-1-wangkefeng.wang@huawei.com>
 <20211121093557.139034-4-wangkefeng.wang@huawei.com>
 <YaVYGCB+I7QLZo0+@fedora>
In-Reply-To: <YaVYGCB+I7QLZo0+@fedora>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Dennis Zhou <dennis@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, gregkh@linuxfoundation.org, cl@linux.com, catalin.marinas@arm.com, will@kernel.org, tsbogend@alpha.franken.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, x86@kernel.org


On 2021/11/30 6:45, Dennis Zhou wrote:
> On Sun, Nov 21, 2021 at 05:35:56PM +0800, Kefeng Wang wrote:
>> With previous patch, we could add a generic pcpu first chunk
>> allocation and free function to cleanup the duplicated definations
>> on each architecture.
>>
>> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
>> ---
>>   arch/mips/mm/init.c            | 16 +--------
>>   arch/powerpc/kernel/setup_64.c | 51 ++------------------------
>>   arch/sparc/kernel/smp_64.c     | 50 +-------------------------
>>   arch/x86/kernel/setup_percpu.c | 59 +-----------------------------
>>   drivers/base/arch_numa.c       | 19 +---------
>>   include/linux/percpu.h         |  9 +----
>>   mm/percpu.c                    | 66 ++++++++++++++++++----------------
>>   7 files changed, 42 insertions(+), 228 deletions(-)
...
>> diff --git a/include/linux/percpu.h b/include/linux/percpu.h
>> index 41bb54715b0c..d73c97ef4ff4 100644
>> --- a/include/linux/percpu.h
>> +++ b/include/linux/percpu.h
>> @@ -95,9 +95,6 @@ extern const char * const pcpu_fc_names[PCPU_FC_NR];
>>   extern enum pcpu_fc pcpu_chosen_fc;
>>  =20
>>   typedef int (pcpu_fc_cpu_to_node_fn_t)(int cpu);
>> -typedef void * (*pcpu_fc_alloc_fn_t)(unsigned int cpu, size_t size, siz=
e_t align,
>> -				     pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn);
>> -typedef void (*pcpu_fc_free_fn_t)(void *ptr, size_t size);
>>   typedef void (*pcpu_fc_populate_pte_fn_t)(unsigned long addr);
>>   typedef int (pcpu_fc_cpu_distance_fn_t)(unsigned int from, unsigned in=
t to);
>>  =20
>> @@ -112,15 +109,11 @@ extern void __init pcpu_setup_first_chunk(const st=
ruct pcpu_alloc_info *ai,
>>   extern int __init pcpu_embed_first_chunk(size_t reserved_size, size_t =
dyn_size,
>>   				size_t atom_size,
>>   				pcpu_fc_cpu_distance_fn_t cpu_distance_fn,
>> -				pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn,
>> -				pcpu_fc_alloc_fn_t alloc_fn,
>> -				pcpu_fc_free_fn_t free_fn);
>> +				pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn);
>>   #endif
>>  =20
>>   #ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
>>   extern int __init pcpu_page_first_chunk(size_t reserved_size,
>> -				pcpu_fc_alloc_fn_t alloc_fn,
>> -				pcpu_fc_free_fn_t free_fn,
>>   				pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn,
>>   				pcpu_fc_populate_pte_fn_t populate_pte_fn);
>>   #endif
>> diff --git a/mm/percpu.c b/mm/percpu.c
>> index 3f6cf1ff0be2..efaa1cbaf73d 100644
>> --- a/mm/percpu.c
>> +++ b/mm/percpu.c
>> @@ -2992,6 +2992,30 @@ static struct pcpu_alloc_info * __init __flatten =
pcpu_build_alloc_info(
>>  =20
>>   	return ai;
>>   }
>> +
>> +static void * __init pcpu_fc_alloc(unsigned int cpu, size_t size, size_=
t align,
>> +				   pcpu_fc_cpu_to_node_fn_t cpu_to_nd_fn)
>> +{
>> +	const unsigned long goal =3D __pa(MAX_DMA_ADDRESS);
>> +	int node =3D NUMA_NO_NODE;
>> +	void *ptr;
>> +
>> +	if (cpu_to_nd_fn)
>> +		node =3D cpu_to_nd_fn(cpu);
>> +
>> +	if (node =3D NUMA_NO_NODE || !node_online(node) || !NODE_DATA(node)) {
>> +		ptr =3D memblock_alloc_from(size, align, goal);
>> +	} else {
>> +		ptr =3D memblock_alloc_try_nid(size, align, goal,
>> +					     MEMBLOCK_ALLOC_ACCESSIBLE, node);
>> +	}
>> +	return ptr;
>> +}
> My preference here would be to keep this identical to the x86
> implementation where we #ifdef CONFIG_NUMA.

I will add back '#ifdef CONFIG_NUMA',=C2=A0 also will add back the=20
pr_debug/pr_info part as x86 does,

> Overall this makes sense.
>
> Thanks,
> Dennis
> .
