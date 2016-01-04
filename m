From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Date: Mon, 04 Jan 2016 12:03:11 +0000
Subject: Re: [PATCH v2 33/34] xenbus: use virt_xxx barriers
Message-Id: <alpine.DEB.2.02.1601041201120.19710@kaball.uk.xensource.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-34-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-34-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@or>

On Thu, 31 Dec 2015, Michael S. Tsirkin wrote:
> drivers/xen/xenbus/xenbus_comms.c uses
> full memory barriers to communicate with the other side.
> 
> For guests compiled with CONFIG_SMP, smp_wmb and smp_mb
> would be sufficient, so mb() and wmb() here are only needed if
> a non-SMP guest runs on an SMP host.
> 
> Switch to virt_xxx barriers which serve this exact purpose.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Reviewed-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>

Are you also going to take care of

drivers/xen/grant-table.c
drivers/xen/evtchn.c
drivers/xen/events/events_fifo.c
drivers/xen/xen-scsiback.c
drivers/xen/tmem.c
drivers/xen/xen-pciback/pci_stub.c
drivers/xen/xen-pciback/pciback_ops.c

?


>  drivers/xen/xenbus/xenbus_comms.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/xen/xenbus/xenbus_comms.c b/drivers/xen/xenbus/xenbus_comms.c
> index fdb0f33..ecdecce 100644
> --- a/drivers/xen/xenbus/xenbus_comms.c
> +++ b/drivers/xen/xenbus/xenbus_comms.c
> @@ -123,14 +123,14 @@ int xb_write(const void *data, unsigned len)
>  			avail = len;
>  
>  		/* Must write data /after/ reading the consumer index. */
> -		mb();
> +		virt_mb();
>  
>  		memcpy(dst, data, avail);
>  		data += avail;
>  		len -= avail;
>  
>  		/* Other side must not see new producer until data is there. */
> -		wmb();
> +		virt_wmb();
>  		intf->req_prod += avail;
>  
>  		/* Implies mb(): other side will see the updated producer. */
> @@ -180,14 +180,14 @@ int xb_read(void *data, unsigned len)
>  			avail = len;
>  
>  		/* Must read data /after/ reading the producer index. */
> -		rmb();
> +		virt_rmb();
>  
>  		memcpy(data, src, avail);
>  		data += avail;
>  		len -= avail;
>  
>  		/* Other side must not see free space until we've copied out */
> -		mb();
> +		virt_mb();
>  		intf->rsp_cons += avail;
>  
>  		pr_debug("Finished read of %i bytes (%i to go)\n", avail, len);
> -- 
> MST
> 
