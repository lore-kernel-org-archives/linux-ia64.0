From: Smarduch Mario-CMS063 <CMS063@motorola.com>
Date: Wed, 15 Jun 2005 15:34:23 +0000
Subject: 2.4.31 TLB corruption
Message-Id: <A752C16E6296D711942200065BFCB6941D79B9F3@il02exm10>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's the race condition that appears possible. Considering
a context range (for per task RID selection) 1-100. 
The real range is 21 bits wide, and starting context = 300,
resulting in much sparser context selection values and
thus much more difficult to trip.

But for example after next=100 there are the
following context values that exist owned by various tasks:
1,2,10. 

Now on a 2 way system 1  is executing on CPU 0 
and 2 on CPU 1. Both happen to run fork() eventually 
winding up in dup_mmap().

CPU 0 (orig ctxt=1):		CPU 1 (orig ctxt=2):
------				------
- Both call flush_tlb_mm() this sets their mm->context = 0
- eventually both get into activate_context(mm)
                        - grabs ia64_ctx.lock first
				- context wrap around wrap_mmu_contxt()
				  gets called
                        - chooses context=1, limit
                        - flushes local TLB, marks lazy flush needed
                          on 0.
- now acquires ia64_ctx.lock
- chooses context=2 and 
  installs it in its RRs
- appears to resume in user mode with
  matching RID of task running on
  CPU1 (i.e. with its previous
  TLBs with RID=2 installed)	

This whole scheme is complex and elusive I'd appreciate
feedback from this group.

- mario			   
