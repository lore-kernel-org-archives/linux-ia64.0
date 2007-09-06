From: Shaohua Li <shaohua.li@intel.com>
Date: Thu, 06 Sep 2007 03:16:22 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <1189048582.5704.6.camel@sli10-conroe.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2007-09-05 at 18:25 +0200, Petr Tesarik wrote:
> Shaohua Li wrote:
> > This is base kernel patch for ptrace RSE bug. It's basically a backport
> > from the utrace RSE patch I sent out several weeks ago. please review.
> > 
> > when a thread is stopped (ptraced), debugger might change thread's user
> > stack (change memory directly), and we must avoid the RSE stored in
> > kernel to override user stack (user space's RSE is newer than kernel's
> > in the case). To workaround the issue, we copy kernel RSE to user RSE
> > before the task is stopped, so user RSE has updated data.  we then copy
> > user RSE to kernel after the task is resummed from traced stop and
> > kernel will use the newer RSE to return to user. 
> 
> Hi Shaohua,
> 
> somehow I fail to see the need for a dedicated bit in the task flags.
> The user RBS can only be more up-to-date than the kernel RBS if the
> values there have been modified by a debugger. So, it should be enough
> to copy the relevant part of the user RBS back into the kernel RBS when
> the ptraced process is resumed, which happens AFAIK only:
> 
>   1. when the debugger lets it continue via ptrace(), or
>   2. when the debugger ceases to exist.
> 
> Yes, we'd most likely have to add an arch_ptrace_resume() in addition to
> arch_ptrace_stop(), but there are some advantages, too:
> 
>   1. It would save one bit in the task flags.
>   2. The usual path for task switches is not modified
>      (OK, the few instructions needed to check for TIF_RESTORE_RSE are
>      negligible)
> 
> Or am I totally missing what you're trying to do?
No, you didn't. Ideaily the should do sync user RBS to kernel just after
ptraced process is resumed. In previous discussion, somebody thought
this might be too agressive, as ptraced task might do suspend/resume
several times in a single syscall (syscall trace, fork trace) and we
supposed debugger will only change user RBS just after syscall return.
so the flag is used to try to do less sync. If the assumption is not
true, we should always do sync just after ptraced task is resumed.

Thanks,
Shaohua
