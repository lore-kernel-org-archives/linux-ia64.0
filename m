From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 01 Mar 2005 22:04:40 +0000
Subject: Re: take7: vector sharing (Large I/O system support)
Message-Id: <16932.59128.184165.533669@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42226CCE.6070706@jp.fujitsu.com>
In-Reply-To: <42226CCE.6070706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 1 Mar 2005 21:51:18 +0000, Christoph Hellwig <hch@infradead.org> said:

  >> The problem is naming, I think.  Those aren't "cache entries", they
  >> are statically preallocated entries.  How about changing the config
  >> option name to:

  Christoph> Even for early allocations what speaks against alloc_bootmem?

I don't recall anymore.  Last time I checked, it wasn't possible, but
that was a _very_ long time ago.

	--david
