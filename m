From: Roman Hodek <roman@ns.caldera.de>
Date: Wed, 24 Oct 2001 12:14:28 +0000
Subject: Re: [Linux-ia64] framebuffer console
Message-Id: <marc-linux-ia64-105590698805382@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Would be nice to use CONFIG_FB_VESA so I was graphics card
> independent, but there is some x86 assembler in that source, and I
> believe it relies on video mode switching being done before the
> kernel starts as well.

Yep, vesafb is an i386-specific hack... :(
I already thought about a generic replacement, but EFI doesn't have
any resolution-related calls (AFAICS).

> So, has anyone else played with framebuffer console, and been more
> successful than me? Is the problem I'm seeing likely to be specific
> to my graphics card, or something more generic?

I've once played with it (some months ago), and aty128fb worked ok so
far. But I've only tested text on the console, no real graphics.
Anyway, your problems more sounds like portability problems in rivafb...

Roman

