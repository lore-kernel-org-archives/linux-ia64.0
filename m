From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 17 Jun 2013 10:11:41 +0000
Subject: Re: [PATCH 2/2] mn10300: Fix include dependency in irqflags.h
Message-Id: <CAMuHMdU9dX61FrZBicFSaS6CKqox2OJ2iXJk6nq9VUf+ThkKLg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1371413189-2568-1-git-send-email-ddaney.cavm@gmail.com>
	<1371413189-2568-3-git-send-email-ddaney.cavm@gmail.com>
	<27908.1371460079@warthog.procyon.org.uk>
In-Reply-To: <27908.1371460079@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: David Daney <ddaney.cavm@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com, david.s.daney@gmail.com, David Daney <david.daney@cavium.com>

On Mon, Jun 17, 2013 at 11:07 AM, David Howells <dhowells@redhat.com> wrote:
> ddaney.cavm@gmail.com wrote:
>
>>  #ifndef __ASSEMBLY__
>> -#include <linux/smp.h>
>> +/* linux/smp.h <- linux/irqflags.h needs asm/smp.h first */
>> +#include <asm/smp.h>
>>  #endif
>
> If you make this change, is the #ifndef __ASSEMBLY__ still necessary, I
> wonder...

Seems to be fine, for asb2303_defconfig.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
