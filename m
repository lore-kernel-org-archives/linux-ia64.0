From: Jim Wilson <wilson@specifixinc.com>
Date: Mon, 19 Jul 2004 17:41:37 +0000
Subject: Re: problem creating cross compile ia64
Message-Id: <1090258898.1070.14.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040719130226.3282.qmail@web14205.mail.yahoo.com>
In-Reply-To: <20040719130226.3282.qmail@web14205.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-07-19 at 06:02, Daniele Velardi wrote:
> I have to create a cross compiler to run on host
> machine i686 to compile file for target machine
> ia64:

The best source of info I know of for building linux cross compilers is
Dan Kegel's crosstool.  See
    http://kegel.com/crosstool
This is a collection of scripts to automate the process of building a
cross compiler from gcc and glibc sources.

If all you want is a cross compiler for building the kernel, then you
are already done.  You don't need any of the libraries, as the kernel
doesn't use them, so you can ignore the errors you are getting and just
install what you have.  It might be confusing to have a compiler
installed that can only work for compiling kernels though; I don't
generally recommend doing this.

If you want to compile anything other than the kernel, then you have to
have the libraries.  This can be built from gcc and glibc sources by
using Kegel's crosstool above, or it can be built from gcc source by
copying libraries/header files from the target IA-64 machine.  The new
way involves using --with-sysroot, the old way involves using
--with-headers and --with-libs.  I don't recall if --with-sysroot is in
3.3.3, but it is is in 3.3.4.  If you don't have a convenient IA-64
machine to copy libraries and header files from, then crosstool might be
a better choice.

> configure --disable-nls --prefix=/usr
> --mandir=/usr/share/man --infodir=/usr/share/info   
> --target=ia64-linux

It isn't a good idea to configure a cross-compiler using --prefix=/usr. 
The cross compiler might think its header files are in /usr/include and
its libraries in /usr/lib.  They aren't.  Better is to use something
like /opt or /usr/local.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

