From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 21 Mar 2001 19:07:06 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005319@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At this point, you've made so many false, misleading, and exagerated claims
that I am highly skeptical.  I will have to ponder this later.  At the moment,
I have a couple of comments.

>It is not valid to always subtract 1 from the return address because
>programmers are allowed to do this in assembler.
>
>A:
>  ret = B
>  goto F
>X:
>  ...
>B:
>  ...

You're example is seriously lacking.  You haven't provided any evidence to
support your claim that this is valid.  Neither have you provided any
explanation of why someone might want to do this.  I suspect this is
supposed to be the "last-call" optimization that David Mosberger mentioned.
That makes sense, but still does not prove that the optimization is valid.

>F cannot assume that it was entered via call, it can be entered by any
>hand coded construct that gives the same environment as a call, even if
>the return is not to the code that branched to F.  Subtracting 1 from
>ret in this case would give B-1 which appears to be in X and is wrong.

If it is only extremely rare cases of hand-written code that cause a problem,
then why are we fixing the problem by changing the compiler?  Shouldn't we
change the hand-written code?

Does the SGI compiler emit nops after calls that don't return?  Is the SGI
compiler going to be changed to do this?

Jim

