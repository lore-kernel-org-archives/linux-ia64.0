From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Wed, 09 Mar 2005 10:37:29 +0000
Subject: Re: cpu_to_node_map on UP systems
Message-Id: <20050309103729.GB13925@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110350919.9439.16.camel@localhost>
In-Reply-To: <1110350919.9439.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi dann

On Tue, 08 Mar 2005, dann frazier wrote:

> In 2.6.11, cpu_to_node_map has moved from numa.c to smpboot.c.  Since
> smpboot.c isn't built on non-SMP systems, this causes non-smp builds to
> fail to link in various places.
> 
> I don't know what the right answer is here - resurrect numa.c maybe?
We do not seem to have a problem on our Autobuild with CONFIG_SMP=n
http://www.gelato.unsw.edu.au/kerncomp/

Just tested latest bk ChangeSet@1.2028, 2005-03-08 16:26:54-08:00, gregkh@suse.de
tiger_defconfig
CONFIG_SMP=n

plus removal of some unwanted drivers builds OK


> 
> -- 
> dann frazier <dannf@hp.com>
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
