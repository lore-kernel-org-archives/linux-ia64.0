From: Russ Anderson <rja@sgi.com>
Date: Wed, 17 Nov 2004 17:47:51 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <200411171747.iAHHlpS3110348@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> >Can you remind me why k3?  Are you worried about the TR mapping the
> >per-CPU region getting corrupted?
> 
> This isn't for correctness, or even efficiency (since this is a
> very low frequency execution path).  It is just to make the code
> easier to read and maintain.  The current code in the MCA path that
> loops through the array of tlb info structures looking for the
> one that matches the current cpus cr.lid is quite ugly.  Replicating
> it in the INIT code to find the per-cpu save+stack area will add
> to the ugliness.  Having the phys address of the per-cpu area in
> ar.k3 would clean things up.
> 
> For the INIT case it would be safe to just "tpa" a per-cpu address,
> but in the MCA case we shouldn't trust the TR mapping.

So one way to hide the uglyness is to put it in a macro, such 
as in the example at the bottom.

That cleans up the current place (in mca_asm.S) where it is called to be:

        // The following code purges TC and TR entries. Then reload all TC entries.
        // Purge percpu data TC entries.
begin_tlb_purge_and_reload:
        MCA_SAVE_AREA_PTR(r2, lbl1, err);;
        addl    r2=IA64_MCA_TLB_INFO,r2;;
        mov     r17=r2
        ;;

One technical concern is that the routine uses r16, r17, r18, r19, r20.
Optimizing is may squeeze out a couple but the bigger question is what
scratch registers are available?  Specificly, ia64_os_mca_proc_state_dump
saves off r16+ registers, so it would be good not to trash them before they
are saved.  

Other than that issue, it looks like a macro could be used instead of k3.

----------------------------------------------------------------------
/*
 * MCA_SAVE_AREA_PTR() gets the physical address pointer to this cpus
 * MCA/INIT save area.
 *      paddr (register) ends up holding the physical address.
 */

#define MCA_SAVE_AREA_PTR(paddr, tlbl, tmperr)                  \
        mov r16=cr.lid;;                                        \
        LOAD_PHYSICAL(p0,r17,ia64_mca_tlb_list);;               \
        mov r19=0;;                                             \
        mov r20=NR_CPUS;;                                       \
tlbl:   cmp.eq p6,p7=r19,r20;;                                  \
(p6)    br.spnt.few tmperr;;                                    \
        ld8 r18=[r17],IA64_MCA_TLB_INFO_SIZE;;                  \
        add r19=1,r19;;                                         \
        cmp.eq p6,p7=r18,r16;;                                  \
(p7)    br.sptk.few 1b;;                                        \
        adds r17=-IA64_MCA_TLB_INFO_SIZE,r17;;                  \
        mov paddr = r17;;
----------------------------------------------------------------------

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
