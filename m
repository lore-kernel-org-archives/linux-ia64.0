From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 24 May 2005 03:29:47 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <17042.40875.917598.469830@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 May 2005 13:50:31 -0400, Bob Picco <bob.picco@hp.com> said:

  Bob> Ultimately I would like to eliminate [...] VIRTUAL_MEM_MAP.

Why?

Considering this:

+#ifdef CONFIG_SPARSEMEM
+ /*
+ * SECTION_SIZE_BITS            2^N: how big each section will be
+ * MAX_PHYSADDR_BITS            2^N: how much physical address space we have
+ * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
+ */

The virtual mem-map seems like a much nicer solution to me.

	--david
