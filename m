From: Andrew Morton <akpm@osdl.org>
Date: Fri, 03 Jun 2005 07:35:44 +0000
Subject: Re: periodically-drain-non-local-pagesets-fix.patch added to -mm
Message-Id: <20050603003544.3deb0ec2.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050602231057.580dcaa3.akpm@osdl.org>
In-Reply-To: <20050602231057.580dcaa3.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> wrote:
>
> On Fri, 3 Jun 2005 00:22:10 -0700, 
> Andrew Morton <akpm@osdl.org> wrote:
> >Keith Owens <kaos@sgi.com> wrote:
> >> Does this fix the problem?  Compiled but not tested.
> >
> >Well it'll make the warning go away but I think there's a more fundamental
> >problem, in that:
> >
> >	get_cpu();
> >	cond = something_which_uses_smp_processor_id();
> >	put_cpu();
> >
> >	/* `cond' can become false at any time from here */
> 
> Good point.  The entire fpu load/restore logic on ia64 needs reviewing
> for preemption.  There is an implicit assumption that the fpu state is
> atomically saved and restored on the current cpu, while under the
> control of psr->mfh.  Preempt has the potential to migrate a task while
> it is in the middle of save/restore fpu, breaking that assumption.
> Other ia64 register save/restore code might have similar problems.

OK, thanks.  Could someone please spin up a disable-preempt-on-ia64 patch
for the 2.6.12 release?

> Leaving this one to the rest of the list.

Sensible man ;)
