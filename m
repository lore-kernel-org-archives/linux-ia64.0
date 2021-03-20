From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sat, 20 Mar 2021 19:02:35 +0000
Subject: Re: [PATCH] ia64: Ensure proper NUMA distance and possible map initialization
Message-Id: <2bcb5146-4142-05c5-1b44-18a69118ee19@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210318130617.896309-1-valentin.schneider@arm.com>
 <3c421868-d6a8-1da2-f876-49b6374270dc@physik.fu-berlin.de>
 <20210319191059.2a776cb8@sf>
In-Reply-To: <20210319191059.2a776cb8@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: Valentin Schneider <valentin.schneider@arm.com>, linux-kernel@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, debian-ia64 <debian-ia64@lists.debian.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Anatoly Pugachev <matorola@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 3/19/21 8:10 PM, Sergei Trofimovich wrote:
> On Fri, 19 Mar 2021 15:47:09 +0100
> John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:
> 
>> Hi Valentin!
>>
>> On 3/18/21 2:06 PM, Valentin Schneider wrote:
>>> John Paul reported a warning about bogus NUMA distance values spurred by
>>> commit:
>>>
>>>   620a6dc40754 ("sched/topology: Make sched_init_numa() use a set for the deduplicating sort")
>>>
>>> In this case, the afflicted machine comes up with a reported 256 possible
>>> nodes, all of which are 0 distance away from one another. This was
>>> previously silently ignored, but is now caught by the aforementioned
>>> commit.
>>>
>>> The culprit is ia64's node_possible_map which remains unchanged from its
>>> initialization value of NODE_MASK_ALL. In John's case, the machine doesn't
>>> have any SRAT nor SLIT table, but AIUI the possible map remains untouched
>>> regardless of what ACPI tables end up being parsed. Thus, !online &&
>>> possible nodes remain with a bogus distance of 0 (distances \in [0, 9] are
>>> "reserved and have no meaning" as per the ACPI spec).
>>>
>>> Follow x86 / drivers/base/arch_numa's example and set the possible map to
>>> the parsed map, which in this case seems to be the online map.
>>>
>>> Link: http://lore.kernel.org/r/255d6b5d-194e-eb0e-ecdd-97477a534441@physik.fu-berlin.de
>>> Fixes: 620a6dc40754 ("sched/topology: Make sched_init_numa() use a set for the deduplicating sort")
>>> Reported-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
>>> Signed-off-by: Valentin Schneider <valentin.schneider@arm.com>
>>> ---
>>> This might need an earlier Fixes: tag, but all of this is quite old and
>>> dusty (the git blame rabbit hole leads me to ~2008/2007)
>>>
>>> Alternatively, can we deprecate ia64 already?
>>> ---
>>>  arch/ia64/kernel/acpi.c | 7 +++++--
>>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
>>> index a5636524af76..e2af6b172200 100644
>>> --- a/arch/ia64/kernel/acpi.c
>>> +++ b/arch/ia64/kernel/acpi.c
>>> @@ -446,7 +446,8 @@ void __init acpi_numa_fixup(void)
>>>  	if (srat_num_cpus = 0) {
>>>  		node_set_online(0);
>>>  		node_cpuid[0].phys_id = hard_smp_processor_id();
>>> -		return;
>>> +		slit_distance(0, 0) = LOCAL_DISTANCE;
>>> +		goto out;
>>>  	}
>>>  
>>>  	/*
>>> @@ -489,7 +490,7 @@ void __init acpi_numa_fixup(void)
>>>  			for (j = 0; j < MAX_NUMNODES; j++)
>>>  				slit_distance(i, j) = i = j ?
>>>  					LOCAL_DISTANCE : REMOTE_DISTANCE;
>>> -		return;
>>> +		goto out;
>>>  	}
>>>  
>>>  	memset(numa_slit, -1, sizeof(numa_slit));
>>> @@ -514,6 +515,8 @@ void __init acpi_numa_fixup(void)
>>>  		printk("\n");
>>>  	}
>>>  #endif
>>> +out:
>>> +	node_possible_map = node_online_map;
>>>  }
>>>  #endif				/* CONFIG_ACPI_NUMA */
>>>  
>>>   
>>
>> Tested-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
>>
>> Could you send this patch through Andrew Morton's tree? The ia64 port currently
>> has no maintainer, so we have to use an alternative tree.
>>
>> @Sergei: Could you test/ack this patch as well?
> 
> Booted successfully without problems on rx3600.
> 
> Tested-by: Sergei Trofimovich <slyfox@gentoo.org>

Great, thanks!

@Andrew: Could you pick up this patch through your tree?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
