From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 20:07:33 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <16887.63621.433849.794579@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Jan 2005 11:23:06 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> It seems logical to me that MCA data be close to the node/cpu
  >> using it, but workable if it is not.

  Tony> Since performance is not an issue here, and there isn't a
  Tony> functionality reason for allocating per-node, I'd vote for
  Tony> whatever is the cleanest code implementation.  Part of the pit
  Tony> I've dug myself into is caused by the complexity of the
  Tony> contig/discontig code ... if we can make it simpler, perhaps I
  Tony> won't break it all again.

I'm all for simplification, but with a better API, we could share code
and still have node-local data (which does feel intuitively right).

Can't we have a simple

	alloc_bootmem_for_cpu(cpu, size, align, goal)

which would take care of the difference?

(Yes, I know about alloc_bootmem_node(), but it wants a pgdat pointer,
which I couldn't care less about in the non-NUMA case.)

	--david
