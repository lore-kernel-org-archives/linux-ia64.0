From: mgross <mgross@unix-os.sc.intel.com>
Date: Fri, 19 Jul 2002 14:54:18 +0000
Subject: [Linux-ia64] Re: [PATCH]: scheduler complex macros fixes
Message-Id: <marc-linux-ia64-105590701905791@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Friday 19 July 2002 01:28 pm, Linus Torvalds wrote:
> On Sat, 20 Jul 2002, Ingo Molnar wrote:
> >=A0well, SCHED_BATCH is in fact ready, so we might as well put it in. All
> > the suggestions mentioned on lkml (or in private) are now included, the=
re
> > are no pending (known) problems, no objections, and a number of people
> > are using it with success.
>
> Well, I do actually have objections, mainly because I think it modifies
> code that I'd rather have cleaned up in other ways _first_ (ie the return
> path to user mode, which has pending irq_count/bh_count/preempt issues
> that I consider to be about a million times more important than batch
> scheduling).
>

Thats too bad.  I've been looking at Ingo's SCHED_BATCH design to help=20
suspend processes with out lock problems while doing multithreaded core=20
dumps. =20

Is there any ETA on the return path to user mode clean up?

--mgross

