From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 22:24:56 +0000
Subject: Re: [Linux-ia64] gettimeoffset for 2.5.67
Message-Id: <marc-linux-ia64-105590723705698@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705684@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705684@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 May 2003 12:44:47 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Here it is finally, the long awaited gettimeoffset patch for 2.5.x. It's
  Jes> basically a forward port of my fix for 2.4.21, taking into account that
  Jes> gettimeoffset() returns a nanosecond offset now.

  Jes> Patch is relative to David's 2.5.67 0416 release.

The patch looks largely fine to me.  It's missing an update to
fsys_gettimeofday() though.  In that routine, you need to check
whether the ITC_DRIFT flag is on and, if so, fall back on doing the
heavy-weight syscall.

BTW: There were some unrelated changes in the time code (for
CLOCK_MONOTONIC), which make it likely that your patch won't apply.
If you don't mind, wait with resubmitting the patch until 2.5.69 is
out (hopefully today or tomorrow).  But if you don't want to wait,
that's OK too, I'll do the merge, if necessary.

	--david

