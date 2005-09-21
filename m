From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 21 Sep 2005 17:47:59 +0000
Subject: RE: MCA/INIT: need to wire CURRENT_STACK?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F047209C2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16451.1127265127@ocs3.ocs.com.au>
In-Reply-To: <16451.1127265127@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I put this comment in arch/ia64/kernel/mca_asm.S, where we switch to
>the MCA/INIT stack.  The code runs fine without wiring
>IA64_KR_CURRENT_STACK and IA64_TR_CURRENT_STACK.  Is that coincidence
>or do the extra registers really need to be updated?  The MCA/INIT
>stacks are initialized early in boot, they are in region 7.

Those registers keep track of which address we have pinned with
DTR[2] so that context switch code (ia64_switch_to) can figure
out whether it needs to reload DTR[2] to map the stack of the
new process.  Since you aren't going to context switch from your
MCA code (I hope!) this should't be an issue.

BUT ... it raises the question of whether you will do anything
in your MCA handler that will run into problems because the stack
is perhaps[1] not pinned ... just mapped by a DTC entry.  I forget
what the exact issue is that led to pinning the stack with DTR[2],
but there is a correctness issue involved.  David: memory jog time??

-Tony

[1] It might be pinned if it is allocated from the same granule
as the stack of the most recently running process on this cpu,
since DTR[2] just maps a whole granule at a time.  You might also
have a DTC mapping active, so skip lightly past the problem in
simple tests.
