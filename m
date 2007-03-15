From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 15 Mar 2007 07:40:01 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070315003916.8a78dd0c.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070312.192616.63128242.davem@davemloft.net>
	<20070312.193211.30184040.davem@davemloft.net>
	<20070315002249.9e531578.akpm@linux-foundation.org>
	<20070315.003118.41650094.davem@davemloft.net>
In-Reply-To: <20070315.003118.41650094.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: paulus@samba.org, clameter@sgi.com, linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

> On Thu, 15 Mar 2007 00:31:18 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 15 Mar 2007 00:22:49 -0800
> 
> > So...  what would happen if sparc64 were to use neither quicklists nor
> > slab?  Just grab these pages from the page allocator and clear them?
> 
> The page table allocator is heavier weight than the quicklists,
> although obviously not as heavy weight as SLAB.

Spose so, although only in the case where we go into the buddy lists, I hope.

otoh, releasing a cache-hot page into the page allocator makes it available for
other use.

It'd be nice if you could run the numbers sometime, please - if it's OK then
we can remove code...
