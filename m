From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 May 2003 23:20:09 +0000
Subject: Re: [Linux-ia64] Re: new ia64 kernel patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705737@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705722@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705722@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 11 May 2003 00:02:50 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> * Always save the return address in r28 in addition to b6
  Keith> (btw, your patch still mentions b7).

You mean in the comment?  I fixed that now, thanks.

  Keith> b6 is not in minstate which means it is missing for INIT and
  Keith> MCA dumps, making it impossible to determine which code was
  Keith> in contention.

This doesn't make any sense to me.  If it's not in MINSTATE, it's
preserved across the firmware INIT path.  You may want to take a
look at how the 2.5 MCA code is handling this.

  Keith> * Add more registers to the clobber list.

  Keith> ar.ccv is really clobbered and is missing from the list.

Indeed.

  Keith> Some of the optional code that is added to the contention
  Keith> path (e.g. exponential backoff) needs more registers.
  Keith> Changing spinlock.h forces a complete recompile, so predefine
  Keith> a suitable set of free registers.

I'd like to see that exponential backoff code first.  The old code in
head.S did exponential backoff with 4 general registers just fine,
IIRC.

  Keith>   There is also a problem with binary only modules, I hate
  Keith> them but they are a fact of life.  Changing the clobber list
  Keith> in spinlock.h will result in binary only modules that have an
  Keith> incorrect view of what the kernel is doing and will result in
  Keith> register corruption on contended locks.  I don't like the
  Keith> idea that tuning and debugging patches introduce Heisenbugs!

That's an argument against binary-only driver.  Not much else.

	--david

