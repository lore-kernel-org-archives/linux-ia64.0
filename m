From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Sep 2004 20:48:55 +0000
Subject: RE: RFC - freeing up ar.k5
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020963B7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I certainly do not object to using ar.k5 for a percpu physical 
>address pointer.  
>
>Just to understand the rest, I assume this means:
>
>  * The ia64_mca_tlb_list[] array goes away and each cpu will have a 
>    ia64_mca_tlb_info structure (a physical address pointer to 
>the structure 
>    being in ar.k5).  The memory for each structure will be 
>allocated on
>    the same node as the CPU.
>
>  * A physcial address pointer to the per data MCA/INIT area added to 
>    the ia64_mca_tlb_info structure.
>
>  * Then whe an MCA or INIT occurs, the pointer is waiting in ar.k5.

I think that the whole ia64_mca_tlb_info structure could be cleaned
away:

        u64     cr_lid;
was just used as an index to find the right entry.
        u64     percpu_paddr;
is now in ar.k5
        u64     ptce_base;
is a copy of what is in the cpuinfo_64 structure, which should now
be easy to access as an offset from ar.k5
        u32     ptce_count[2];
ditto
        u32     ptce_stride[2];
ditto
        u64     pal_paddr;
need a percpu variable for this
        u64     pal_base;
and for this one too.

The pointers to the per-cpu MCA/INIT save areas would become
percpu variables too, accessed as an offset from ar.k5

*BUT*, I'm still contemplating this whole "free up ar.k5" patch.
So don't spend your whole weekend implementing this because I
might throw the patch away if someone comes up with some figures
that context switch is 0.4% slower because of this patch.

-Tony
