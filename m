From: Smarduch Mario-CMS063 <CMS063@motorola.com>
Date: Tue, 21 Jun 2005 21:22:50 +0000
Subject: RE: 2.4.31 TLB corruption
Message-Id: <A752C16E6296D711942200065BFCB6941D79BA22@il02exm10>
List-Id: <linux-ia64.vger.kernel.org>
References: <A752C16E6296D711942200065BFCB6941D79B9F3@il02exm10>
In-Reply-To: <A752C16E6296D711942200065BFCB6941D79B9F3@il02exm10>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

FYI, shrinking the RID range does reproduce the
problem easily. Its also reproducable on 2.6.7.

- Mario

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
Sent: Wednesday, June 15, 2005 11:26 AM
To: Smarduch Mario-CMS063
Cc: linux-ia64@vger.kernel.org
Subject: Re: 2.4.31 TLB corruption


It does look to me like there is a race-condition between
delayed_tlb_flush() and wrap_mmu_context().  I can't say I have seen of heard any such problem on 2.6, but a worthwhile experiment to try might be to claim an artifically small number of region-ids (8 or 16 should be enough).  That way, wrap_mmu_context() will be called much more frequently and it should be easier to demonstrate any problems.

	--david

>>>>> On Wed, 15 Jun 2005 10:34:23 -0500, Smarduch Mario-CMS063 
>>>>> <CMS063@motorola.com> said:

  Mario> Here's the race condition that appears possible. Considering
  Mario> a context range (for per task RID selection) 1-100.  The real
  Mario> range is 21 bits wide, and starting context = 300, resulting
  Mario> in much sparser context selection values and thus much more
  Mario> difficult to trip.

  Mario> But for example after next=100 there are the following
  Mario> context values that exist owned by various tasks: 1,2,10.

  Mario> Now on a 2 way system 1 is executing on CPU 0 and 2 on CPU
  Mario> 1. Both happen to run fork() eventually winding up in
  Mario> dup_mmap().

  Mario> CPU 0 (orig ctxt=1): CPU 1 (orig ctxt=2): ------ ------ -
  Mario> Both call flush_tlb_mm() this sets their mm->context = 0 -
  Mario> eventually both get into activate_context(mm) - grabs
  Mario> ia64_ctx.lock first - context wrap around wrap_mmu_contxt()
  Mario> gets called - chooses context=1, limit - flushes local
  Mario> TLB, marks lazy flush needed on 0.  - now acquires
  Mario> ia64_ctx.lock - chooses context=2 and installs it in its RRs
  Mario> - appears to resume in user mode with matching RID of task
  Mario> running on CPU1 (i.e. with its previous TLBs with RID=2
  Mario> installed)

  Mario> This whole scheme is complex and elusive I'd appreciate
  Mario> feedback from this group.

  Mario> - mario - To unsubscribe from this list: send the line
  Mario> "unsubscribe linux-ia64" in the body of a message to
  Mario> majordomo@vger.kernel.org More majordomo info at
  Mario> http://vger.kernel.org/majordomo-info.html
