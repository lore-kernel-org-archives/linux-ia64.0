From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Mar 2003 20:29:04 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590723705337@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 15 Mar 2003 21:31:53 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Fri, 14 Mar 2003 22:46:28 -0800, 
  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >> I thought about it some more and recalled why I was so uneasy about
  >> claiming ar.pfs is 0: the problem is that this informs that the
  >> _previous_ register frame was empty, not the current one.  So the
  >> unwind info technically is still wrong.  I think you realize that, and
  >> the kernel unwinder won't complain, since it's not paranoid about
  >> validating accesses to stacked registers.  But still, the unwind info
  >> is wrong and I'm not terribly comfortable with that.

  Keith> I agree, but the end result is benign.

I disagree.  A bug is a bug.  Relying on implementation-specific
behavior of one particular unwinder doesn't change that.

  Keith> Unwind needs a way of saying "this is out of line code, not a
  Keith> function, and its state is the same as this ip".  But without
  Keith> that feature in the unwind spec, this is probably the best
  Keith> that we can do.  It is a pity that unwind thinks that
  Keith> everything is a function and did not consider out of line
  Keith> code.

  Keith> How about putting the new spinlock code in now so I can
  Keith> continue with adding kdb support for debugging hung
  Keith> spinlocks?  Even with the swapped arg list, any debug data on
  Keith> hung spinlocks is better than none at all.  I will think some
  Keith> more about the unwind descriptors to see if there is any way
  Keith> of avoiding the misattribution of the register usage, but the
  Keith> worst case is that we live with the swapped argument list.

My experience tells me that if I put in the code now, nobody will work
on a corrected version.

I think it makes sense to start a discussion of extending the unwind
spec to make it easier to accommodate what we're trying to do here.  A
similar facility already exists in libunwind for dynamic unwind info
(since runtime function cloning naturally leads to the same issue).

Can you start this discussion?

	--david

