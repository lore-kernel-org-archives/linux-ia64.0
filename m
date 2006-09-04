From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 04 Sep 2006 06:37:29 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <20060904153729.451e8f48.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 4 Sep 2006 15:23:25 +0900
Horms <horms@verge.net.au> wrote:

> Hi,
> 
> I'm trying to build a non-NUMA (HP_SIM) config, and I am running
> into trouble because there are serveral places where NODE_DATA is
> used. It seems to me that this makes little sense as NODE_DATA
> needs the node_data element of struct cpuinfo_ia64, which doesn't
> exist without CONFIG_NUMA.
> 
> Is CONFIG_NUMA mandatory or is this just an oversight?
> 

Could you attach your .config ?

-Kame


-- 
VGER BF report: U 0.510073
