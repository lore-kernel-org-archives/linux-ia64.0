From: Rohit Seth <rohitseth@google.com>
Date: Sat, 28 Apr 2007 01:24:39 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <1177723479.13482.371.camel@galaxy.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070425205548.fd51b301.akpm@linux-foundation.org>
	 <46305A8D.2080003@yahoo.com.au> <20070426173544.GA30744@ldl.fc.hp.com>
	 <4631E49C.2030501@yahoo.com.au>
In-Reply-To: <4631E49C.2030501@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mike Stroyan <mike.stroyan@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 2007-04-27 at 21:55 +1000, Nick Piggin wrote:

> That's the theory. However, I'd still like to know how the arch code can
> make the assertion that icache is known to be at all times other than at
> the time of a fault?
> 

Kernel needs to only worry about the updates that it does.  So, if
kernel is writing into a page that is getting marked with execute
permission then it will need to make sure that caches are coherent.
ia64 Kernel keeps track of whether it has done any write operation on a
page or not using PG_arch_1.  And accordingly flushes icaches.

> Ie. what if an operation which causes incoherency is carried out _after_
> an executable mapping is installed for that page.
> 

You mean by user space? If so, then it is user space responsibility to
do the appropriate operations (like flush icache in this case).

-rohit

