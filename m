From: Jim Wilson <wilson@specifixinc.com>
Date: Thu, 15 Jul 2004 19:32:52 +0000
Subject: Re: problem with ski & NUE
Message-Id: <1089919973.3167.14.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040715133007.46413.qmail@web14205.mail.yahoo.com>
In-Reply-To: <20040715133007.46413.qmail@web14205.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-07-15 at 06:30, Daniele Velardi wrote:
> "BFD:Dwarf Error: Invalid or unhandled FORM value: 14.
> Segmentation fault"! 

That happens when you use an old bfd library to try to read an object
file created by a recent bfd library.  Form 14 is DW_FORM_strp (string
pointer), which is used by recent bfd versions to optimize away
duplicate strings in the debug info.  This helps reduce object file
size.  But older bfd's that lack DW_FORM_strp support will get confused,
and may fail.

So presumably the problem here is that the ski binary you have was
linked against an old bfd version, and the vmlinux binary you have was
created with a recent bfd (binutils) version.  You are probably out of
luck unless you can get a updated ski version.  If ski is perhaps using
a shared library libbfd.so on your system, then updating that library
(or updating the OS) may help.  Try running ldd on the ski binary.

Stripping the debug info from vmlinux may get you past this problem, but
then you won't be able to debug the linux kernel.

>ski:/usr/i386-glibc21-linux/lib/libpthread.so.0:
>version `GLIBC_2.2' not found (required by ski) 
>ski:/usr/i386-glibc21-linux/lib/libpthread.so.0:
>version `GLIBC_2.3.2' not found (required by ski) 

This likely means you have an old OS installed on your system, an OS
that came with glibc-2.1, and ski was compiled on a system with a newer
OS that came with glibc-2.2 and/or glibc-2.3.  You probably have to try
a newer OS.  You could maybe install a newer glibc version on your
system, but building glibc isn't easy.  Installing a newer OS is easier.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

