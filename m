From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 13 Aug 2004 00:14:03 +0000
Subject: Re: r996 - in trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7: . debian
Message-Id: <200408121714.03322.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040810071417.GA5080@lst.de>
In-Reply-To: <20040810071417.GA5080@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, August 12, 2004 5:07 pm, Alex Williamson wrote:
>    The point is to be able to provide a working UP kernel.  A generic
> kernel shouldn't be limited to SMP, and NUMA doesn't make much sense on
> a UP kernel....

A UP kernel can still have lots of nodes, but I agree that CONFIG_NUMA and 
CONFIG_DISCONTIGMEM are pretty mixed up atm.

Jesse
