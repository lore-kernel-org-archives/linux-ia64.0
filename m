From: j-nomura@ce.jp.nec.com
Date: Fri, 27 Feb 2004 05:38:14 +0000
Subject: Re: [Lse-tech] Re: fix zonelist ordering for NUMA
Message-Id: <20040227.143814.424258372.nomura@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <100070000.1077834062@flay>
In-Reply-To: <100070000.1077834062@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> >> +#ifndef node_distance
> >> +#define node_distance(from,to) (1)
> >> +#endif
> > 
> > 1 or 0 here?
> 
> Dunno ... was from j-nomura@ce.jp.nec.com, but I'd guess 1 makes more
> sense semantically - we're saying the distance between nodes on a flat
> NUMA architecture is equal (I think ;-))

Umm. Even on a flat NUMA architecture, I should have distinguish between
local and remote. It's NUMA.

#define node_distance(from,to) (from != to)

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com>
