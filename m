From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Oct 2004 08:56:48 +0000
Subject: Re: bug in 2.6.9-rc4-mm1 ia64/mm/init.c
Message-Id: <416CEF0E.1060406@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.33.0410121705510.31839-100000@localhost.localdomain>
 <16748.57721.66330.638048@napali.hpl.hp.com> <416CEADA.2060207@jp.fujitsu.com>
 <16748.60002.875945.950324@napali.hpl.hp.com>
In-Reply-To: <16748.60002.875945.950324@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: akepner@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, jbarnes@sgi.com

David Mosberger wrote:

>>>>>>On Wed, 13 Oct 2004 17:44:10 +0900, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com> said:
> 
> 
>   Hiroyuki> My purpose was to reduce # of page fault when
>   Hiroyuki> ia64_pfn_valid() is called.  It is called heavily in
>   Hiroyuki> bad_range() (in mm/page_alloc.c) now.
> 
> At the expense of ignoring perfectly good memory?  Or did I miss something?
> 
> 	--david

Am I ignoring some good memory ?
I think GRANULEROUNDDOWN(start)/GRANULEROUNDUP(end) only expand valid pfn range,
do I misunderstanding something ?



-- Kame
