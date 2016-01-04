From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 04 Jan 2016 21:07:13 +0000
Subject: Re: [PATCH 3/3] checkpatch: add virt barriers
Message-Id: <20160104230528-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451907395-15978-1-git-send-email-mst@redhat.com>
 <1451907395-15978-4-git-send-email-mst@redhat.com>
 <1451926073.4334.90.camel@perches.com>
In-Reply-To: <1451926073.4334.90.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Cc : Andy Whitcroft" <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

On Mon, Jan 04, 2016 at 08:47:53AM -0800, Joe Perches wrote:
> On Mon, 2016-01-04 at 13:37 +0200, Michael S. Tsirkin wrote:
> > Add virt_ barriers to list of barriers to check for
> > presence of a comment.
> 
> Are these virt_ barriers used anywhere?
> 
> I see some virtio_ barrier like uses.

They will be :) They are added and used by patchset
	        arch: barrier cleanup + barriers for virt

See
http://article.gmane.org/gmane.linux.kernel.virtualization/26555


-- 
MST
