From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Sep 2003 07:08:53 +0000
Subject: kernel link times
Message-Id: <marc-linux-ia64-106317774818447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A while ago, Matthew brought up the issue of kernel link times.
Turning off debug info certainly accelerates linking, but if you're
like me and really want the debug info to be there, that's not much
help.  Fortunately, there is a very nice patch by Michael Matz which
fixes an O(N^2) algorithm in the linker which was burning huge amounts
of CPU cycles.  With this patch applied a "make vmlinux" (with nothing
changed other than version.c) drops from ~90sec to 27sec on my
(oldish) machine.  The improved linker still spends almost 30% of its
time in a single routine, so there may be other optimization
opportunities, but this is already a big step forward.  Patch can be
found here:

 http://sources.redhat.com/ml/binutils/2003-09/msg00122.html

Enjoy,

	--david
