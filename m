From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 28 Apr 2007 03:04:40 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <4632B9C8.40400@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070425205548.fd51b301.akpm@linux-foundation.org>	 <46305A8D.2080003@yahoo.com.au> <20070426173544.GA30744@ldl.fc.hp.com>	 <4631E49C.2030501@yahoo.com.au> <1177723479.13482.371.camel@galaxy.corp.google.com> <4632AAB4.6030303@yahoo.com.au>
In-Reply-To: <4632AAB4.6030303@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: rohitseth@google.com, Mike Stroyan <mike.stroyan@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Nick Piggin wrote:

> What if you were to say remove all the PG_arch_1 code, and do something
> really simple like flush icache in flush_dcache_page? Would performance
> suffer horribly?

OIC, you need a virtual address to evict the icache, so you can't
flush at flush_dcache time? Or does ia64 have an instruction to
flush the whole icache? (it would be worth testing, to see how much
performance suffers).

-- 
SUSE Labs, Novell Inc.
