From: Keith Owens <kaos@melbourne.sgi.com>
Date: Tue, 20 Mar 2001 02:10:16 +0000
Subject: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005303@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

panic() is defined as __attribute__ ((noreturn)).  Either gcc is
generating invalid unwind data for this attribute or the kernel unwind
code is mishandling the data.  To reproduce, set a kdb breakpoint on
panic() and call panic.  The stack is valid but kdb gets invalid data
from the unwind routines and prints gibberish.  Removing noreturn gives
a correct backtrace, at the expense of some extra "control reachs end
of non-void function" messages.


