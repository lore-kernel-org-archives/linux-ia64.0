From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Fri, 08 Nov 2002 17:13:44 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805358@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2002-11-07 at 19:51, William Lee Irwin III wrote:
> On Thu, Nov 07, 2002 at 09:23:21PM -0600, Van Maren, Kevin wrote:
> > This is a follow-up to the email thread I started on July 29th.
> > See http://www.cs.helsinki.fi/linux/linux-kernel/2002-30/0446.html
> > and the following discussion on LKML.
> > I'll summarize the problem again to refresh the issue.
> > Again, this is a correctness issue, not a performance one.
> > I am seeing a problem on medium-sized SMPs where user programs are
> > able to livelock the Linux kernel to such an extent that the
> > system appears dead.  With the help of some hardware debugging
> > tools, I was able to determine that the problem is caused by
> > the reader-preference reader/writer locks in the Linux kernel.
> 
> This is a very serious problem which I have also encountered. My
> strategy was to make the readers on the tasklist_lock more well-behaved,
> and with Ingo's help and co-authorship those changes were cleaned up,
> tuned to provide performance benefits for smaller systems, bugfixed,
> and incorporated in the kernel. They have at least provided 16x systems
> in my lab with much more stability. The issues are still triggerable on
> 32x systems in my lab, to which I do not have regular access.

The normal way of solving this fairness problem is to make pending write
locks block read lock attempts, so that the reader count is guaranteed
to drop to zero as read locks are released.  I haven't looked at the
Linux implementation of rwlocks, so I don't know how hard this is to
do.  Or perhaps there's some other reason for not implementing it this
way?

	J


