From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Apr 2004 00:03:23 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <16525.41803.428407.356922@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Apr 2004 16:35:55 -0500, Robin Holt <holt@sgi.com> said:

  >> In any case, just be careful about not introducing memory attribute
  >> aliases.  You need to be especially careful since the kernel accesses
  >> memory with granule-sized mappings (normally 64MB page size, but on
  >> some machines its 16MB).

  Robin> Be very careful when using uncached memory.  On the SGI
  Robin> systems, we always allocate memory for uncached out of a
  Robin> seperate granule.  We were experiencing memory corruption due
  Robin> to kernel speculative load which fetched the cache line
  Robin> dirty.  This would result in cache lines that were
  Robin> occasionally out of date.  The problem was resolved on our
  Robin> kernels by drivers/char/fetchop.c which provides a seperate
  Robin> device for mapping when you want uncached or write coalesced
  Robin> memory.

Are you just re-stating my caveat about memory-attribute-aliasing or
are you saying something else?  If the latter, I'm not following.  If
the former, I certainly agree: memory attribute-aliasing leads to
really nasty-to-track-down bugs.  Hence, you want to make sure
_upfront_ that it doesn't occur.

	--david
