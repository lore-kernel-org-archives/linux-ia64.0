From: Doug Beattie <dbb@caldera.com>
Date: Mon, 17 Sep 2001 16:02:14 +0000
Subject: [Linux-ia64] PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805193@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Your reponse is welcome and invited.

The LSB and FHS groups are trying to better address the coexistance of
32 and 64 bit in the 64 bit Itanium environment.

Please review the following proposal and respond to the
"lsb-spec@lists.linuxbase.org" and "lsb-discuss@lists.linuxbase.org"
mail lists.

Thanks,
Doug

George Kraft IV wrote:
> 
> FHS & LSB teams,
> 
> IBM and SuSE has the following suggestion regarding 32/64bit coexistance.
> 
> George (gk4)
> 
> > > 32/64bit executable coexistence
> > >
> > > 32/64bit executable coexistence on architectures with 32/64bit
> > > backward compatibility
> > >
> > > Introduction
> > >
> > > Linux has been ported to serveral different architectures and is
> > > now available for both 32bit and 64bit processors. Some of these
> > > architectures and their implementations in hardware already allow
> > > or will allow parallel execution of 32bit and 64bit applications
> > > in the very same single operating system instance.
> > >
> > > As the 32bit and 64bit instances of libraries like glibc usually
> > > are named identically due to the same source code base, they
> > > cannot reside in the same directory of the Linux file system
> > > hierarchy.
> > >
> > > There is a decision to be made about the location and naming
> > > conventions for the dedicated libraries, if backward
> > > compatibility of existing 32bit applications on 64bit systems is
> > > desired.
> > >
> > > Discussion
> > >
> > > Until now two significant 64bit Linux ports are available using a
> > > 64bit kernel and 64bit userland: Compaq Alpha and Intel Itanium
> > > based systems. Theses ports fully exploit the 64bit architecure;
> > > nevertheless they are able to run 32bit code, too.
> > >
> > > The new emerging or potential ports for AMD x86-64, IBM pSeries /
> > > iSeries Power3/4, SPARC32/64 and IBM zSeries approach the 64bit
> > > area in different ways:
> > >
> > > - AMD x86-64 can be regarded as transparently extending the 32bit
> > >   architecture by 64bit features
> > >
> > > - ipSeries today only have 32bit based kernels and userland
> > >   available, but are expected to have 64bit kernel in the near
> > >   future (same as x86-64)
> > >
> > > - SPARC runs 64bit and 32bit based kernels, userland is mostly
> > >   32bit based, with 64bit based libs available, too (same as
> > >   x86-64, ipSeries)
> > >
> > > - S/390 and zSeries can be supported in either way: S/390 by
> > >   31/32bit kernel and userland, zSeries with 64bit kernel and
> > >   32bit and 64 bit userland executables.
> > >
> > > Applications can be build either using 32bit or 64bit and are
> > > usually compiled to use dedicated shared libraries of each type.
> > > If one application runs in 64bit, it can only use 64bit
> > > libraries. The same applies for 32bit. There's no way to use both
> > > 32-bit and 64-bit libraries in one application.
> > >
> > > Loading the depending functions and libraries is done during
> > > execution by the dynamic loader. It needs to know dedicated file
> > > system pathes to search for available libraries.
> > >
> > > The Linux File Hierarchy Standard FHS Version 2.2 final
> > > (http://www.pathname.com/fhs/) supports both file location and
> > > naming conventions for such libraries: /lib32 and /lib64 to place
> > > 32bit and 64bit libraries. Relevant paragraphs are:
> > >
> > > [...]
> > > 3.10.2  Requirements -> footnote 12:
> > > This is commonly used for 64-bit or 32-bit support on systems
> > > which support multiple  binary formats, but require libraries
> > > of the same name. In this case, /lib32 and /lib64 might be the
> > > library directories, and /lib a symlink to one of them.
> > > [...]
> > >
> > > On 'pure' 64bit systems the natural location would be /lib for
> > > those libraries and 32bit libs would be placed in /lib32 (Linux
> > > for iA64, L/Alpha, and L/zSeries have been implemented this way).
> > >
> > > While this naming conventions seems quite obvious and natural it
> > > is not backward compatible: existing 32bit applications will
> > > install and search their 32bit shared libs in /lib which will
> > > only contain 64bit libs. A symbolic link or renaming to  /lib ->
> > > /lib32 will conflict with installed 64bit applications on the
> > > system. This is clearly not an issue for the loader, that will
> > > be able to properly select the library to load from, but will be an
> > > issue for all existing 32bit applications and their install scripts
> > > and the like, not knowing about the hybrid nature of a 32/64bit
> > > system environment. Thus we're suggesting that /lib is always a
> > > symbolic link to /lib32 to grant backward compatibility and new 64bit
> > > applications to use and install into /lib64.
> 
> --
> George Kraft IV
> gk4@austin.ibm.com

-- 
Douglas B. Beattie
------------------
Linux Test Architect - Caldera, Inc.
dbb@caldera.com

