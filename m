From: Andrew Morton <akpm@osdl.org>
Date: Thu, 13 Nov 2003 03:31:24 +0000
Subject: Re: Inefficient TLB flushing
Message-Id: <marc-linux-ia64-106869408221123@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106866775025427@msgid-missing>
In-Reply-To: <marc-linux-ia64-106866775025427@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner <steiner@sgi.com> wrote:
>
> > Either that, or add a new interface function
>  > 
>  > 	int mmu_gather_is_full_mm(mmu_gather *tlb);
>  > 
>  > and use it...
>  > 
> 
>  How implementation independent should it be? Currently, there is only one
>  field in the mmu_gather structure that must be preserved. However, if we
>  want to make the interface truly implementation independent, it seems
>  like we should define something like:
> 
>  	if (need_resched()) {
>  		struct mmu_gather_state state;
>  		tlb_mmu_gather_save_state(*tlbp, &state);
>  		tlb_finish_mmu(*tlbp, tlb_start, start);
>  		...
>  		*tlbp = tlb_mmu_gather_restore_state(&state);
>  	}
> 
>  Is this overkill?

Think so ;) The `full_mm_flush' boolean is the only state thing we can pass
into tlb_gather_mmu anyway.

> 
>  Should we use the patch given above for 2.6.0 & replace it with an implementation 
>  independent interface for 2.6.1?

Just the little wrapper which doesn't assume the presence of
mmu_gather.full_mm should suffice.

