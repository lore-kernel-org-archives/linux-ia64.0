From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 25 Nov 2003 16:23:40 +0000
Subject: klibc: type of symbol changed warning
Message-Id: <marc-linux-ia64-106977774928579@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello,

I've been trying to get klibc working on ia64.  I'm running into a
problem while compiling it.  I get a warning during the final link:

gcc --static --nostdlib -nostartfiles -o udev klibc/klibc/crt0.o udev.o
udev-add.o udev-remove.o udevdb.o logging.o namedev.o
libsysfs/sysfs_bus.o libsysfs/sysfs_class.o libsysfs/sysfs_device.o
libsysfs/sysfs_dir.o libsysfs/sysfs_driver.o libsysfs/sysfs_utils.o
libsysfs/dlist.o tdb/tdb.o tdb/spinlock.o  klibc/klibc/libc.a
/usr/lib/gcc-lib/ia64-linux/3.3.2/libgcc.a

/usr/bin/ld: Warning: type of symbol `errno' changed from 1 to 6 in
/usr/lib/gcc-lib/ia64-linux/3.3.2/../../../libc.a(errno.o)

Whatever causing this is also messing up other stuff.  The __ctypes
array, which is used by many of the ctype.h functions is not in the
right place in the final udev executable.

The fix that I've found is to do the final link with ld instead of gcc.

Anyone know what's causing this problem?
thanks
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296


