From: Matthew Wilcox <willy@debian.org>
Date: Sat, 23 Aug 2003 13:49:54 +0000
Subject: Why sim/boot in -test4?
Message-Id: <marc-linux-ia64-106164660606242@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


$ cvs diff -rLINUS_260_TEST3 -rLINUS_260_TEST4 arch/ia64/Makefile 
[...]
-boot := arch/ia64/boot
+boot := arch/ia64/hp/sim/boot

Why was this change made?  It's not causing me any problems, just a
bit of confusion when I noticed my previous vmlinux.gz wasn't getting
updated any more.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
