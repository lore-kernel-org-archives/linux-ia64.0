From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 02 May 2000 22:32:28 +0000
Subject: Re: [Linux-ia64] ld failure
Message-Id: <marc-linux-ia64-105590678205069@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205047@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205047@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	/usr/bin/ld: dw: __gp does not cover short data segment 

Sorry, I forgot to answer this.

Something is still broken.  I don't know what.  There are a few ways that you
could get here.
1) You have a program with millions of small static scalar variables.  If so,
   try using -mno-sdata, or rewrite your program.
2) You are explicitly allocating variables to the short data segment, either
   by using attribute section, or by using a special linker script, or by
   writing assembly language code that puts data in the short data segement.
   If so, you need to fix your code to stop putting so much data in the short
   data segment.
3) There is a linker bug, that is causing the out-of-range call support to
   fail in a way that makes it look like the short data segment is too big.

#3 seems like the most likely explanation.  We would need a complete testcase
to reproduce this, which means a copy of all object files and libraries that
you are linking together, together with the linker command line.  Fixing this
would be a low priority, so it may be a few weeks before it gets fixed.

Jim


