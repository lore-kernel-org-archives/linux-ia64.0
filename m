From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 21 Feb 2000 21:35:15 +0000
Subject: Re: [Linux-ia64] building the toolchain
Message-Id: <marc-linux-ia64-105590678204951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204943@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204943@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Will the ftp site disappear in the near future?

No.

	I've been trying to build and use these tools. I believe I am missing
	some step along the way. I'm starting with the cross compiler and
	attempting to build a new kernel. Here's what I've done:

It looks like a good start.  Unfortunately, since you did not report any 
actual error, all I can do is guess at what might be the problem.  Bug reports
are much more useful if they actually contain info about the bug.

My guess is that the build failed while trying to compile gcc's libgcc.a
library because stdio.h was missing.

To fix this problem, you want to use the additional configure options
	--with-headers=<path> --with-libs=<path>
where <path> is a directory name containing ia64-linux header files and
libraries respectively.  If you have an ia64-linux machine, you can just
copy the /usr/include and /lib directories to someplace on the machine where
you are building the cross compiler, and then point the options at the
copied directories.

Unfortunately, I just took a look at the OS CD-rom from LinuxWorld, and
discovered that /usr/include and /lib are empty.  This means there is no easy
way to build a working toolchain.  I don't know why these weren't included
in the public release.

The OS CD-rom does contain a copy of the glibc sources in /usr/src.  So you
can still do a build, but you essentially have to build gcc and glibc at
the same time.  I've never done that.  I'm a novice when it comes to glibc
builds, so I can't guarantee that I can figure out how to do this.

Jim


