From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 20:12:59 +0000
Subject: Re: [patch] 2.4.25 sync unwind code with 2.6.3
Message-Id: <16442.24267.353386.287861@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3792.1077504388@kao2.melbourne.sgi.com>
In-Reply-To: <3792.1077504388@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Keith> I am not happy with the kludge that avoids the deadlock on
  Keith> script-> lock, anybody got a better solution?  The kludge
  Keith> assumes script-> that the first field in an ia64 rwsem is a
  Keith> spinlock.  I have hit this unwind deadlock a couple of times
  Keith> during processing of asynchronous MCA events, so I want it
  Keith> fixed.

What I did for libunwind is to avoid deadlock by falling back to
uncached unwinding if necessary.  That is, if a lock is taken, it just
creates an unwind script on the local stack.

It would be good to replace the built-in kernel unwinder with
something based on libunwind.  That would make it much easier to keep
the code in sync (and libunwind is much better tested).  I have been
toying with the idea of doing this for 2.7, but it hasn't been very
high priority to me because, for the most part, the kernel unwinder is
good enough.

	--david
