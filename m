From: Alex Williamson <alex_williamson@hp.com>
Date: Tue, 28 Jan 2003 21:58:28 +0000
Subject: [Linux-ia64] gcc-3.2 bug
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------A1AEABCE747B2CCBB591BB3D"
Message-Id: <marc-linux-ia64-105590709805762@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------A1AEABCE747B2CCBB591BB3D
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   I've been trying to figure out why agpgart_be.c won't compile on
ia64 w/ gcc-3.2, and I've got a pretty simple test case that seems
to show a compiler bug.  Not being much of a tools guy, I figured
I'd toss it out here.  If I compile with -O2, I get an undefined
reference much like I see in the kernel:

# gcc -O2 -o test test.c
/tmp/ccQCPFMM.o(.text+0xa0): In function `main':
: undefined reference to `.L13'
collect2: ld returned 1 exit status

If I compile w/o optimization or w/ gcc-2.96, it works fine.  It
also works fine on x86 w/ gcc-3.2.  Here's my gcc info:

# gcc -v
Reading specs from /usr/lib/gcc-lib/ia64-linux/3.2.2/specs
Configured with: ../src/configure -v --enable-languages=c,c++,java,f77,proto,pascal,objc,ada --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-gxx-include-dir=/usr/include/c++/3.2
--enable-shared --with-system-zlib --enable-nls --without-included-gettext --enable-__cxa_atexit --enable-clocale=gnu --enable-java-gc=boehm --enable-objc-gc ia64-linux
Thread model: posix
gcc version 3.2.2 20030124 (Debian prerelease)

This is the Debian unstable 3.2.2-0pre6.  I'll file a bug there too.
Test case attached.  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------A1AEABCE747B2CCBB591BB3D
Content-Type: text/x-csrc; charset=us-ascii;
 name="test.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="test.c"

#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char **argv)
{
	int arg, value = 0;

	printf("%s %d\n",argv[0], atoi(argv[1]));
	arg = atoi(argv[1]);

	switch (arg) {
		case 0:
			value += arg;
			break;
		case 1:
			value += arg;
			break;
		case 2:
			value += arg;
			break;
		case 3:
			value += arg;
			break;
		case 4:
			value += arg;
			break;
		default:
			value = 0;
			break;
	}
	printf("value = %d\n",value);
	return 0;
}

--------------A1AEABCE747B2CCBB591BB3D--


