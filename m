From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 19 Jul 2007 12:15:49 +0000
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <469F55F5.7040503@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com> <20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "tony.luck@intel.com" <tony.luck@intel.com>, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, GOTO <y-goto@jp.fujitsu.com>

> Back to do_no_page():
> if the new PTE includes the exec bit and PG_arch_1 is set,
> the page has to be flushed from the I-cache before the PTE is
> made globally visible.

Sorry, I wanted to say:

if the new PTE includes the exec bit and PG_arch_1 is NOT set

Thanks,

Zoltan

