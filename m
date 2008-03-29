From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 29 Mar 2008 02:52:06 +0000
Subject: Re: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <alpine.LFD.1.00.0803281942440.14670@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain> <20080329001341.7F93826FA1D@magilla.localdomain> <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org> <20080329022408.0DD4726FA1D@magilla.localdomain>
In-Reply-To: <20080329022408.0DD4726FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org



On Fri, 28 Mar 2008, Roland McGrath wrote:
> 
> It could be a PF_* too, I suppose.  There aren't too many of those
> bits free, but it would have the advantage of being a place for an
> arch that doesn't store any TS_* bits anywhere.

Yeah, I guess PF_ would be a bit more regular. Maybe we should even try to 
avoid the use of TS_ in x86, and turn it into PF_. There are probably bad 
historical reasons for the duplication of capabilities.

> Since acting on the flag is in arch signal code anyway, it makes some
> sense to let the arch define how it gets that to happen.  I'll send
> some follow-on patches that change the conditionals to use #ifdef
> HAVE_SET_RESTORE_SIGMASK.

Let's see if it matters first. No reason to add another arch-specific 
thing if nobody can even measure this thing, and from a quick look it 
seems like every RESTORE_SIGMASK user is basically an error path for a 
system call. Those few extra cycles really won't be noticeable, we almost 
certainly have better things we could use our energy on.

So never mind. I think your series is fine, and my TS_ idea doesn't really 
look like it's worth it (and using PF_ sounds a bit more palatable since 
we could do it with existing infrastructure, but a quick grep shows that 
there's more users of test_thread_flag(TIF_RESTORE_SIGMASK) than I would 
have expected (and the *testing* is equally cheap for atomic and thread- 
synchronous fields, so that's not a performance issue).

			Linus
