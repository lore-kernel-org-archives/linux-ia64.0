From: David Miller <davem@davemloft.net>
Date: Thu, 15 Mar 2007 07:31:18 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070315.003118.41650094.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070312.192616.63128242.davem@davemloft.net>
	<20070312.193211.30184040.davem@davemloft.net>
	<20070315002249.9e531578.akpm@linux-foundation.org>
In-Reply-To: <20070315002249.9e531578.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: paulus@samba.org, clameter@sgi.com, linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 15 Mar 2007 00:22:49 -0800

> So...  what would happen if sparc64 were to use neither quicklists nor
> slab?  Just grab these pages from the page allocator and clear them?

The page table allocator is heavier weight than the quicklists,
although obviously not as heavy weight as SLAB.

I know special purpose allocation lists suck, but they really help in
this case in my opinion.

And for the x86 cases it's not going to help to have GFP_ZERO stuff
via the page allocator for page tables, they have to have specific
bits in the pre-initialized areas for the kernel PGDs, not just zero.
