From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Tue, 15 Nov 2005 21:16:27 +0000
Subject: Re: Question about interrupt enabling/disabling in kernel exit path
Message-Id: <ed5aea430511151316s308e7eedhf02e6c1f4bbd2f42@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131559925.5214.100.camel@localhost.localdomain>
In-Reply-To: <1131559925.5214.100.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 11/15/05, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> Lee Schermerhorn wrote on Tuesday, November 15, 2005 12:21 PM
> > On Mon, 2005-11-14 at 13:52 -0800, David Mosberger-Tang wrote:
> > > > Then I notice that after we return from do_notify_resume_user() we don't
> > > > recheck TIF_NEED_RESCHED, etc. in the thread_info flags.
> > >
> > > Why do you say this?  It's not true.  After processing pending work,
> > > we go back to .work_processed_{syscall,kernel), which will again
> > > invoke .work_pending, if necessary.
> >
> > OK.  I guess I'm misinterpreting the comments on the line labeled
> > '.ret10:'.
> > Say's it's setting p6 to zero, so no recheck.  I'm not fluent [writing
> > nor reading] ia64 assembler, but it appeared to me that with p6 set to
> > zero on return from notify_resume(), the checks for more work back
> > at .work_processed_* would be disabled.
> >
>
> Looking at the code, I think Lee is correct that upon returning from
> notify_resume_user, p6 is turned off and subsequently turns off all
> the check in work_pending.

Yes, I goofed.

The ia64 code shouldn't be different from other platforms in this
respect though.  If x86 nowadays does the re-check unconditionally, we
need to look into what happened.  Perhaps x86 got updated and we
missed that update for ia64?

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
