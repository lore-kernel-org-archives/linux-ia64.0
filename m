From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 09 Nov 2005 18:12:05 +0000
Subject: Question about interrupt enabling/disabling in kernel exit path
Message-Id: <1131559925.5214.100.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello:

I have a question about enabling interrupts in the kernel exit path.
Especially, in do_notify_resume_user().  I have work that I need to
defer to this point, but it needs to run with interrupts enabled.  I
wanted to piggy back off TIF_NOTIFY_RESUME, because that is more or less
generic code and gets handled in a C function where I can play the usual
header games:  static inline wrapper function when feature is
configured;  null macro when not.

I see a comment at the beginning of ia64_leave_kernel that says that
"work.need_resched, etc. mustn't get changed by this CPU before it
returns to user- or fsys-mode, hence we disable interrupts early on."
[This may be a stale comment.  I.e., we now check for resched needed in
current task's thread_info flags.] But, then I see later that when
CONFIG_PREEMPT is set, we do enable interrupts and then re-disable them.

Then I notice that after we return from do_notify_resume_user() we don't
recheck TIF_NEED_RESCHED, etc. in the thread_info flags.   So, maybe
this is the issue?  If I open an interrupt window in
do_notify_resume_user(), 'NEED_RESCHED might get set and we wouldn't
notice it on return to the assembly language code.  [I might even sleep
here.  Is that a problem?]

I took a look at the x86_64 and i386 versions and they always goes back
to check for resched after calling their version of do_notify_resume()
[no '_user suffix on the routine].  If this were the only issue with
enabling interrupts in do_notify_resume_user(), I could change it to
return non-zero if recheck is needed [zero in the usual case] and then
go back and recheck thread_info flags.

Regards,
Lee


