From: "bertos, deborah" <bertos_deborah@emc.com>
Date: Tue, 16 Jan 2001 23:11:14 +0000
Subject: [Linux-ia64] Errors when compiling kernel (2.4.0test10)
Message-Id: <marc-linux-ia64-105590693005056@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005054@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005054@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi!

I'm hoping someone can help me out.  I've just installed turbolinux's 1123
release for ia64, and I'm having trouble compiling the kernel. =20

I run the following commands:
make mrproper
make menuconfig
make dep
make clean
make

When I run make, I start receiving numerous errors, and the command exits
before completing.  I receive the following error multiple times every time
I run make:

/usr/src/linux/include/asm/unistd.h: 287: warning: 'dummy2' might be used
uninitialized in this function.  (this error shows up with either 287, 288,
or 289 as the lines where the error is occurring, and the error is showing
either dummy2, 3, 4, or 5.)

In addition, I'm receiving several errors on several different files.  The
files and the errors themselves seem to change each time I try to run
through the compilation process, starting from make mrproper.  Some examples
of the errors are:

pm.c: In function 'pm_send':
pm.c:132: warning cast from pointer to integer of different size.

module.c: In function 'sys_init_module':
module.c:365: warning passing arg 1 of 'kdbaddmodsym' discards qualifiers
from pointer target type.

ivt.S:253: warning: Only the first path encountering the conflict is
reported
ivt.S:249: warning: This is the location of the conflicting usage.

Thanks for the help.


EMC=B2  			Deborah Bertos
The Enterprise Storage Company        		Systems Engineer
					HA & Systems Integration=20

EMC Corporation 		=09
228 South Street				*Office: (508) 435-1000 ext.
23168=09
Hopkinton, MA 01748			*E-Mail: bertos_deborah@emc.com



