From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 26 Apr 2000 17:57:57 +0000
Subject: Re: [Linux-ia64] 2.3.99-pre5 Kernel Compile
Message-Id: <marc-linux-ia64-105590678205053@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205048@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205048@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Perhaps the real question should be: why is it that gcc produces such
	bloated debug info?

I haven't looked at the ia64-linux kernel specifically, but in most cases the
problem is duplicated debug info for header files.  This is particularly a
problem for large C++ programs.  If a header file is included in twenty
different files, you end up with 20 copies of the debug info for that
header file.  This is something that everyone using DWARF2 eventually
complains about.  There are also a few other areas where the gcc DWARF2
implementation could be improved with respect to debug info size.

It is possible to eliminate a lot of the duplicate info in the linker.
However, because DWARF2 debug info is highly encoded to save space, this
would require the linker to decode the debug info, factor out common info,
and then re-encode the debug info.  This is a lot of work for the linker, and
is not easy to implement.

There is a DWARF2 standards committee that is working on a revision of the
DWARF2 standard, and one of the things that they are working on making it
easier to reduce the debug info size at link time.  If we could put header
file debug info in its own section for instance, then we can use normal linker
support for discarding duplicate sections to reduce the debug info size.
Cygnus is contributing to this committee, and I expect that we will be
implementing some of these new features in the gcc DWARF2 implementation.

People using stabs don't see this problem because stabs already has support
for eliminating duplicate header file debug info.  This is easy to do in
stabs, because there is no complicated encoding of the data that gets in the
way of identifying duplicate debug info.

Jim


