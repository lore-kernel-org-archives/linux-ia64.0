From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 20 Oct 2003 18:48:27 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106667573723954@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 20 Oct 2003 09:17:10 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> On Friday 17 October 2003 6:21 pm, David Mosberger wrote:
  >> What about memory-mapped device registers?  Isn't all memory
  >> physically contiguous on x86 and that's why the "p >  >> __pa(high_memory)" test saves you from that?

  Bjorn> As others have mentioned, using read/write on /dev/mem to get
  Bjorn> at memory-mapped registers is unlikely to work on ia64
  Bjorn> anyway, because read/write use cacheable mappings.  Using
  Bjorn> mmap does work (using uncacheable mappings), and my patch
  Bjorn> doesn't change that path.

True, I just find this whole thing rather disgusting: different
behavior for read/write vs. mmap; but you're right, it's nothing
new and probably the most pragmatic "solution".

  Bjorn> I bet that ia32 does have page tables for this case, and that
  Bjorn> an attempt to read non-existent physical memory will cause a
  Bjorn> TLB miss from which copy_*_user() can easily recover.

True, but even this doesn't help for MMIO space, where a device may
decode less than a full page.  So you'd still end up accessing address
holes.  Just that x86 returns garbage in that case (I think).

	--david
