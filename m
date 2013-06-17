From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 17 Jun 2013 07:28:24 +0000
Subject: Re: [PATCH 1/2] ia64: Fix include dependency in asm/irqflags.h
Message-Id: <CAMuHMdXQxacjQHMCxvOVx6FduXnWmsKvCjSsHX9U3kpR0b8wiQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1371413189-2568-1-git-send-email-ddaney.cavm@gmail.com>
	<1371413189-2568-2-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1371413189-2568-2-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com, david.s.daney@gmail.com, David Daney <ddaney@caviumnetworks.com>, David Daney <david.daney@cavium.com>

On Sun, Jun 16, 2013 at 10:06 PM,  <ddaney.cavm@gmail.com> wrote:
> asm/kregs.h isn't always included first, so we need an explicit include.

Thanks, this fixes the build!

> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
