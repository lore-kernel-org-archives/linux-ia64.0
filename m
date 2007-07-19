From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 19 Jul 2007 14:51:57 +0000
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <20070719235157.9715baff.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
	<469F5372.7010703@bull.net>
	<20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com>
	<469F71E7.4050200@bull.net>
In-Reply-To: <469F71E7.4050200@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, y-goto@jp.fujitsu.com

On Thu, 19 Jul 2007 16:15:03 +0200
Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> We may have, say 1 Gbyte / sec local i/o activity (using some RAIDs).
> Assume a few % of this 1 Gbyte is the program execution, or program swap in.
> It gives some hundreds of new exec pages / sec =>
> some msec-s can be lost each sec.
> 
> I can agree that it should not be a big deal :-)
> 
Hmm...but the current code flushes the page. just do it in "lazy" way.
much difference ?

-Kame
