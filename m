From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 10 Nov 2005 23:30:39 +0000
Subject: RE: [Patch 1/1] 4-level page tables v4.
Message-Id: <200511102330.jAANUdg21565@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Thursday, November 10, 2005 2:39 PM
> On Thu, Nov 10, 2005 at 01:49:26PM -0800, Luck, Tony wrote:
> > Compiling with three levels, I see some differences in the scheduling
> > of instructions in the vhpt_miss handler and the nested_dtlb miss
> > handler.  Side-by-side diff of a disassembly included below (original
> > sequence is on the left, new sequence is on the right).  For the vhpt
> > case the new handler is 3 instructions shorter ... but shorter isn't
> > always better.
> 
> I used the objdump that Jack Steiner pointed me towards to optomize the
> vhpt_miss handler and then test.  This instruction order gave the best
> performance, but we are talking extremely small differences.
> 
> Is the goal to make these identical?  If so, it should be easy to do,
> but I was not aware that was the intent.

I was wondering earlier too why you changed all the register usage etc.
You really don't need to make that big of change since the resource
contention is around dep/cmp.  cmp instruction is ALU type and can be
schedule on all 6 integer units.  The easiest way is to just re-order
these two instructions.  There is one change you made around tbit/dep on
line 163 (dep r23=0,r20,0,PAGE_SHIFT), but that is outside the 4-level
page table walk.  And again, easiest thing to do is to pull that ins 2
bundle earlier.

- Ken

