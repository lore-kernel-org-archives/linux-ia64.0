From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 24 Jul 2000 19:55:22 +0000
Subject: Re: [Linux-ia64] Internal Error compiling ddd
Message-Id: <marc-linux-ia64-105590678205227@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205226@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205226@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	BoxPoint.h:1352: Internal compiler error in `fix_lexical_addr', at
	function.c:5409

Probably a known bug with the C++ front end in the February (000216)
toolchain.  I'd suggest trying different optimization options -O1 or -O0.

The February toolchain is based on an FSF snapshot from Jan 3, and there were
unfortuntely some instabilities in the C++ front end at that time due to
C++ front end development.  These bugs have all been fixed long ago.  But
since they were fixed by additional C++ front end development, the patches
aren't really suitable for a released toolchain.

I think the best fix for this is to make a new release, and hope that the new
release has a more stable C++ front end.  Unfortunately, this is likely to
continue to be a problem until the FSF makes a release, since there continues
to be a lot of development work going into the C++ front end and other parts
of gcc.

Red Hat is working on a new toolchain release for the ia64-linux project.  We
made a CVS branch for the release last Monday, based on the July 10 FSF gcc
snapshot, and we are now testing the compiler and fixing bugs.  I could make
a pre-release at any time, but I think we need to fix a couple of more bugs
before that will be really useful.

Jim


