From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Sep 2006 23:27:19 +0000
Subject: sysctl calls from userland
Message-Id: <617E1C2C70743745A92448908E030B2A96AA90@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looking through the dmesg(1) output from the kernel I built this morning
from Linus' git tree, I saw a few:

 warning: process `date' used the removed sysctl system call

Other programs listed as using sysctl are: kmodule, ls, kudzu, sleep
newaliases, sendmail and dbus-daemon.

Looking at "sleep", I found that the sysctl() call was made before
getting to main().  The issue is all the code dragged in by "-lrt".
A simple test case:

$ cat nop.c
main() {}
$ gcc -o nop nop.c -lrt
$ strace -o nop.out ./nop
$ grep sysctl nop.out
_sysctl(0x60000ffffe97f3c0)           = 0
$

Is my userland too old (vintage RHEL4u1)?

-Tony
