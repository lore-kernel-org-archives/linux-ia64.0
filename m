From: Russ Anderson <rja@sgi.com>
Date: Wed, 15 Sep 2004 21:38:49 +0000
Subject: Re: INIT dumps broken?
Message-Id: <200409152138.i8FLcn0h030312@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
>
> The problem depends on which task is running on the monarch at
> the time of the INIT.  Expanding the SAVE_MIN_WITH_COVER macro
> in ia64_monarch_init_handler, one of the first things done is
> to get "current" ... since MINSTATE_PHYS is defined, we use the
> version that reads:
>    mov reg=IA64_KR(Current);;dep reg=0,reg,61,3
>
> So if our task is anything other than the initial "init_task",
> we'll take a nice region 7 address from ar.k6, and convert to
> physical by zapping bits [63:61].  But we happen to be running
> the init_task, then ar.k6 contains a region 5 address, and we
> create a garbage address by clearing the high bits, which can
> lead to an MCA (if the address points somewhere bad) or to
> stomping on some random place (if the address happens to be a
> legal physical address).
>
> Perhaps MIN_STATE_GET_CURRENT() needs to be smarter and handle
> the region 5 case?  Or perhaps Russ will factor this into a newer
> version of his percpu save area patch????

Correctly understanding the proper way to translate addresses for
the various regions would be the first step.

The top 3 bits of the virtual address is the virtual region number.  

If it is a region 7 (0xe) address, then masking off the top 3 bits 
yields the correct physical address.

If it is a region 5 (0xa) address, then a "tpa" instruction (using 
the TLB) should yield the correct physical address (assuming there is
a valid TLB entry for that virtual address).

Would that be the correct way to translate the addresses?

Are there exceptions, such as region 7 addresses where masking off 
the top 3 bits would not yield the correct physical address?

How should region 5 addresses without a valid TLB mapping be handled?

Are there any other regions that need handling, and if so, how?

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
