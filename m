From: Robin Holt <holt@sgi.com>
Date: Tue, 08 Sep 2009 07:34:06 +0000
Subject: Re: [PATCH] sgi-xp: fix printk format warnings
Message-Id: <20090908073406.GA9842@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090904170259.02ed92ea.randy.dunlap@oracle.com>
In-Reply-To: <20090904170259.02ed92ea.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 04, 2009 at 05:02:59PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix warnings in SGI XPC sn2 driver:  lots of printk format warnings
> 
> and:
> drivers/misc/sgi-xp/xpc_sn2.c: In function 'xpc_get_partition_rsvd_page_pa_sn2':
> drivers/misc/sgi-xp/xpc_sn2.c:618: warning: passing argument 3 of 'sn_partition_reserved_page_pa' from incompatible pointer type
> drivers/misc/sgi-xp/xpc_sn2.c:618: warning: passing argument 4 of 'sn_partition_reserved_page_pa' from incompatible pointer type
> 
> (likely due to generic u64 / long long changes)
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Acked-by: Robin Holt <holt@sgi.com>
