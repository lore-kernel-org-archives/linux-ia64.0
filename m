From: k Macy <kip_macy@yahoo.com>
Date: Mon, 03 Sep 2001 19:44:16 +0000
Subject: [Linux-ia64] can't compile on x86 - building cross-compiler for ia64 getting SIGSEGV
Message-Id: <marc-linux-ia64-105590698805115@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is it actually possible to cross-develop from x86?

This must have been answered before, but I did not
see any way to search the posts to this list.
> ./configure --prefix=/usr/local/ia64
--host=ia64-hp-linux; gmake 

gives me:
cc1: Internal error: Segmentation fault
on both gcc-3.0 and gcc-3.0.1

The snapshot distributed from HP with nue fails
building both 2.4.5 and 2.4.9 with:
/home/kmacy/linux/include/asm/hw_irq.h:122: 
Internal compiler error in `pushdecl', at
c-decl.c:2310
Please submit a full bug report.
See <URL:http://www.gnu.org/software/gcc/bugs.html>
for instructions.
gcc: Internal compiler error: program cpp got fatal
signal 13


__________________________________________________
Do You Yahoo!?
Get email alerts & NEW webcam video instant messaging with Yahoo! Messenger
http://im.yahoo.com

