From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Mon, 14 Nov 2005 21:52:56 +0000
Subject: Re: Question about interrupt enabling/disabling in kernel exit path
Message-Id: <ed5aea430511141352y669fa884p5c7372cbbca40506@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131559925.5214.100.camel@localhost.localdomain>
In-Reply-To: <1131559925.5214.100.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Then I notice that after we return from do_notify_resume_user() we don't
> recheck TIF_NEED_RESCHED, etc. in the thread_info flags.

Why do you say this?  It's not true.  After processing pending work,
we go back to .work_processed_{syscall,kernel), which will again
invoke .work_pending, if necessary.

AFAIR, it's OK to reenable interrupts in notify_resume_user() because
we know we're at the top of the kernel stack (i.e., there is no risk
of nesting the kernel stack too deeply due to pending interrupts),
provided the interrupts are off again when resuming execution at
.work_processed_kernel.

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
