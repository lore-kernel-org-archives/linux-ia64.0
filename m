From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 01 Jan 2016 17:23:46 +0000
Subject: Re: [PATCH v2 32/32] virtio_ring: use virt_store_mb
Message-Id: <5686B622.6070600@cogentembedded.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-33-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-33-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>

Hello.

On 12/31/2015 10:09 PM, Michael S. Tsirkin wrote:

> We need a full barrier after writing out event index, using
> virt_store_mb there seems better than open-coding.  As usual, we need a
> wrapper to account for strong barriers.
>
> It's tempting to use this in vhost as well, for that, we'll
> need a variant of smp_store_mb that works on __user pointers.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>   include/linux/virtio_ring.h  | 12 ++++++++++++
>   drivers/virtio/virtio_ring.c | 15 +++++++++------
>   2 files changed, 21 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
> index f3fa55b..3a74d91 100644
> --- a/include/linux/virtio_ring.h
> +++ b/include/linux/virtio_ring.h
> @@ -45,6 +45,18 @@ static inline void virtio_wmb(bool weak_barriers)
>   		wmb();
>   }
>
> +static inline void virtio_store_mb(bool weak_barriers,
> +				   __virtio16 *p, __virtio16 v)
> +{
> +	if (weak_barriers)
> +		virt_store_mb(*p, v);
> +	else
> +	{

    The kernel coding style dictates:

	if (weak_barriers) {
		virt_store_mb(*p, v);
	} else {

> +		WRITE_ONCE(*p, v);
> +		mb();
> +	}
> +}
> +
[...]

MBR, Sergei

