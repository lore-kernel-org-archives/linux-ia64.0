From: Keith Owens <kaos@sgi.com>
Date: Wed, 21 Sep 2005 22:58:55 +0000
Subject: Re: MCA/INIT: need to wire CURRENT_STACK?
Message-Id: <14241.1127343535@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16451.1127265127@ocs3.ocs.com.au>
In-Reply-To: <16451.1127265127@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 Sep 2005 11:12:58 -0700, 
David Mosberger-Tang <David.Mosberger@acm.org> wrote:
>> BUT ... it raises the question of whether you will do anything
>> in your MCA handler that will run into problems because the stack
>> is perhaps[1] not pinned ... just mapped by a DTC entry.  I forget
>> what the exact issue is that led to pinning the stack with DTR[2],
>> but there is a correctness issue involved.  David: memory jog time??
>
>Any virtually mapped memory that needs to be accessed with PSR.IC=0
>needs to be pinned because otherwise you'd get a nested TLB fault and
>things would go south from there real fast.

The virtual mode handlers are entered with psr.ic=1 and psr.i=0.
External interrupts are blocked until the handlers resume to the
original context.  Internal interrupts like KDB_ENTER() use the
handler's stack in virtual mode with psr.ic=0, but by the time it gets
to ivt.S::non_syscall, the C code has already accessed the handler
stack with psr.ic=1.  Worst case, the first access to the handler stack
in mca.c (which is with psr.ic) will take an alt DTLB fault and drop in
a DTC for the handler stack.

There is a theoretical problem case.  After the DTC for the handler
stack has been loaded, the handler does enough data accesses that its
own DTC is flushed.  Then the handler, without accessing its own stack,
causes an internal interrupt, e.g. KDB_ENTER().  That could cause a
nested DTLB fault.

I can change the mca_asm code to save, modify and restore
IA64_KR_CURRENT_STACK and IA64_TR_CURRENT_STACK around the C handlers.
But that gets awkward if the C code wants to resume to a new context,
the C code would have to set new values for IA64_KR_CURRENT_STACK and
IA64_TR_CURRENT_STACK while it was still using its own stack, which
might open the same problem.

