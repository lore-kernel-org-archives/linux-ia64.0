From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 03 Jan 2016 09:01:05 +0000
Subject: Re: [PATCH v2 32/32] virtio_ring: use virt_store_mb
Message-Id: <20160103110052-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-33-git-send-email-mst@redhat.com>
 <5686B622.6070600@cogentembedded.com>
In-Reply-To: <5686B622.6070600-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org

On Fri, Jan 01, 2016 at 08:23:46PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/31/2015 10:09 PM, Michael S. Tsirkin wrote:
> 
> >We need a full barrier after writing out event index, using
> >virt_store_mb there seems better than open-coding.  As usual, we need a
> >wrapper to account for strong barriers.
> >
> >It's tempting to use this in vhost as well, for that, we'll
> >need a variant of smp_store_mb that works on __user pointers.
> >
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >---
> >  include/linux/virtio_ring.h  | 12 ++++++++++++
> >  drivers/virtio/virtio_ring.c | 15 +++++++++------
> >  2 files changed, 21 insertions(+), 6 deletions(-)
> >
> >diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
> >index f3fa55b..3a74d91 100644
> >--- a/include/linux/virtio_ring.h
> >+++ b/include/linux/virtio_ring.h
> >@@ -45,6 +45,18 @@ static inline void virtio_wmb(bool weak_barriers)
> >  		wmb();
> >  }
> >
> >+static inline void virtio_store_mb(bool weak_barriers,
> >+				   __virtio16 *p, __virtio16 v)
> >+{
> >+	if (weak_barriers)
> >+		virt_store_mb(*p, v);
> >+	else
> >+	{
> 
>    The kernel coding style dictates:
> 
> 	if (weak_barriers) {
> 		virt_store_mb(*p, v);
> 	} else {
> 
> >+		WRITE_ONCE(*p, v);
> >+		mb();
> >+	}
> >+}
> >+
> [...]
> 
> MBR, Sergei

Will fix, thanks!
