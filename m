From: Bill Nottingham <notting@redhat.com>
Date: Thu, 25 Jan 2001 16:34:48 +0000
Subject: [Linux-ia64] Re: That getpagesize() problem again!
Message-Id: <marc-linux-ia64-105590693005102@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Francis Galiegue (fg@mandrakesoft.com) said: 
> When trying to install only two packages via RPM in a chroot, this is what I
> get:
> 
> rpm: ../sysdeps/unix/sysv/linux/ia64/getpagesize.c:36: __getpagesize: Assertion
> `_dl_pagesize != 0'
> failed.
> 
> Then, abort and core dump.

The page size stuff was broken in glibc for a few days (right around 2.2.1)
in where it didn't work for static binaries (they'd explode as soon as
they tried to use NSS.)

Once you get a version of glibc that fixes this, you need to rebuild all
static binaries that use NSS (e.g., rpm); then it should work.

Bill

