From: Richard Hirst <rhirst@linuxcare.com>
Date: Wed, 24 Oct 2001 10:30:33 +0000
Subject: [Linux-ia64] framebuffer console
Message-Id: <marc-linux-ia64-105590698805378@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
  I've been trying to use the framebuffer console to display simple
graphics with only partial success.  I'm using an nVidia Quadro2 card,
and a 2.4.9 kernel.

Would be nice to use CONFIG_FB_VESA so I was graphics card independent,
but there is some x86 assembler in that source, and I believe it relies
on video mode switching being done before the kernel starts as well.

So, I've compiled with CONFIG_FB_RIVA, and am experimenting with fbi, a
simple image viewer for the framebuffer console.  This mmaps the framebuffer
memory, and tries to memcpy() in to it.  That reliably causes hard
crashes and spontaneous system reboots.  If I hack fbi to do lseek/write
on /dev/fb0 rather than mmap(), it seems to work ok.

When using mmap() I sometimes see parts of my image on the screen before
it crashes, and the pattern of bits that are drawn (or not) indicate
that some small blocks of data (cachelines?) are not written to the
video memory while other similar sized blocks are written.  As the system
crashes so badly, I guess the missing blocks are written elsewhere.

The other thing that struck me as odd (but unrelated) was that on boot I
get two penguins at the top of the screen, where I'd expected only one..

So, has anyone else played with framebuffer console, and been more
successful than me?  Is the problem I'm seeing likely to be specific
to my graphics card, or something more generic?

Thanks,
  Richard


