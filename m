From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 26 Jun 2004 05:08:31 +0000
Subject: Re: Increasing swiotlb default
Message-Id: <16605.1231.476554.213509@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040624212754.7dd1d68e.ak@suse.de>
In-Reply-To: <20040624212754.7dd1d68e.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Jun 2004 21:27:54 +0200, Andi Kleen <ak@suse.de> said:

  Andi> I discovered that swiotlb defaults to using only 2MB of RAM by
  Andi> default. That's IMHO far too small, especially since the
  Andi> consequences of overflow are so severe (panic) x86-64 has the
  Andi> same problem because it shares this code.

  Andi> This patch increases it to 64MB by default.

You haven't actually tested this, have you?  swiotlb.c has code which
assumes that IO_TLB_SHIFT <= PAGE_SHIFT.

Also, 64MB could be a fairly significant fraction of a system's memory.
Perhaps the default value should take the amount of system memory into
account?

	--david
