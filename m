From: Keith Owens <kaos@sgi.com>
Date: Thu, 13 Mar 2003 22:20:12 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 13 Mar 2003 14:14:44 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 14 Mar 2003 08:59:54 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> All is not lost, there is one spare slot in spin_lock which
>  Keith> can clear r29 (dummy ar.pfs) before entering
>  Keith> ia64_spinlock_contention.
>
>But that won't work for leaf routines as that would permanently
>clobber pfs.

I am not touching the real ar.pfs, precisely to avoid changing leaf
routines.  Setting r29 to 0 and .save ar.pfs, r29 in ia64_unwind_contention
will fool the unwind code into doing the unwind correctly but without
changing the state of the routine using spin_lock().


