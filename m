From: Matthew Wilcox <willy@debian.org>
Date: Sat, 23 Aug 2003 17:40:55 +0000
Subject: Re: Why sim/boot in -test4?
Message-Id: <marc-linux-ia64-106166075115091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106164660606242@msgid-missing>
In-Reply-To: <marc-linux-ia64-106164660606242@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Aug 23, 2003 at 10:32:20AM -0700, David Mosberger wrote:
> >>>>> On Sat, 23 Aug 2003 14:49:54 +0100, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> $ cvs diff -rLINUS_260_TEST3 -rLINUS_260_TEST4 arch/ia64/Makefile 
>   Matthew> [...]
>   Matthew> -boot := arch/ia64/boot
>   Matthew> +boot := arch/ia64/hp/sim/boot
> 
>   Matthew> Why was this change made?  It's not causing me any
>   Matthew> problems, just a bit of confusion when I noticed my
>   Matthew> previous vmlinux.gz wasn't getting updated any more.
> 
> It's just a general cleanup.  The bootloader ended up never being used
> for anything other than the simulator, so moving it to hp/sim makes sense.
> 
> Are you saying "make compressed" doesn't build vmlinux.gz anymore?  It
> seems to work for me.

Oh, it builds it, it just builds it inside the sim directory.  That's not
actually a problem, it just made me think there might be a problem.
Here's the messages:

  LD      vmlinux
  OBJCOPY arch/ia64/hp/sim/boot/vmlinux.bin
  GZIP    arch/ia64/hp/sim/boot/vmlinux.gz
  LN      vmlinux.gz
  Kernel: vmlinux.gz is ready

Since it used to do

  OBJCOPY arch/ia64/boot/vmlinux.bin
  GZIP    arch/ia64/boot/vmlinux.gz
  LN      vmlinux.gz

I thought I'd broken something with my other makefile change.

By the way, -test3 used to take a really really long time to link each
step, and -test4 doesn't.  I don't know whether this was an intentional
fix, but I'm certainly happy to see it.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
