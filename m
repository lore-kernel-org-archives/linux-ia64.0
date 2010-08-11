From: Julia Lawall <julia@diku.dk>
Date: Wed, 11 Aug 2010 16:23:28 +0000
Subject: Re: [PATCH 5/5] drivers/serial: Return -ENOMEM on memory allocation
Message-Id: <Pine.LNX.4.64.1008111818380.8669@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.1008111211440.8669@ask.diku.dk> <4C62C8F3.3090405@sgi.com>
In-Reply-To: <4C62C8F3.3090405@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

> > I believe this code also leaks earlier instances of port, which are only
> > referenced by card_ptr, which is freed in the error handling code at the
> > end of the function.  A lot of operations are done on port on each
> > iteration, however, so I'm not sure whether it is good enough to just free
> > them.  Perhaps there is some way to call ioc3uart_remove?
> > 
> 
> Yes you are right, there should be something like this for out4:
> 
> out4:
> 	for (phys_port = 0; phys_port < PORTS_PER_CARD; phys_port++) {
> 		port = card_ptr->ic_port[phys_port].icp_port;
> 		if (port) {
> 			pci_free_consistent(port->ip_idd->pdev,
>                                        TOTAL_RING_BUF_SIZE,
>                                        (void *)port->ip_cpu_ringbuf,
>                                        port->ip_dma_ringbuf);
> 			kfree(port);
> 		}
> 	}
> 	kfree(card_ptr);
> 	return ret;

Actually, pci_alloc_consistent is only called when phys_port is 0.  In the 
subsequent cases, the ip_dma_ringbuf field is just initialized to the 
previous value.  So it could be:

out4:
        for (phys_port = 0; phys_port < PORTS_PER_CARD; phys_port++) {
                port = card_ptr->ic_port[phys_port].icp_port;
                if (port) {
			if (phys_port = 0)
	                        pci_free_consistent(port->ip_idd->pdev,
                                       TOTAL_RING_BUF_SIZE,
                                       (void *)port->ip_cpu_ringbuf,
                                       port->ip_dma_ringbuf);
                        kfree(port);
                }
        }
        kfree(card_ptr);
        return ret;

julia
