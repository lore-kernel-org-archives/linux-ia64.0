From: Mike Travis <travis@sgi.com>
Date: Tue, 21 Oct 2008 13:53:04 +0000
Subject: Re: [PATCH 18/35] cpumask: add nr_cpumask_bits
Message-Id: <48FDDEC0.9040903@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com> <20081020170322.090531000@polaris-admin.engr.sgi.com> <200810212326.10278.rusty@rustcorp.com.au>
In-Reply-To: <200810212326.10278.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Rusty Russell wrote:
> On Tuesday 21 October 2008 04:03:37 Mike Travis wrote:
>> When nr_cpu_ids is set to CONFIG_NR_CPUS then references to nr_cpu_ids
>> will return the maximum index of the configured NR_CPUS (+1) instead
>> of the maximum index of the possible number of cpus (+1).  This results
>> in extra unused memory being allocated by functions that are setting up
>> arrays of structs to keep track of per cpu items.
> 
> 1) I like the name in this context: it's a beacon of sanity after NR_CPUS and
>    nr_cpu_ids.  But it's not so clearly a win when general code uses it:
> 
> 	if (cpumask_first(mymask) = nr_cpumask_bits) ...
> 
>    vs:
>    
> 	if (cpumask_first(mymask) = nr_cpu_ids) ...

I think the correct use for iterators would be:

	if (cpumask_first(mymask) >= nr_cpu_ids)

... since nr_cpu_ids is guaranteed to be <= nr_cpumask_bits.  And nr_cpumask_bits
is not really meant to be used anywhere except in the bit operations supporting
the cpumask_* operators.

> 2) This breaks anyone who tests that the iterators etc. return = nr_cpu_ids.

I think that's broken anyways... ;-)

>    One of the other patches tried to change them from NR_CPUS to nr_cpu_ids,
>    that should now be revisited & reaudited.

The change from NR_CPUS to nr_cpu_ids is ok, but it should also be changed from:

	(x = NR_CPUS)
to:
	(x <= nr_cpu_ids)
 
> 3) Noone should be naively allocating "* nr_cpu_ids" arrays, they should be
>    using per-cpu pointers.  Not doing so wastes memory on non-contiguous
>    processor systems.

The problem often arises where an array is allocated that will use the
cpu as an index into the array.  They can be changed eventually to use a
percpu pointer, but in the interim keeping nr_cpu_ids intact maintains
compatibility without allocating unused memory.

> 4) It should be a constant not be dependent on CONFIG_CPUMASK_OFFSTACK, but
>    rather as it was on NR_CPUS > BITS_PER_LONG.  I think that's the sweet
>    spot, and should also make your 2MB "gain" vanish.

I'll run the test again but most likely the result will be an extra 1Mb of
unused memory instead. ;-)  One other note, that test compile used the default
config [and NR_CPUS8] which turns off a lot of functions.  A typical distro
config will have many more options turned on.

And the beauty of using a separate flag to enable variable length cpumasks,
is there may be cases where an arch or specific system config wants a multiple
word cpumask on the stack for performance reasons (like cache or node locality,
avoidance of the kmalloc's, etc.)

> That's why I suggested a max_possible_cpu() function, and using that for those 
> who really want to do allocations, who should be audited anyway, see (3).  I 
> don't want it as prominent as nr_cpu_ids, which is usually the Right Thing, 
> and always safe.

We could change all refs from nr_cpu_ids to max_possible_cpu but wouldn't
we still be leaving a window open where it could be incorrectly used?
So far all the cpumask conversions allow for "mixed-use" cpumask (i.e.,
cpumask_t and struct cpumask *) by maintaining backwards compatility,
until everything is eventually sorted out.  Keeping nr_cpu_ids representing
the same value maintains this "compatibility bridge".

The most correct way would be to use the (not yet implemented) zero
based PERCPU allocator.  Slightly less efficient would be to allocate
node local memory for each struct, in a loop using a per cpu pointer
and "for_each_possible_cpu()".

> Cheers,
> Rusty.
> PS.  I have part of a patch for this...

But as I've said, it's not critical to the new functionality...

Thanks!
Mike
