From: Einar Saltnes <eisa@scali.no>
Date: Wed, 19 Jul 2000 15:30:23 +0000
Subject: [Linux-ia64] IA64 Linux library problem
Message-Id: <marc-linux-ia64-105590678205213@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello!

We are experiencing some problems using some library routines on ia64.
We have an Itanium monoprocessor from Fujitsu Siemens running Red Hat
Linux
Development Release for IA-64.


1)
We experience that
sysconf(_SC_NPROCESSORS_ONLN) returns 0 (zero) on a monoprocessor ia64.


2)
We also experience errors using
 cout << xxx << endl;
when linking with the pthread library.
Using "endl" will give segmentation fault when linking with pthread
library, while the very same statement will be OK when not linking with
pthread library.

//Program-------------------------------
#include <iostream.h>

int
main(void)
{
   cout << "Heisann++" << endl;
}
//--------------------------------------

// Compilation:------------------------------------------
//-------------------------------------------------------
: eisa@scali9-11:ScaThread; g++ -D_REENTRANT -v -g  -o
Linux2.ia64.gnu/test_out test_out.cpp   -lstdc
++ -lm -lgcc -lc -lpthread
Reading specs from
/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/specs
gcc version 2.9-ia64-000216-final
 /usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/cpp -lang-c++
-v -D__GNUC__=3D2 -D__GNUG__=3D2=20
-D__GNUC_MINOR__=3D9 -D__cplusplus -D__ia64 -D__ia64__ -D__linux
-D__linux__ -D_LONGLONG -Dlinux -Dunix
 -D__LP64__ -D__ELF__ -D__ia64 -D__ia64__ -D__linux -D__linux__
-D_LONGLONG -D__linux__ -D__unix__ -D
__LP64__ -D__ELF__ -D__linux -D__unix -Asystem(linux) -Acpu(ia64)
-Amachine(ia64) -D__EXCEPTIONS -g -
D__LONG_MAX__=9223372036854775807L -D_REENTRANT test_out.cpp
/tmp/ccVJHNF8.ii
GNU CPP version 2.9-ia64-000216-final (IA-64)
#include "..." search starts here:
#include <...> search starts here:

/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/../../../../includ=
e/g++-3
 /usr/include

/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/../../../../ia64-r=
edhat-linux/include
 /usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/include
 /usr/include
End of search list.
The following default directories have been omitted from the search
path:
End of omitted list.
 /usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/cc1plus
/tmp/ccVJHNF8.ii -ma-step -quiet -d
umpbase test_out.cc -g -version -o /tmp/cc6wLFW9.s
GNU C++ version 2.9-ia64-000216-final (ia64-redhat-linux) compiled by
GNU C version 2.9-ia64-000216-f
inal.

/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/../../../../ia64-r=
edhat-linux/bin/as
-o /tm
p/ccSUoF6u.o /tmp/cc6wLFW9.s
 /usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/collect2
-dynamic-linker /lib/ld-linux-ia64
.so.1 -o Linux2.ia64.gnu/test_out
/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/../../../c
rt1.o
/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/../../../crti.o
/usr/lib/gcc-lib/ia64-
redhat-linux/2.9-ia64-000216-final/crtbegin.o
-L/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-fi
nal
-L/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/../../../../ia64=
-redhat-linux/lib
-L/u
sr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/../../..
/tmp/ccSUoF6u.o -lstdc++ -lgcc -lpthr
ead -lstdc++ -lm -lc -lgcc -lc -lgcc
/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/crtend.
o
/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/../../../crtn.o
: eisa@scali9-11:ScaThread; Linux2.ia64.gnu/test_out
Segmentation fault (core dumped)
: eisa@scali9-11:ScaThread;=20

//Stack Trace------------------------------------------------------
//-----------------------------------------------------------------
(gdb) run
Starting program:
/home/eisa/work/ScaBase/src/lib/ScaThread/Linux2.ia64.gnu/test_out=20
[New Thread 1024 (runnable)]

Program received signal SIGSEGV, Segmentation fault.
[Switching to Thread 1024 (runnable)]
__pthread_mutex_lock (mutex=3D0xe000000000b3b340) at mutex.c:83
83      mutex.c: No such file or directory.
Current language:  auto; currently c
(gdb) bt =20
#0  __pthread_mutex_lock (mutex=3D0xe000000000b3b340) at mutex.c:83
#1  0x2000000000055610 in __flockfile (stream=3D0x6000000000003f20) at
lockfile.c:32
#2  0x2000000000195c50 in _IO_putc (c=10, fp=3D0x6000000000003f20) at
putc.c:32
#3  0x4000000000007a20 in endl (outs=3D@0x6000000000003cf0) at
streambuf.h:58
#4  0x4000000000017040 in ostream::operator<< (this=3D0x6000000000003cf0,=20
    func=3D0x4000000000023730 <__EH_FRAME_END__+216>) at
../../../libio/iostream.cc:1039
#5  0x4000000000002cd0 in main () at test_out.cpp:38
(gdb)

//----------------------------------------------------------------


We are using:
- Linux scali9-11 2.4.0-0.8smp #1 SMP Sun Jun 18 00:32:35 EDT 2000 ia64
unknown
- gnupro Version: 0501, Release: 2, Build Date: Thu 01 Jun 2000 12:45:11
AM CEST
- glibc Version: 2.1.3, Release: 0.0427.7, Build Date: Mon 12 Jun 2000
03:42:49 AM CEST


Best Regards
Einar Saltnes
SW-Engineer

  e-mail:  eisa@scali.no         Scali AS (http://www.scali.com)
  Tlf   : (+47) 22 62 89 50      Olaf Helsets vei 6
  Fax   : (+47) 22 62 89 51      N-0621 Oslo, Norway


