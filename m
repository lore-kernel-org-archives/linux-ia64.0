From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 26 Oct 2000 05:08:49 +0000
Subject: [Linux-ia64] Working gcc for IA64 with unwind support
Message-Id: <marc-linux-ia64-105590678205631@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Does anybody have a working toolchain for IA64 that supports the latest
unwind descriptors?  Preferably one that actually cross compiles from
ix86.

The CVS gcc has broken cross compile ix86->IA64, incorrect optimization
(bug C/645), spurious warning messages, no crt1 etc.  After working
around the gcc problems, the resulting kernel will not boot, it breaks
during efi time initialization.


