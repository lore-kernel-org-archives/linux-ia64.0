From: Mario Smarduch <cms063@email.mot.com>
Date: Tue, 04 May 2004 16:30:21 +0000
Subject: mmap() of /dev/kmem issue
Message-Id: <4097C51D.71EA0BEA@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have problem of viewing memory contents via mmap()
of /dev/kmem. After mmap()'ing /dev/kmem for reading
it appears that data accessed in the kernel lives in
different cache lines from data accessed in the user space.
The lseek()/read() from kernel reflects latest updates,
but same reads from user space mmap fetches old data, and
vice versa when updating from user. When I flush the
caches (cat of a big file to another file), then user mapped
value reflects the latest changes but then again remains
frozen. I'm having trouble understanding how can this
happen since the caches are physically indexed.
Any ideas what the problem could be?

- Mario.

