From: David Howells <dhowells@redhat.com>
Date: Mon, 17 Jun 2013 09:07:59 +0000
Subject: Re: [PATCH 2/2] mn10300: Fix include dependency in irqflags.h
Message-Id: <27908.1371460079@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1371413189-2568-3-git-send-email-ddaney.cavm@gmail.com> <1371413189-2568-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1371413189-2568-3-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ddaney.cavm@gmail.com
Cc: dhowells@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com, david.s.daney@gmail.com, David Daney <david.daney@cavium.com>

ddaney.cavm@gmail.com wrote:

>  #ifndef __ASSEMBLY__
> -#include <linux/smp.h>
> +/* linux/smp.h <- linux/irqflags.h needs asm/smp.h first */
> +#include <asm/smp.h>
>  #endif

If you make this change, is the #ifndef __ASSEMBLY__ still necessary, I
wonder...

David
