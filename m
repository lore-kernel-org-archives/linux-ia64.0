From: Keith Owens <kaos@sgi.com>
Date: Sat, 15 Mar 2003 10:31:53 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590709806132@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 14 Mar 2003 22:46:28 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>I thought about it some more and recalled why I was so uneasy about
>claiming ar.pfs is 0: the problem is that this informs that the
>_previous_ register frame was empty, not the current one.  So the
>unwind info technically is still wrong.  I think you realize that, and
>the kernel unwinder won't complain, since it's not paranoid about
>validating accesses to stacked registers.  But still, the unwind info
>is wrong and I'm not terribly comfortable with that.

I agree, but the end result is benign.  Unwind will attribute the
previous frame's registers to the out of line contention code and will
attribute zero registers to the code that invoked spin_lock(), IOW the
argument lists are swapped on the top two unwind entries.  After that
the unwind is in sync and all other registers are right.

Unwind needs a way of saying "this is out of line code, not a function,
and its state is the same as this ip".  But without that feature in the
unwind spec, this is probably the best that we can do.  It is a pity
that unwind thinks that everything is a function and did not consider
out of line code.

How about putting the new spinlock code in now so I can continue with
adding kdb support for debugging hung spinlocks?  Even with the swapped
arg list, any debug data on hung spinlocks is better than none at all.
I will think some more about the unwind descriptors to see if there is
any way of avoiding the misattribution of the register usage, but the
worst case is that we live with the swapped argument list.


