From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Oct 2004 08:44:10 +0000
Subject: Re: bug in 2.6.9-rc4-mm1 ia64/mm/init.c
Message-Id: <416CEADA.2060207@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.33.0410121705510.31839-100000@localhost.localdomain>
 <16748.57721.66330.638048@napali.hpl.hp.com>
In-Reply-To: <16748.57721.66330.638048@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: akepner@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, jbarnes@sgi.com

David Mosberger wrote:

> Why was this patch even accepted?  It seemed rather dubious to me and
> I don't recall much discussion on its merits or safety.
> 
> 	--david

At first, that patch it is not essential to no-bitmap-buddy patch, and removing
it is okay. It seems that test and discussion are not enough now.

Since I heared that all of the pages in a granule on ia64 are guaranteed to exist,
I included that in no-bitmap-buddy-patch.
(when pagesizek/granuleM,I think this has no effect.)

My purpose was to reduce # of page fault when ia64_pfn_valid() is called.
It is called heavily in bad_range() (in mm/page_alloc.c) now.


Kame <kamezawa.hiroyu@jp.fujitsu.com>




