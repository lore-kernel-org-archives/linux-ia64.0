From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 10 Sep 2001 23:13:07 +0000
Subject: Re: [Linux-ia64] large binary question
Message-Id: <marc-linux-ia64-105590698805163@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805157@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805157@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>We tried to compile a "large" application on Linux/IA64, and get get this:
>/usr/bin/ld: ../FOO.05.x: short data segment overflowed (0x7a4588 >>0x400000)

The IA-64 ABI says that small variables (8 bytes or less) go in the
small data section.  There is also some relocation/addressing info that
goes in the small data section, like the .got.  If you have a lot of small
variables, you can overflow this section.  This section has a fixed size of
4MB due to the fact that the add instructions accepts a 22-bit immediate
operand.  The IA-64 ABI unfortunately has no provision for handling overflow
of this section.  Some targets like sparc-solaris have small-pic and big-pic,
where small-pic has a section limitation but big-pic does not.  IA-64 has no
equivalent.

You can reduce use of the small data section by using the GCC -mno-sdata
option.  This will stop putting small variables in sdata.  You may have
to recompile a lot of files with this option.  This will give slower code.

It is also possible that you are running into a linker bug.  There have
been a few problems where the linker put stuff in small data that shouldn't
have been there, causing it to overflow.  There is a known problem with
Fortran common blocks fixed 2 months ago.  Also, there were a number of
problems with using GNU ld to link code produced by the Intel compiler that
were fixed about 4 months ago.  If everything is in C/C++, and was compiled
by gcc, then it is pretty unlikely that you are seeing a linker bug.

>when trying to link it.  Running "size" on all the .o files, it looks like
>the combined text segment is about 15x10^6 bytes, as well as (more modest)
>460K data and 60K BSS between all the object files.

size alone won't tell you anything interesting, since it lumps too many
different sections together.  size is really only useful on systems using
the obsolete a.out object file format.  Use objdump -h, preferably, or
alternatively size -A.  It is the sdata and sbss sections that are primarily
of interest.  Also, some of the sections for relocation/addressing, like the
.got also end up in sdata.  If you are using objdump, and have a recent
enough copy of it, it will tell you what all of the "SMALL" sections are.

>Any ideas on how to link it?  Would it help to compile some of the files
>into a library first: would PIC code avoid the limit?

Code is always PIC.

Putting some code in a shared library would help, since shared libraries
have their own 4MB small data section.  Putting code in a static library will
not help.

Jim

