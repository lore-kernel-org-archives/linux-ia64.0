From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 20 Mar 2003 02:06:20 +0000
Subject: Re: [Linux-ia64] provide /proc/sal/itc_drift through AUX?
Message-Id: <marc-linux-ia64-105590723705276@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705273@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705273@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> Why do you need to export it if you just use a light-weight
David> gettimeofday()?  The light-weight syscall can readily access
David> the ITC-drift info via kernel memory.

Let me get sure I understand you right here, you are suggesting I add
a new syscall to provide the info currently found in
/proc/sal/itc_drift? Right now it's just returning true/false (1/0) as
to whether the ITC drifts or not.

The reason I was thinking about using the AUX was that it's still
faster than making a system call and the dynamic linker will always be
calling it once. It doesn't make a big difference of course whether we
do it one way or another.

David> BTW: I think someone should explore using an NTP-like approach
David> to keep ITC drift small enough that it's still usable for
David> ITC-based interpolation.  Granted, this assumes that hw drifts
David> are reasonably small and you'd still need to worry about
David> different clock-frequencies, but I suspect that in practice,
David> this would work extremely well.  It would be nice because it
David> would be much faster than an HPET-based approach, would work on
David> all ia64 machines, and would provide better resolution.
David> Furthermore, we already have all the logic in the
David> time-interpolation to ensure that there is never an observable
David> time discontinuity.

I think this would work if it wasn't for the different clock frequency
problem. What real life ITC drifts are like I must admit I have no
idea.

Pardon my ignorance, what are you referring to by HPET? I am sure it's
something obvious and I know I have heard it before, but it's just not
ringing a bell here right now.

Cheers,
Jes

