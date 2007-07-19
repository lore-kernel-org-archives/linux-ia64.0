From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 19 Jul 2007 15:18:59 +0000
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <469F80E3.3040007@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>	<20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>	<469F5372.7010703@bull.net>	<20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com>	<469F71E7.4050200@bull.net> <20070719235157.9715baff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070719235157.9715baff.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, y-goto@jp.fujitsu.com

KAMEZAWA Hiroyuki wrote:

> Hmm...but the current code flushes the page. just do it in "lazy" way.
> much difference ?

I agree the current code flushes the I-cache for all kinds of file
systems (for PTEs with the exec bit on).

The error is that it does it after the PTE is written.

In addition, I wanted to optimize it to gain a few %.
Apparently this idea is not much welcome.

I can agree that flushing the I-cache (if the architecture requires it)
before setting the PTE eliminates the error.

Thanks,

Zoltan
