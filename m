From: Bruce Losure <blosure@americas.sgi.com>
Date: Tue, 06 Sep 2005 13:46:21 +0000
Subject: Re: [PATCH] Altix patch for fpga reset
Message-Id: <Pine.LNX.4.44.0509060844350.27976-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0509021513240.12217-100000@fsgi025.americas.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0509021513240.12217-100000@fsgi025.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 3 Sep 2005, Christoph Hellwig wrote:

> On Fri, Sep 02, 2005 at 03:16:35PM -0500, Bruce Losure wrote:
> > 
> > Tony,
> > 
> > Here is a patch to 1) workaround a h/w reset issue and 2) to improve the
> > determination of FPGA-based h/w in the arch/ia64/sn/kernel/tiocx code.
> 
> You still haven't shown any actual users of that interface, we probably
> should just remove it instead.
> 

drivers/char/mbcs.c use code from tiocx.c.    We have customers with h/w
who are using this code.

-- 
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121

