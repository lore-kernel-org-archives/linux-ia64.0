From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 28 Apr 2007 04:11:35 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <4632C977.1040105@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070425205548.fd51b301.akpm@linux-foundation.org>	 <46305A8D.2080003@yahoo.com.au> <20070426173544.GA30744@ldl.fc.hp.com>	 <4631E49C.2030501@yahoo.com.au> <1177723479.13482.371.camel@galaxy.corp.google.com> <4632AAB4.6030303@yahoo.com.au>
In-Reply-To: <4632AAB4.6030303@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 
Cc: rohitseth@google.com, Mike Stroyan <mike.stroyan@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Nick Piggin wrote:
> Rohit Seth wrote:

>> You mean by user space? If so, then it is user space responsibility to
>> do the appropriate operations (like flush icache in this case).
> 
> 
> No, I mean places that set PG_arch_1. flush_dcache_page. This can
> happen for mapped pages in write, splice, install_arg_page looks
> questionable, direct IO...

Oh, and also ptrace! I think I was almost fooled by that attempt to flush
the cache in copy_to_user_page.

But that also fails if you map the underlying page with multiple virtual
addresses (or processes, if the icache is not flushed on ctxsw), because
those others won't have their caches flushed, right?

-- 
SUSE Labs, Novell Inc.
