From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 22 Dec 2004 01:16:37 +0000
Subject: Re: [PATCH] modifing vmemmap initialization [1/1] : modifies init
Message-Id: <41C8CAF5.1060902@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41C7CC9E.7080602@jp.fujitsu.com>
In-Reply-To: <41C7CC9E.7080602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:
>>>This patch adjust calling sequence of virtual_mem_map_alloc(),
>>>which is added by previous patch.
>>
>>This doesn't look like an improvement at all, the whole virtual memmap
>>should not need core ifdefs.  In fact I still hope it'll go away.
> 
> 
> It doesn't need core ifdefs at all -- simply define a dummy
> virtual_mem_map_alloc() and you can remove the ifdefs.
> 
I'm thinking about pass "memmap allocation function" as a free_area_init_node()'s argument.
Such args can be used in i386(or some) NUMA case, which doesn't use alloc_bootmem().
Anyway, my patch is not good.

> (I also hope it'll go away.  Where's CONFIG_NONLINEAR got to?)
> 
Robert Picco's one was intended to avoid using CONFIG_VIRTUAL_MEM_MAP.
I wrote another one, which uses CONFIG_VIRTUAL_MEM_MAP, and it was too complicated :(

-- Kame <kamezawa.hiroyu@jp.fujitsu.com>
