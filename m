From: Manfred Spraul <manfred@colorfullife.com>
Date: Sun, 09 Jul 2000 08:51:44 +0000
Subject: [Linux-ia64] do_mmap_fake question
Message-Id: <marc-linux-ia64-105590678205192@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

do_mmap_fake seems to be buggy:

You use simple memset/memcpy to initialize user memory.
AFAICS this can oops on SMP: one thread calls do_mmap_fake, and a second
thread calls sys_munmap() for that memory range.
memset/memcpy will fail, and you don't have an exception handler
installed.

Btw, why do you use llseek?
Is there a hidden problem with read(,,,&off)?

- llseek(,,off);
- r = file->f_op->read(file,(char*)addr, len, &file->f_pos);
+ r = file->f_op->read(file,(char*)addr, len, &off);

--
	Manfred


