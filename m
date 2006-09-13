From: Robin Holt <holt@sgi.com>
Date: Wed, 13 Sep 2006 15:03:06 +0000
Subject: Re: [patch] trim output of show_mem()
Message-Id: <20060913150306.GB14925@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0zmd3esi7.fsf@jaguar.mkp.net>
In-Reply-To: <yq0zmd3esi7.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This patch goes on top of the patch I posted earlier today. It trims
> the number of lines of memory information output per node down from 5
> lines to one line per node. Kinda helps if you have 1024 live nodes in

That is a great improvement!

> +		printk(KERN_INFO "Node %d:", pgdat->node_id);
...
> +		printk("\tRAM: %ld, reserved: %d, shared: %d, "
> +		       "swap cached: %d\n", present, reserved, shared, cached);

What about making these fixed width fields.

> +		printk(KERN_INFO "Node %4d: ", pgdat->node_id);
...
> +		printk("RAM: %11ld, rsvd: %8d, shrd: %10d, swpd: %10d\n",
> +				present, reserved, shared, cached);

Note, I changed the one tab to a space and abbreviated.  This puts things
into an 80 column display.  How would you feel about putting the two printks
together?

Thanks,
Robin
