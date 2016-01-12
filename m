From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 12 Jan 2016 08:43:36 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160112103913-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com>
 <56945366.2090504@imgtec.com>
In-Reply-To: <56945366.2090504-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawuUor55F778Sg@public.gmane.org

On Mon, Jan 11, 2016 at 05:14:14PM -0800, Leonid Yegoshin wrote:
> On 01/10/2016 06:18 AM, Michael S. Tsirkin wrote:
> >On mips dma_rmb, dma_wmb, smp_store_mb, read_barrier_depends,
> >smp_read_barrier_depends, smp_store_release and smp_load_acquire  match
> >the asm-generic variants exactly. Drop the local definitions and pull in
> >asm-generic/barrier.h instead.
> >
> This statement doesn't fit MIPS barriers variations. Moreover, there is a
> reason to extend that even more specific, at least for smp_store_release and
> smp_load_acquire, look into
> 
>     http://patchwork.linux-mips.org/patch/10506/
> 
> - Leonid.

Fine, but it matches what current code is doing.  Since that
MIPS_LIGHTWEIGHT_SYNC patch didn't go into linux-next yet, do
you see a problem reworking it on top of this patchset?

-- 
MST
