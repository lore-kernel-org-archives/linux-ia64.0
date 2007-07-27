From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 27 Jul 2007 16:39:16 +0000
Subject: Re: [PATCH] flush cache fixes for ia64 [1/2] migration fix
Message-Id: <Pine.LNX.4.64.0707270934300.15619@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
 <20070727133843.6cd3f57a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070727133843.6cd3f57a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Zoltan.Menyhart@bull.net

This will have no effect on x86_64, ia64 and i386. Maybe useful for 
virtually mapped platforms (parisc)?

asm-ia64/cacheflush.c

#define flush_icache_page(vma,page)             do { } while (0)

Acked-by: Christoph Lameter <clameter@sgi.com>

