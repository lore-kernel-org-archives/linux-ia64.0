From: Keith Owens <kaos@sgi.com>
Date: Thu, 13 Mar 2003 22:42:41 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806089@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 13 Mar 2003 14:26:28 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 14 Mar 2003 09:20:12 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> I am not touching the real ar.pfs, precisely to avoid
>  Keith> changing leaf routines.  Setting r29 to 0 and .save ar.pfs,
>  Keith> r29 in ia64_unwind_contention will fool the unwind code into
>  Keith> doing the unwind correctly but without changing the state of
>  Keith> the routine using spin_lock().
>
>Ah, sorry, I didn't read your mail carefully enough.  Hmmh, not
>exactly a pretty solution, but I don't see anything obviously wrong
>with it either.  With libunwind, you could in fact say
>
>	.save ar.pfs,r0
>
>but I don't remember whether this would work with the kernel unwinder
>(if it doesn't, it would be easy to fix though).

I wanted to do .save ar.pfs,r0, but it needs a change to
unw_access_gr().  As you say, easy enough to fix, but I wanted to
minimize the changes for this new spinlock code.  OTOH, if you do not
mind changing unw_access_gr(), I will do it that way and free up r29.


