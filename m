From: duraid@fl.net.au
Date: Wed, 30 Jan 2002 06:44:54 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805953@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Quoting Niels Christiansen <nchr@us.ibm.com>:

> I tried using gcc 3.0.2 on a RedHat 7.2 4-way with 2.4.16 kernel
> but got errors as shown below.  I have a profiling tool (currently
> internal use only) which I intended to use but I need the make to
> succeed first...

Okay I'll come clean: these are the compilers I've tested:

gcc version 2.96 20000731 (Debian GNU/Linux IA64 experimental)

Reading specs from /usr/lib/gcc-lib/ia64-linux/3.0.3/specs
Configured with: ../src/configure -v
--enable-languages=c,c++,java,f77,proto,objc --prefix=/usr --infodir=/share/info
--mandir=/share/man --enable-shared --with-gnu-as --with-gnu-ld
--with-system-zlib --enable-long-long --enable-nls --without-included-gettext
--disable-checking --enable-threads=posix --enable-java-gc=boehm
--with-cpp-install-dir=bin --enable-objc-gc ia64-linux
Thread model: posix
gcc version 3.0.3

and finally:

Intel(R) C++ Itanium(TM) Compiler for Itanium(TM)-based applications
Version 6.0 Beta, Build 20011129 

The program builds OK with all three of those, but the source needs a bit of
twiddling to work with the Intel compiler.
 
> You say you run on an SMP.  How many processors?

4 processors in the box, but it's just a single-threaded code.

     Duraid

P.S. looks like your binutils is a bit out of date?




-------------------------------------------------
This mail sent through IMP: http://horde.org/imp/

