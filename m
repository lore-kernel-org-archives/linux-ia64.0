From: Jack Steiner <steiner@sgi.com>
Date: Fri, 09 May 2003 19:31:54 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705708@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> On Wed, May 07, 2003 at 04:24:09PM -0700, Luck, Tony wrote:
> > 1) My patch (posted around October last year) which picked virtual addresses
> > in the wild blue yonder (initial versions used 0xe002000000000000, later ones
> > used 0xffffffff00000000) for the link address for the kernel. Elilo can load
> > kernel at any suitably aligned physical address, and head.S establishes the
> > mappings using itr[0] and dtr[0].
> > 
> >  pros) provided separate maps for kernel text and data, so supported kernel text
> >        replication too.
> >  cons) __pa() no longer works on kernel addresses, use new __tpa() instead.
> >        Some ugly runtime patching of kernel code to get physical address of
> >        swapper_pg_dir into the TLB miss code.

The __tpa macros are ugly but they are fully contained within the ia64 part
of the tree. (IIRC, the old scheduler had a reference but the O(1) scheduler doe not).
In our tree, there are currently only 12 references to __tpa. All are
in boottime initialization code., mostly in mca.c.  Although I would 
rather not have __tpa, this doesnt seem too bad.



> > 
> > 2) I think SGI are currently running a modified version of #1 without the text
> > replication support, and that provides a mapping from the normal virtual
> > address that the kernel is linked for (0xe00000000044000000) to whatever physical
> > address it was actually loaded at ... at least I think that's what Jack said.

Right.


> > 
> >  pros) simpler than my patch
> > 
> >  cons) Still needs __tpa() instead of __pa() for kernel addresses.
> > 
> > 3) David's suggestion of boot-time relocation.  Probably simplest to implement
> > this in elilo, but if you are really good at PIC asm code it could be done in
> > the kernel startup sequence.
> > 
> >  pros) Just like linking kernel at a new address.
> >        Avoids the __tpa() issue.
> >        Doesn't invalidate any assumptions about how to get from virtual to
> >        physical addresses and back again.
> > 
> >  cons) Nobody has implemented it.
>          doesn't address text replication concerns, while (1) and (2)
>          do
> 
> So, is there any consensus on the best path to pursue?  Chris Wedgwood
> is working on option #3, and I've got Tony's patch trimmed down to #2
> (with one piece missing--ia64_switch_to runtime patching), but none of
> these are in either 2.4 or 2.5 yet.  Maybe for 2.4 we should do #2 or
> #3 and for 2.5 we could implement #1 with the virtual offsets Tony
> mentioned earlier?

As far as I can tell, #1 is the only solution that will support kernel text replication.
We did experiments to measure the effect of kernel text replication. On AIM7,
(granted, not the best benchmark), we see a small but consistent
improvement in performance with text replication enabled. (Data attached below).
The biggest difference is cputime, not throughput.

This was from a relatively small system with very good remote-to-local latency
ratios. As system sizes increase, I expect the benefit of text replication will
increase.

I think that whatever solution is adopted, it need to accommadate text replication.


If we are going to do #1 for 2.5, it seems like #2 is the best solution for 2.4.

#3 requires changes elilo & the way System.map is used. These changes wont apply
to 2.5. #3 also will introduce some confusion since the System.map that is 
generated at build time cant be used without knowing the physical address 
where elilo actually loaded the kernel.  The address could change based on minor
changes in the configuration (amount of memory, devices, nodes, etc).


------

AIM7
Kernel Text replication:
        Tasks   Jobs/Min        JTI     Real    CPU     Jobs/sec/task
        200     18110.2         84      64.3    619.6   1.5092
        500     23932.5         76      121.6   2947.1  0.7977
        1000    24402.0         71      238.5   9890.6  0.4067
        2000    23895.4         71      487.1   25537.8 0.1991
        3000    22848.8         75      764.2   42549.7 0.1269
        4000    20420.4         78      1140.0  64237.4 0.0851
 
Baseline
        Tasks   Jobs/Min        JTI     Real    CPU     Jobs/sec/task
        200     18008.8         84      64.6    624.1   1.5007
        500     23102.2         76      126.0   4238.1  0.7701                                      
        1000    23886.4         71      243.7   10507.3 0.3981                                      
        2000    23669.9         72      491.8   26120.2 0.1972                                      
        3000    22344.9         75      781.4   42965.0 0.1241
        4000    20256.9         78      1149.2  64711.0 0.0844                                      

	
> 
> Thanks,
> Jesse
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


