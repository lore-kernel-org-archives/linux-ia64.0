From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 May 2004 20:24:56 +0000
Subject: Re: [PATCH] fix MOD_{INC,DEC}_USE_COUNT use in prominfo
Message-Id: <200405071324.56726.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040507104545.GA10909@lst.de>
In-Reply-To: <20040507104545.GA10909@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, May 7, 2004 3:45 am, Christoph Hellwig wrote:
> set proper proc_entry owner instead.  btw, the file is complete mess and
> wants a rewrite at least - if not a rearchitecture for a saner
> interface.

The fixes look fine.  I'm hoping to put this info into sysfs under each node 
at some point, but I've got to get Greg's ok about the format and how it's 
presented.

Jesse
