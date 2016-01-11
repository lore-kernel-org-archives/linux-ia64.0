From: Julian Calaby <julian.calaby@gmail.com>
Date: Mon, 11 Jan 2016 11:06:14 +0000
Subject: Re: [PATCH v4 0/3] checkpatch: handling of memory barriers
Message-Id: <CAGRGNgXnxjmvjD8_vT17ZWwK0uCsGNmXq_KdVj9KoT6NRZQvPA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452509968-19778-1-git-send-email-mst@redhat.com> <20160111130334-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160111130334-mutt-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux <sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Mailing List, Arm" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Hi Michael,

On Mon, Jan 11, 2016 at 10:04 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Mon, Jan 11, 2016 at 12:59:25PM +0200, Michael S. Tsirkin wrote:
>> As part of memory barrier cleanup, this patchset
>> extends checkpatch to make it easier to stop
>> incorrect memory barrier usage.
>>
>> This replaces the checkpatch patches in my series
>>       arch: barrier cleanup + barriers for virt
>> and will be included in the pull request including
>> the series.
>>
>> changes from v3:
>>       rename smp_barrier_stems to barrier_stems
>>       as suggested by Julian Calaby.
>
> In fact it was Joe Perches that suggested it.
> Sorry about the confusion.

I was about to point that out.

FWIW this entire series is:

Acked-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
