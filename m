From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 12 Jan 2001 02:30:47 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.0)
Message-Id: <marc-linux-ia64-105590693005036@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I got the source of the tool chain, but i could find how to build this
>source to generate the
>compiler, linker binaries from this.

In general, for most FSF programs, the build process is the same.
Unpack the sources so that you have a src directory.  Then something like
       mkdir build
       cd build
       ../src/configure
       make
       make install
This will build a native toolchain including everything.

If you don't want to install in /usr/local, you can change that directory
name with the configure option --prefix=<path>.

If you don't want the gdb gui, including tcl/tk/tix/itcl/etc, then you
can use the configure option --disable-gdbtk.

For a cross, there are a few extra steps.  You need libraries and header files
from the target.  You can grab /usr/lib and /usr/include from the target and
put them on your build machine.  Then use the --with-libs=<path> and
--with-headers=<path> configure options to point at the target library and
header files respectively.  You also need the --target=ia64-linux configure
option to indicate that this is a cross to ia64-linux.

There is documentation on this stuff, but it is scattered around a bit.
There is a toplevel README file that contains some info, with pointers
to tool specific README files like gcc/README, which in turn point at other
files.  Red Hat has some nice printed documentation that we give to customers,
but it isn't in a convenient form for our purposes.  It is done in FrameMaker
I believe.  There is also some online stuff, for instance
http://gcc.gnu.org/install/index.html.  This is gcc specific, but most of
this stuff is the same for all of the other parts of the toolchain.

Jim

