From: "Zach, Yoav" <yoav.zach@intel.com>
Date: Sun, 16 Dec 2001 12:21:27 +0000
Subject: RE: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805705@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On September 25, 2001, David Mosberger wrote :

> Here is a long-awaited kernel update which brings us in sync with
> 2.4.10.  As usual, it's available at
...
>   with these fixes in place, I'm able to successfully run the ia32
>   versions of realplay, OpenOffice, mozilla, netscape, acrobat, strace,
>   Intel compilers, etc.  But as usual, your mileage may vary.


I'm trying to run the Intel compiler for IA32 on an IA64 machine, kernel
version 2.4.10. Compilation works fine, but on the link stage I get errors
which indicate that the linker is trying to link IA64 libraries with the
IA32 object file created at the compilation stage. For instance - 

/opt/intel/compiler60/ia32/lib/libcxa.so.1(*ABS*+0x722f0): multiple
definition of `_DYNAMIC'
/usr/lib/crt1.o(.dynamic+0x0): first defined here

and, more explicitly put - 

ld: hello.o: linking 64-bit files with 32-bit files
Bad value: failed to merge target specific data of file hello.o

I guess it only an environment variable or command line switch that fixes
the problem. Does anyone know how to fix it ?


TIA,
Yoav.

-----------------------------------------------
Yoav Zach
Phone:    972 4 865 5112
Mail:        yoav.zach@intel.com

