From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 18 Jan 2002 18:14:08 +0000
Subject: [Linux-ia64] race conditions in ia32 subsystem
Message-Id: <marc-linux-ia64-105590698805879@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A while we discussed the race conditions that are present in the ia32
subsystem when the page size is greater than 4KB.  It occurred to me
that these problems can be fixed easily and cleanly by using the
get_user_pages() routine (this routine was introduced in 2.4.17, if
memory serves).

The basic idea would be to use the address space's mmap_sem instead of
the global ia32_mmap_sem and to use get_user_pages() instead of
copy_from_user()/copy_to_user() to access memory.

Does someone want to take a stab at doing this?

	--david

