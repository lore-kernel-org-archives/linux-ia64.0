From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 03 Dec 2001 21:55:36 +0000
Subject: Re: [Linux-ia64] PATCH: performance problems with swiotlb.c
Message-Id: <marc-linux-ia64-105590698805590@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805583@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 3 Dec 2001 12:12:07 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> The basis of the fix is to partition the space reserved for
  Tony> bounce buffers into smaller segments so that we place an upper
  Tony> bound on the amount of work needed to coalesce blocks.

Looks good to me.  I applied the patch,

  Tony> In addition to the performace boost, this patch also fixes one
  Tony> real bug that Dori found while testing.  map_single() would
  Tony> pick a "stride" based on the number of slots needed for the
  Tony> request ... but if this stride is not a power of two, the "do
  Tony> { ... } while (index != wrap);" loop can spin indefinitely. He
  Tony> changed that to use a stride of 1 because he couldn't see the
  Tony> benefit of the larger stride ... nor can I ... e.g.  when
  Tony> looking for 5 slots you might look at an allocation map that
  Tony> looks like this:

  Tony> 	3 <- look here, 3<5 so skip down 5 slots 2 1 0 5 4 <-
  Tony> now look here, missing the large enough block that began on
  Tony> the previous slot.

I'm not sure either.  I assume the stride was intended to reduce
searching overheads.  Perhaps Asit or Goutham would know?

Thanks,

	--david

