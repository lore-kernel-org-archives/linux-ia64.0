From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 May 2003 20:25:06 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705710@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 9 May 2003 15:02:47 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:

  >> Would there be a downside to this on SGI's machines?

  Jack> I dont see any significant problems. It actually seems easy.

Good.

  Jack> I think we still need to use __tpa() for addresses assigned by
  Jack> the loader.  The standard __pa() macros wont work in region 5.

That's why I don't mind: nobody can use __pa() on region 5 anyhow, so
using something different (page table walk or __tpa()) is OK.  I was
real uneasy with having a "magic" address range inside region 7, where
__pa() wouldn't work.  But in region 5, no problem.

It might be good to call __tpa() something different: it's too close
to __pa() and the difference may easily be overlooked.  For example,
ia64_tpa() would make it obvious that we're talking about an ia64
instruction.

	--david

