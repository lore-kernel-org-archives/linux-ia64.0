From: Piet/Pete Delaney <piet@sgi.com>
Date: Tue, 16 Apr 2002 22:36:47 +0000
Subject: [piet@sgi.com: [Linux-ia64] unw_init_frame_info() and activation records]
Message-Id: <marc-linux-ia64-105590701905464@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Keith:

Our linux lcrash code support for stack frames needs improvement, I'm
looking around for code to pinch and was wondering about the kdb code.

The kdb code at least seems to support the NEW_UNWIND code by using 
unw_init_frame_info().  You code mentions that it should be using activation 
records and I was wondering what that's all about.

I've been reading David Mosberger chapter on Stack Unwinding and I'll check the
kernel code for perspectives on the code. I suspect that the gdb unwind code
and the HP-IPF-unwind library (available on request) are likely an overkill and only
needed for C++.

Perhaps you could take a few minutes and provide a few pointers on how
to save time in adding unwind support. 

-piet

