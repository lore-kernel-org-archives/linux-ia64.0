From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 08 Nov 2002 17:55:39 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805367@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2002-11-08 at 09:34, David Howells wrote:
> 
> > The normal way of solving this fairness problem is to make pending write
> > locks block read lock attempts, so that the reader count is guaranteed
> > to drop to zero as read locks are released.  I haven't looked at the
> > Linux implementation of rwlocks, so I don't know how hard this is to
> > do.  Or perhaps there's some other reason for not implementing it this
> > way?
> 
> Actually implementing a fair spinlocks and fair rwlocks on the x86 arch are
> very easy (at least, if you have XADD it is). Any arch which has CMPXCHG can
> also do it, just not so easily.
> 
> I've attached an implementation of a fair spinlock and an implementation of a
> fair rwlock (which can be compiled and played with in u-space).
> 
> David

There are a selection of similar algorithms here:
	http://www.cs.rochester.edu/u/scott/synchronization/pseudocode/rw.html#s_f

How does yours compare?




