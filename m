From: Andi Kleen <ak@suse.de>
Date: Fri, 19 Aug 2005 03:03:54 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-Id: <20050819030354.GG22993@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050818125236.4ffe1053.akpm@osdl.org> <p73y86ysz5c.fsf@verdi.suse.de> <20050819102706.62C7.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20050819102706.62C7.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>, peterc@gelato.unsw.edu.au, linux-mm@kvack.org, mbligh@mbligh.org, linux-ia64@vger.kernel.org, kravetz@us.ibm.com, tony.luck@intel.com

On Fri, Aug 19, 2005 at 11:29:32AM +0900, Yasunori Goto wrote:
> To hot-add a node, it is better that pgdat link list is removed.
> (Hot add code will set JUST node_online_map by it.)
> I posted a patch to remove this link list 3 month ago.
> http://marc.theaimsgroup.com/?l=linux-mm&m1596924629564&w=2
> http://marc.theaimsgroup.com/?l=linux-mm&m1596953711780&w=2

Agreed that's a better solution than my patch, and should
fix that bug too.

-Andi
