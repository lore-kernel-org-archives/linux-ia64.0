From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 31 Jul 2000 22:22:09 +0000
Subject: [Linux-ia64] integer -> pointer question
Message-Id: <marc-linux-ia64-105590678205250@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

When porting packages to IA64, it is very common to come across code where
integers are being assigned to pointers.  This results in warning messages
from the compiler about assigning integers to pointers of a different
size.

This is very helpful in the case where a function prototype has been
omitted, or the programmer has simply made bad assumptions about the sizes
of pointers and integers.

On the other hand, it is not unusual to see void pointers used for storing
integers, and the programmer has no intention of ever de-referencing the
pointer.  Glib and GTK+ make extensive use of this technique.

The problem is that this generates the same warning messages as the first
case, and it makes it more difficult to know if a particular package has
portability problems.

My question is:  Is there a way to assign integers to void pointers
without triggering warnings from the compiler?

Thanks

Mike Madore
Software Engineer
TurboLinux, Inc.



