From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Mon, 03 Oct 2005 05:19:53 +0000
Subject: Re: [PATCH]Remove pgdat list ver.2 [1/2]
Message-Id: <20051003135936.0EAE.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930205919.7019.Y-GOTO@jp.fujitsu.com> <1128096445.6145.36.camel@localhost>
In-Reply-To: <1128096445.6145.36.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>

> This works around my compile problem for now.  But, it might cause some
> more issues.  Can you take a closer look?

It works well in my ia64 box.
But, I have not understood why this patch moves also the lines from
is_highmem_idx() to lowmem_reserve_ratio_sysctl_handler() yet.
Is it necessary?
If no, the patch becomes a bit smaller. :-)

Thanks.

-- 
Yasunori Goto 

