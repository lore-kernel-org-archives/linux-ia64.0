From: Martin Pool <mbp@samba.org>
Date: Wed, 06 Aug 2003 06:19:19 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106015083900529@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106015002132453@msgid-missing>
In-Reply-To: <marc-linux-ia64-106015002132453@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On  5 Aug 2003, David Mosberger <davidm@napali.hpl.hp.com> wrote:
> >>>>> On Wed, 6 Aug 2003 16:00:28 +1000, Martin Pool <mbp@samba.org> said:
> 
>   Martin> As of linux-2.6.0-test2-ia64-030729, there seems to be no
>   Martin> asm-ia64/floppy.h, and so the fd driver won't work.
> 
>   Martin> Might this patch to make sure it does not accidentally get
>   Martin> configured on be accepted?
> 
> Perhaps the check should be against ISA instead?  Or are there non-ISA
> systems with such a floppy controller?  In any case, the final
> decision of course rests with the maintainer of block/Kconfig
> (probably best to bring it up on lkml).

Other systems (such as Amiga and m68k) have non-ISA floppy drives,
which are reached through an ad-hoc abstraction layer defined by
different implementations of asm/floppy.h:

  ~/work/linux/linux-2.6.0test2-ia64/include/:
  find . \( -name floppy.h \) -exec ls -ld {} \;
  -rw-r--r--    4 mbp      mbp          3721 Jul 11 06:12 asm-arm26/floppy.h
  -rw-r--r--    5 mbp      mbp          6155 Dec 10  2002 asm-parisc/floppy.h
  -rw-r--r--    5 mbp      mbp          2719 Dec 10  2002 asm-ppc64/floppy.h
  -rw-r--r--    5 mbp      mbp            82 Dec 10  2002 asm-um/floppy.h
  -rw-r--r--    2 mbp      mbp          5322 Jul 29 12:07 asm-m68k/floppy.h
  -rw-r--r--    2 mbp      mbp          6706 Jul 29 12:06 asm-x86_64/floppy.h
  -rw-r--r--    5 mbp      mbp          1795 Dec 10  2002 asm-ppc/floppy.h
  -rw-r--r--   13 mbp      mbp          3763 Aug 13  2001 asm-arm/floppy.h
  -rw-r--r--    4 mbp      mbp          3702 Jul 29 12:06 asm-mips/floppy.h
  -rw-r--r--    4 mbp      mbp         10371 Jul 11 06:04 asm-sparc/floppy.h
  -rw-r--r--    5 mbp      mbp          3351 Dec 10  2002 asm-alpha/floppy.h
  -rw-r--r--    4 mbp      mbp          7352 Jul 11 06:06 asm-i386/floppy.h
  -rw-r--r--    2 mbp      mbp         21132 Jul 29 12:07 asm-sparc64/floppy.h
  -rw-r--r--    4 mbp      mbp          3702 Jul 29 12:06 asm-mips64/floppy.h
  -rw-r--r--    2 mbp      mbp          6279 Jul 29 12:06 asm-sh/floppy.h

It looks like there are some similarities, but also many differences,
between support for different platforms.  I didn't want to get into
trying to unify them, which would probably be a much larger project.

Are there any ia64 machines which come with floppy drives?  If there
aren't, I'd like to be able to tell the maintainer so.

Thanks
-- 
Martin 
