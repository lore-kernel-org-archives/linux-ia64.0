From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 04 Sep 2006 07:45:05 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <20060904164505.d75fac21.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 4 Sep 2006 16:06:06 +0900
Horms <horms@verge.net.au> wrote:

> Sure, 
> 
> here is a config that exhibits the problem.
> Though now you come to mention it, perhaps the config is invalid.
> 

it looks you selects CONFIG_DISCONTIGMEM and doesn't do CONFIG_NUMA.
interesting but ...

DISCONTIGMEM uses plural pg_data_t. This is represented by
CONFIG_NEED_MULTIPLE_NODES. 
So all codes which handles pgdats should depend on CONFIG_NEED_MULTIPLE_NODES.

But several pieces of codes uses CONFIG_NUMA instead of CONFIG_NEED_MULTIPLE_NODES.

for now, selecting CONFIG_FLATMEM is safe, I think.

-Kame


-- 
VGER BF report: U 0.775508
