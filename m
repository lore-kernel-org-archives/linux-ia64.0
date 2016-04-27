From: Dennis Chen <dennis.chen@linaro.org>
Date: Wed, 27 Apr 2016 11:37:22 +0000
Subject: Re: [PATCH v5 12/14] arm64, acpi, numa: NUMA support based on SRAT and SLIT
Message-Id: <CADKHWadTL5dB__Y-LGtoPs_mQQ+A36nnhwJo3muTC_z9X1FZag@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461116439-22991-1-git-send-email-ddaney.cavm@gmail.com>
 <1461116439-22991-13-git-send-email-ddaney.cavm@gmail.com>
 <CADKHWadFBh2TbyoZSmYJHX24roMQQXf8Kx8rEoLABJ8xaTGL=Q@mail.gmail.com>
 <5720127E.1030307@caviumnetworks.com> <57203A47.9000108@linaro.org>
In-Reply-To: <57203A47.9000108@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hanjun Guo <hanjun.guo@linaro.org>
Cc: David Daney <ddaney@caviumnetworks.com>, David Daney <ddaney.cavm@gmail.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, Ganapatrao Kulkarni <gku>

Hi Hanjun,

Thanks for the clarification and some little comments ;-)

On 27 April 2016 at 12:04, Hanjun Guo <hanjun.guo@linaro.org> wrote:
> Hi Dennis, David,
>
> Sorry for the late reply, please see my comments below.
>
>
> On 2016/4/27 9:14, David Daney wrote:
>>
>> On 04/21/2016 03:06 AM, Dennis Chen wrote:
>>>
>>> On 20 April 2016 at 09:40, David Daney <ddaney.cavm@gmail.com> wrote:
>>
>> [...]
>>>>
>>>> +/* Callback for Proximity Domain -> ACPI processor UID mapping */
>>>> +void __init acpi_numa_gicc_affinity_init(struct
>>>> acpi_srat_gicc_affinity *pa)
>>>> +{
>>>> +       int pxm, node;
>>>> +       u64 mpidr;
>>>> +
>>>> +       if (srat_disabled())
>>>> +               return;
>>>> +
>>>> +       if (pa->header.length < sizeof(struct
>>>> acpi_srat_gicc_affinity)) {
>>>> +               pr_err("SRAT: Invalid SRAT header length: %d\n",
>>>> +                       pa->header.length);
>>>> +               bad_srat();
>>>> +               return;
>>>> +       }
>>>> +
>>>> +       if (!(pa->flags & ACPI_SRAT_GICC_ENABLED))
>>>> +               return;
>>>> +
>>>> +       if (cpus_in_srat >= NR_CPUS) {
>>>> +               pr_warn_once("SRAT: cpu_to_node_map[%d] is too small,
>>>> may not be able to use all cpus\n",
>>>> +                            NR_CPUS);
>>>> +               return;
>>>> +       }
>>>> +
>>>> +       pxm = pa->proximity_domain;
>>>> +       node = acpi_map_pxm_to_node(pxm);
>>>> +
>>>> +       if (node = NUMA_NO_NODE || node >= MAX_NUMNODES) {
>>>> +               pr_err("SRAT: Too many proximity domains %d\n", pxm);
>>>> +               bad_srat();
>>>> +               return;
>>>> +       }
>>>> +
>>>> +       if (get_mpidr_in_madt(pa->acpi_processor_uid, &mpidr)) {
>>>> +               pr_err("SRAT: PXM %d with ACPI ID %d has no valid
>>>> MPIDR in MADT\n",
>>>> +                       pxm, pa->acpi_processor_uid);
>>>> +               bad_srat();
>>>> +               return;
>>>> +       }
>>>> +
>>>> +       early_node_cpu_hwid[cpus_in_srat].node_id = node;
>>>> +       early_node_cpu_hwid[cpus_in_srat].cpu_hwid =  mpidr;
>>>> +       node_set(node, numa_nodes_parsed);
>>>> +       cpus_in_srat++;
>>>> +       pr_info("SRAT: PXM %d -> MPIDR 0x%Lx -> Node %d cpu %d\n",
>>>> +               pxm, mpidr, node, cpus_in_srat);
>>>> +}
>>>
>>>
>>> What does the *cpu* means in above pr_info function? If it's the
>>> logical processor ID or ACPI processor UID, then I suggest to use
>>> pa->acpi_processor_uid instead of cpus_in_srat, I understand the
>
>
> I think print cpus_in_srat is pointless here, as the logic cpu number
> is allocated by OS when initializing SMP by scanning MADT table. As
> Dennis said, it's just a count number, not a number mapping to MPIDR.
>
> ACPI processor UID is the key value to connect MADT, SRAT, DSDT.
>
> For MADT, it will have MPIDR and ACPI processor UID, and OS will
> create mappings to MPIDR and cpu logical number,
> ACPI processor UID <------> MPIDR <------> CPU logical number
>
> In SRAT, there is ACPI processor UID represented, mappings will be
> ACPI processor UID <------> PXM <------> NUMA node logical number
>
> So we can use ACPI processor UID to get the MPIDR by scanning the
> MADT, then we can map NUMA node logical number to cpu logical
> number later.
>
Right, kernel will record the logical cpu index info (begins from 0,
the boot cpu) into the cpu_possible bit map by parsing the MADT GICC
sub-table. So I am thinking here if we can reduce the parsing walk by
only one, because I see the acpi_numa_gicc_affinity_init() calls
get_mpidr_in_madt() to traverse the entire MADT, actually the kernel
will also traverse the MADT in smp_init_cpus(), merge them into one?
>
>>> cpus_in_srat is just a count number of the entries of GICC Affinity
>>> Struct instance in SRAT, correct me if I am wrong. So at least it sees
>>> to me, the above pr_info will output message looks like:
>>> SRAT: PXM 0 -> MPIDR 0x100 -> Node 0 cpu 1
>>> SRAT: PXM 0 -> MPIDR 0x101 -> Node 0 cpu 2
>>> SRAT: PXM 0 -> MPIDR 0x102 -> Node 0 cpu 3
>>>
>>
>> Yes, that is correct, and for my system seems to be what we want as the
>> names in /sys/devices/system/cpu/ and /proc/cpu_info agree with the
>> sequential numbering (0..95) with 48 CPUs on each node.
>
>
> That's because you place CPUs in the same order both in MADT and SRAT :)
> if not, that will be not match.
>
Hmm, I think I made a mistake presumption here that the ACPI processor
UID is the logical processor number, just take a look at the ACPI
processor driver module code, the logic process number should comes
from the bit map. And from the below output message pasted by David,
we can see that his firmware is using MPIDR as the ACPI processor UID,
it's not incorrect implementation according to the ACPI spec...
>
>>
>> If I make the change you suggest, I get :
>> .
>> .
>> .
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x0 -> Node 0 cpu 0
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x1 -> Node 0 cpu 1
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x2 -> Node 0 cpu 2
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x3 -> Node 0 cpu 3
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x4 -> Node 0 cpu 4
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x5 -> Node 0 cpu 5
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x6 -> Node 0 cpu 6
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x7 -> Node 0 cpu 7
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x8 -> Node 0 cpu 8
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x9 -> Node 0 cpu 9
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0xa -> Node 0 cpu 10
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0xb -> Node 0 cpu 11
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0xc -> Node 0 cpu 12
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0xd -> Node 0 cpu 13
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0xe -> Node 0 cpu 14
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0xf -> Node 0 cpu 15
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x100 -> Node 0 cpu 256
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x101 -> Node 0 cpu 257
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x102 -> Node 0 cpu 258
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x103 -> Node 0 cpu 259
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x104 -> Node 0 cpu 260
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x105 -> Node 0 cpu 261
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x106 -> Node 0 cpu 262
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x107 -> Node 0 cpu 263
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x108 -> Node 0 cpu 264
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x109 -> Node 0 cpu 265
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x10a -> Node 0 cpu 266
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x10b -> Node 0 cpu 267
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x10c -> Node 0 cpu 268
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x10d -> Node 0 cpu 269
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x10e -> Node 0 cpu 270
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x10f -> Node 0 cpu 271
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x200 -> Node 0 cpu 512
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x201 -> Node 0 cpu 513
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x202 -> Node 0 cpu 514
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x203 -> Node 0 cpu 515
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x204 -> Node 0 cpu 516
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x205 -> Node 0 cpu 517
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x206 -> Node 0 cpu 518
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x207 -> Node 0 cpu 519
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x208 -> Node 0 cpu 520
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x209 -> Node 0 cpu 521
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x20a -> Node 0 cpu 522
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x20b -> Node 0 cpu 523
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x20c -> Node 0 cpu 524
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x20d -> Node 0 cpu 525
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x20e -> Node 0 cpu 526
>> [    0.000000] ACPI: NUMA: SRAT: PXM 0 -> MPIDR 0x20f -> Node 0 cpu 527
>> [    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10000 -> Node 1 cpu
>> 65536
>> [    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10001 -> Node 1 cpu
>> 65537
>> [    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10002 -> Node 1 cpu
>> 65538
>> [    0.000000] ACPI: NUMA: SRAT: PXM 1 -> MPIDR 0x10003 -> Node 1 cpu
>> 65539
>> .
>> .
>> .
>>
>> Not really what I would want.
>
>
> How about remove the print for "cpu"? it's not the right value we want,
> and we can get such mapping information under in sysfs.
>
I think you may remove the *cpu* in the print, indeed it's pointless.
You can, IMO, use cpu_possible bitmask if you want to get the logical
processor number just as the ACPI processor does. About the
early_node_cpu_hwid, the only reason I can see now is to map logic cpu
into the numa node number, can we refer to the implementation under
x86, anyway I am not sure since not very familiar with that codes
dependency...
>
>>
>>
>>> While the /sys/devices/system/cpu will use the ACPI processor UID to
>>> generate the index of the cpu, like:
>>> cpu0  cpu1  cpu2 ...
>>>
>>> As the GICC Affinity Struct indicated, the ps->proximity_domain is the
>>> domain to which the logical processor belongs...
>
>
> Yes, we can get such information in /sys/devices/system/node, I think
> we can only print:
>
> ACPI: NUMA: SRAT: PXM x -> MPIDR y -> Node z
Agree.
>
>
> Thanks
> Hanjun
>



-- 
Regards,
Dennis
