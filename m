From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 01 Dec 2003 21:42:06 +0000
Subject: Re: TLB flushing on SGI platforms
Message-Id: <marc-linux-ia64-107031512728461@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Nov 2003 09:43:01 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> The SGI NUMA platform does not use the hardware "ptc" instruction
  Jack> to flush TLBs. Instead, it has to write an MMR on the chipset on each
  Jack> node to cause a TLB flush transaction to be placed on the bus. On
  Jack> large systems, the overhead to broadcast the TLB flush to every node
  Jack> in the system is one of the hot spots in the kernel.

  Jack> In most cases, the TLB context being flushed has been loaded into
  Jack> a small subset of the nodes. Flushing every node is unnecessary.

  Jack> I'm looking for suggestions on the best way to limit TLB flushing so
  Jack> that only the necessary nodes are flushed. Here is patch that
  Jack> I believe will work. I added a bitmask to the mm_context_t to
  Jack> track nodes where the context has been loaded. The TLB flush routine
  Jack> issues the TLB flush requests only to these nodes.

  Jack> Are there other/better ways that I can do this??

Why not use mm->cpu_vm_mask?  It will give you CPU instead of
node-granularity, but if you really want nodes instead, you can do the
mapping in the NUMA-specific code.

	--david
