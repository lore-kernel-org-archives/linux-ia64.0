From: n0ano@indstorage.com
Date: Mon, 17 Dec 2001 17:11:35 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805706@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yoav-

It looks to me like your Intel compile thinks it's the default
compiler and it is therefore going to the default places to find
things, like libraries and what not.  I know how to fix this
for GCC but I'm not that familiar with the Intel compiler anymore.

The best solution is to install the Intel compile in such a way
that it finds the appropriate IA32 objects.  You'll probably have
to talk to your Intel compiler supplier about that.  (I just noticed
that you have an Intel address.  Talk to the compiler group, they
can tell you how to do this.)

As an interim solution I believe that the Intel compiler driver
program, `cc', merely spawns off different programs to do the
different phases of the compilation process, passing appropriate
parameters to the different programs.  If memory serves the
parameter `-#' will print out each command and its arguments.
You can do this, see what the actual link command is and then
manually execute the linker with parameters that point to IA32
objects.

On Sun, Dec 16, 2001 at 02:21:27PM +0200, Zach, Yoav wrote:
> 
> On September 25, 2001, David Mosberger wrote :
> 
> > Here is a long-awaited kernel update which brings us in sync with
> > 2.4.10.  As usual, it's available at
> ...
> >   with these fixes in place, I'm able to successfully run the ia32
> >   versions of realplay, OpenOffice, mozilla, netscape, acrobat, strace,
> >   Intel compilers, etc.  But as usual, your mileage may vary.
> 
> 
> I'm trying to run the Intel compiler for IA32 on an IA64 machine, kernel
> version 2.4.10. Compilation works fine, but on the link stage I get errors
> which indicate that the linker is trying to link IA64 libraries with the
> IA32 object file created at the compilation stage. For instance - 
> 
> /opt/intel/compiler60/ia32/lib/libcxa.so.1(*ABS*+0x722f0): multiple
> definition of `_DYNAMIC'
> /usr/lib/crt1.o(.dynamic+0x0): first defined here
> 
> and, more explicitly put - 
> 
> ld: hello.o: linking 64-bit files with 32-bit files
> Bad value: failed to merge target specific data of file hello.o
> 
> I guess it only an environment variable or command line switch that fixes
> the problem. Does anyone know how to fix it ?
> 
> 
> TIA,
> Yoav.
> 
> -----------------------------------------------
> Yoav Zach
> Phone:    972 4 865 5112
> Mail:        yoav.zach@intel.com
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

