From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 30 Jul 2007 18:20:44 +0000
Subject: Re: [PATCH] flush icache before set_pte() take 5. [1/2] cache flush
Message-Id: <Pine.LNX.4.64.0707301120290.743@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070728150319.d19f531f.kamezawa.hiroyu@jp.fujitsu.com>
 <20070728151449.f3ec0ebe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070728151449.f3ec0ebe.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Zoltan.Menyhart@bull.net, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>

On Sat, 28 Jul 2007, KAMEZAWA Hiroyuki wrote:

> In migration, a new page should be cache flushed before set_pte()
> in some archs which have virtually-tagged cache..
> 
> V4 -> V5:
>    * changed flush_icache_page to flush_cache_page.
> 
> Signed-Off-By: KAMEZAWA Hiruyoki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Christoph Lameter <clameter.sgi.com>
