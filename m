From: Francis Galiegue <fg@mandrakesoft.com>
Date: Thu, 25 Jan 2001 10:26:37 +0000
Subject: [Linux-ia64] That getpagesize() problem again!
Message-Id: <marc-linux-ia64-105590693005096@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When trying to install only two packages via RPM in a chroot, this is what I
get:

rpm: ../sysdeps/unix/sysv/linux/ia64/getpagesize.c:36: __getpagesize: Assertion
`_dl_pagesize != 0'
failed.

Then, abort and core dump.

What I'd like to know is why, in the glibc file mentioned in the error,
__getpagesize is defined as such:

int
__getpagesize ()
{
  assert (_dl_pagesize != 0);
  return _dl_pagesize;
}

(that's glibc 2.2.1, but 2.2 exhibits the same behaviour)

This looks all the more strange that you can define the page size during kernel
compile! A sample test program which I made using the getpagesize() syscall
yields the correct value, though...

What should I do?

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


