From: Alan Au <alanau@cse.unsw.EDU.AU>
Date: Wed, 16 Aug 2000 07:54:13 +0000
Subject: [Linux-ia64] building glibc
Message-Id: <marc-linux-ia64-105590678205334@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm having trouble building glibc. I'm using the current turbolinux SRPM, 
glibc-2.1.3-hjl000629p1.src.rpm.

My build environment is HP's NUE.
After applying all the patches, doing configure and then make, I get:

....

make  -C misc subdir_lib
make[2]: Entering directory `/home/alanau/src/glibc/glibc-2.1-hjl/misc'
make[2]: *** No rule to make target
`/home/alanau/glibc-build/misc/mincore.o', needed by
`/home/alanau/glibc-build/misc/stamp.o'.  Stop.
make[2]: Leaving directory `/home/alanau/src/glibc/glibc-2.1-hjl/misc'
make[1]: *** [misc/subdir_lib] Error 2
make[1]: Leaving directory `/home/alanau/src/glibc/glibc-2.1-hjl'
make: *** [all] Error 2


Does anyone know what the problem is? Has anyone successfully built these
sources from within NUE?

Thanks.

Alan
__________
alanau@cse.unsw.edu.au
School of Computer Science and Engineering
University of New South Wales



