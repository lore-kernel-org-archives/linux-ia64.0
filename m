From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 19 Jul 2007 13:32:08 +0000
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <20070719223208.87383731.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
	<469F5372.7010703@bull.net>
	<20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Zoltan.Menyhart@bull.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, y-goto@jp.fujitsu.com

On Thu, 19 Jul 2007 22:01:18 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 19 Jul 2007 14:05:06 +0200
> Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:
> 
> > KAMEZAWA Hiroyuki wrote:
> > 
> > > Then, what should I do more for fixing this SIGILL problem ?
> > > 
> > > -Kame
> > 
> > I can think of a relatively cheap solution:
> > 
> Maybe I should take performance numbers with the patch.
> 
> But is it too costly that flushing icache page only if a page is newly
> installed into the system (PG_arch1) && it is mapped as executable ?
> 
> I don't want to leak this (stupid) corner case to the file system layer.
> Hmm...can't we do clever flushing (like your idea) in VM layer ?
> 
A bit new idea.  How about this ?
=
- Set PG_arch_1 if  "icache is *not* coherent"
- make flush_dcache_page() to be empty func.
- For Montecito, add kmap_atomic(). This function just set PG_arch1.
  Then, "the page which is copied by the kernel" is marked as "not icache coherent page"
- icache_flush_page() just flushes a page which has PG_arch_1.
- Anonymous page is always has PG_arch_1. Tkae care of Copy-On-Write.
=

looks easy ?

-Kame

 
