From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Apr 2005 08:16:29 +0000
Subject: [RFC] [PATCH] naming reserved pages and remove PG_uncached [0/3]
Message-Id: <42709BDD.3040805@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, Jes

I'm now writing a patch and want your comments .

(*)This patches add information to Reserved pages using page->private field.

I think pages markd with PG_uncached are not managed by alloc_pages()/free_pages().
So, instead of using PG_uncached, using (*) and reserved as "reserved_uncached" can
work enough, I think.

"Allocating and isolating" method cannot work with memory-hotplug stuff.

Can this patch work with your mspec ?

[1/3] function for naming pages using page->private
[2/3] name reserved_at_boot pages
[3/3] name reserved_uncached pages

Thanks.
-- Kame




