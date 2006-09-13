From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 13 Sep 2006 17:28:15 +0000
Subject: Re: [patch] show_mem() printk levels
Message-Id: <Pine.LNX.4.64.0609131026320.17927@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq04pvcey2p.fsf@jaguar.mkp.net>
In-Reply-To: <yq04pvcey2p.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Sep 2006, Jes Sorensen wrote:

> Index: linux-2.6/arch/ia64/mm/contig.c
> =================================> --- linux-2.6.orig/arch/ia64/mm/contig.c
> +++ linux-2.6/arch/ia64/mm/contig.c
>  
> -	printk("Mem-info:\n");
> +	printk(KERN_INFO "Mem-info:\n");
>  	show_free_areas();

^^^ This will print 1 mio cpuset descriptions on a 1k cpu / 1k node 
system to the console. Could we just drop calling show_free_areas()?
