From: Shaohua Li <shaohua.li@intel.com>
Date: Fri, 19 Oct 2007 07:30:40 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <1192779040.29598.1.camel@sli10-conroe.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2007-10-18 at 12:59 +0200, Petr Tesarik wrote:
> Shaohua Li wrote:
> > On Wed, 2007-10-17 at 16:56 +0200, Petr Tesarik wrote:
> >> Shaohua Li wrote:
> >>> On Fri, 2007-09-07 at 09:11 -0600, David Mosberger-Tang wrote:
> >>>> Anything that avoids complicating the kernel exit path is worth doing!
> >>>>  The exit path is complicated enough as it is.
> >>>>
> >>>>   --david
> >>>>
> >>>> On 9/7/07, Petr Tesarik <ptesarik@suse.cz> wrote:
> >>>>> -----BEGIN PGP SIGNED MESSAGE-----
> >>>>> Hash: SHA1
> >>>>>
> >>>>> Shaohua Li wrote:
> >>>>>> On Thu, 2007-09-06 at 15:59 +0200, Petr Tesarik wrote:
> >>>>>>> [...]
> >>>>>>> So, what happens if upon syscall entry notification the debugger
> >>>>>>> modifies the part of the RBS (in user-space) which corresponds to the
> >>>>>>> arguments of that syscall? Currently, the syscall takes the modified
> >>>>>>> arguments, but with your change it would still take the stale data
> >>>>>>> from
> >>>>>>> the kernel RBS.
> >>>>>> The patch does sync from user RBS to kernel RBS just after syscall trace
> >>>>>> enter. this is an exception I said doing sync just before syscall
> >>>>>> return. I thought this covers your case, no?
> >>>>> Ah, I'm sorry, I missed that part of the patch. Well, if we have to do a
> >>>>> sync on every syscall_trace_enter() and syscall_trace_leave(), then the
> >>>>> only cases where introducing TIF_RESTORE_RSE saves us a duplicate sync
> >>>>> seems to be in the clone/fork and exit paths. In other words, it's
> >>>>> probably not worth the added complexity. But since you have written the
> >>>>> whole complex thing already, I have no objections against it.
> >>> Ok, this is a simplified patch. please review.
> >> Well, it's been quite some time, but here we go.
> >>
> >> I'm generally fine with this patch, but pleas note that it can't be
> >> included on its own:
> >>
> >>   1. There still is the race condition introduced by moving
> >> set_current_state(TASK_TRACED) after the spin_unlock_irq
> > I don't know the details, but Roland said if other parts are ok, he can help fix the issue.
> > 
> >>   2. You must couple it with the (planned) changes to the ptrace,
> >> because otherwise PTRACE_{PEEK,POKE}{TEXT,DATA} still access the kernel
> >> RBS, but it gets later overwritten back from userspace when it is synced.
> > 
> >> I have verified that failing to do so breaks "strace -f", because
> >> strace
> >> relies on intercepting the clone() system call and setting the
> >> CLONE_PTRACE bit in the flags argument. Of course, if the bit is only
> >> set in the kernel RBS, which is overwritten with the (old) value from
> >> the user RBS on a PTRACE_CONT, the new process is not traced.
> > The patch sync kernel RBS to user just before the task is suspended, so
> > I think we should be fine here. I did test 'strace -f', and test is ok.
> 
> Maybe you're right. I was porting this to 2.6.16 for SUSE Linux
> Enterprise Server 10, so my patch was a bit different. I'll retest with
> latest git. Nevertheless, I still think that ia64_poke() can't do the
> right thing here, because the changes made by PTRACE_PEEKDATA should
> also be visible in /proc/<pid>/mem, for example.
Yes, exactly. I remember somebody said ia64_poke should be removed.

Thanks,
Shaohua
