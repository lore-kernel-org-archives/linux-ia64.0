From: Francis Galiegue <fg@mandrakesoft.com>
Date: Fri, 10 Nov 2000 11:14:12 +0000
Subject: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205680@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Right now I'm using the ia64-final version of gcc, and from test10 on a check
is done on whether __GNUC_MINOR__ is greater than 91. ia64-final returns 9
which is obviously not what the kernel expects...

After commenting this out and fixing by hand quite a lot of places, I got it to
compile and boot though. But more recent snapshots of gcc are available. Are
they worth upgrading?

Also, will the current glibc-2.2 compile as is on ia64 and work?

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


