From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Aug 2005 19:22:46 +0000
Subject: RE: ip_contrack module refuses to load...
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0443A5FA@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>> so all the
>> space allocation, mapping, and relocation code should be the same
>> for UP and SMP ... shouldn't they?
>
>No, in the UP case, we can simply map the per-CPU section in the
>kernel image whereas in the SMP case, each CPU needs its own copy of
>the per-CPU section.  To see this, look for per_cpu_init(): in the SMP
>case, it copies the section, in the UP-case, it simply returns
>__phys_per_cpu_start (a pointer into the per-CPU section).

You are (as usual) correct.

But this shouldn't make any difference for the module loading
case ... whether the memory backing the per-cpu area is physically
within a special section in the kernel data, or allocated from
__alloc_bootmem() in a big array for all cpus (mm/contig.c case),
or done in scattered allocations across nodes (mm/discontig.c case).
So, if the module loader has special UP code, then it shouldn't.

-Tony 
