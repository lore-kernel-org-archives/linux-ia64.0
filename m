From: Jack Steiner <steiner@sgi.com>
Date: Fri, 24 Jun 2005 01:31:32 +0000
Subject: Re: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <20050624013132.GA19726@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Index: linux-2.6.12/arch/ia64/sn/kernel/io_init.c
> =================================> --- linux-2.6.12.orig/arch/ia64/sn/kernel/io_init.c	2005-06-17 12:48:29.000000000 -0700
> +++ linux-2.6.12/arch/ia64/sn/kernel/io_init.c	2005-06-23 13:55:02.000000000 -0700
> @@ -364,6 +364,8 @@ static void sn_pci_controller_fixup(int 
>  
>  	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
>  	cnode = nasid_to_cnodeid(nasid);
> +	if (cnode < num_online_nodes() && cnode < numionodes)
> +		controller->node = cnode;

This doesn't look right. 

The code works for normal nodes (not TIO). For TIO nodes, the node number that
is returned by physical_node_map() is NOT a node number that is known to 
VM. 


>  	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
>  	SN_PCIBUS_BUSSOFT(bus)->bs_xwidget_info >  	    &(hubdev_info->hdi_xwidget_info[SN_PCIBUS_BUSSOFT(bus)->bs_xid]);

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


