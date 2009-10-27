From: Jiri Kosina <jkosina@suse.cz>
Date: Tue, 27 Oct 2009 10:03:24 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.LSU.2.00.0910271044250.19847@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <4ADD48D1.1040701@kernel.org> <alpine.LSU.2.00.0910200756300.8582@wotan.suse.de> <4ADD54D4.70808@kernel.org>
 <4ADD5530.3050107@kernel.org> <alpine.LSU.2.00.0910200826220.8582@wotan.suse.de> <4ADDC69A.5000701@suse.com> <4ADDCDED.6060706@suse.com> <20091026201651.GD24682@elte.hu>
In-Reply-To: <20091026201651.GD24682@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Jeff Mahoney <jeffm@suse.com>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Mon, 26 Oct 2009, Ingo Molnar wrote:

> > -struct update_shares_data {
> > -	unsigned long rq_weight[NR_CPUS];
> > -};
> > -
> > -static DEFINE_PER_CPU(struct update_shares_data, update_shares_data);
> > +unsigned long *update_shares_data;
> 
> That should be __read_mostly - this can be a hotly accessed data 
> structure of the scheduler - if it happens to go next to a frequently 
> bouncing variable that can be bad for performance.

Good point, will resend with this annotation added.

> > -				    struct update_shares_data *usd)
> > +				    unsigned long *usd)
> 
> I dont think using usd[cpu] is clearer than usd->rq_weight[cpu]. At 
> minimum it should be renamed to usd_rq_weight not usd.

OK.

> >  	local_irq_save(flags);
> > -	usd = &__get_cpu_var(update_shares_data);
> > +	usd = per_cpu_ptr(update_shares_data, smp_processor_id());
> 
> Could we please have a look at the before/after assembly of this 
> sequence on x86, to make sure the claims in this thread are true and we 
> dont lose performance? (and included it in the changelog with a 
> resubmission - with a new, changed '[PATCH] ...' subject line, not 
> hidden inside a discussion thread.)

Just for completness (I will include it in the changelog with the next 
resubmission shortly):


Before:

...
ffffffff8104337c:       65 48 8b 14 25 20 cd    mov    %gs:0xcd20,%rdx
ffffffff81043383:       00 00
ffffffff81043385:       48 c7 c0 00 e1 00 00    mov    $0xe100,%rax
ffffffff8104338c:       48 c7 45 a0 00 00 00    movq   $0x0,-0x60(%rbp)
ffffffff81043393:       00
ffffffff81043394:       48 c7 45 a8 00 00 00    movq   $0x0,-0x58(%rbp)
ffffffff8104339b:       00
ffffffff8104339c:       48 01 d0                add    %rdx,%rax
ffffffff8104339f:       49 8d 94 24 08 01 00    lea    0x108(%r12),%rdx
ffffffff810433a6:       00
ffffffff810433a7:       b9 ff ff ff ff          mov    $0xffffffff,%ecx
ffffffff810433ac:       48 89 45 b0             mov    %rax,-0x50(%rbp)
ffffffff810433b0:       bb 00 04 00 00          mov    $0x400,%ebx
ffffffff810433b5:       48 89 55 c0             mov    %rdx,-0x40(%rbp)
...

After:

...
ffffffff8104337c:       65 8b 04 25 28 cd 00    mov    %gs:0xcd28,%eax
ffffffff81043383:       00
ffffffff81043384:       48 98                   cltq
ffffffff81043386:       49 8d bc 24 08 01 00    lea    0x108(%r12),%rdi
ffffffff8104338d:       00
ffffffff8104338e:       48 8b 15 d3 7f 76 00    mov    0x767fd3(%rip),%rdx        # ffffffff817ab368 <update_shares_data>
ffffffff81043395:       48 8b 34 c5 00 ee 6d    mov    -0x7e921200(,%rax,8),%rsi
ffffffff8104339c:       81
ffffffff8104339d:       48 c7 45 a0 00 00 00    movq   $0x0,-0x60(%rbp)
ffffffff810433a4:       00
ffffffff810433a5:       b9 ff ff ff ff          mov    $0xffffffff,%ecx
ffffffff810433aa:       48 89 7d c0             mov    %rdi,-0x40(%rbp)
ffffffff810433ae:       48 c7 45 a8 00 00 00    movq   $0x0,-0x58(%rbp)
ffffffff810433b5:       00
ffffffff810433b6:       bb 00 04 00 00          mov    $0x400,%ebx
ffffffff810433bb:       48 01 f2                add    %rsi,%rdx
ffffffff810433be:       48 89 55 b0             mov    %rdx,-0x50(%rbp)
...

> From a merge POV i'm quite nervous about such a change to the scheduler 
> this late in the .32 cycle - to offset that risk i'd really like to see 
> that this change has been pursued carefully to the edge of possibilities 
> - currently it does not give that impression.

So what's your other proposal?

Refactoring the ia64 pagefault handler is no-go this late in the cycle 
IMHO.

So either this, or reverting 34d76c41 (which is also no-go, I believe).

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
