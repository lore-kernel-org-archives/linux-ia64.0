From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 13 Nov 2000 21:19:22 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205698@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am not a kernel expert.  I do not build my own kernels.  I can not tell you
which compiler versions are best for compiling which kernel versions.

However, in general, I recommend the most recent toolchain snapshot available
at  ftp://ftp.cygnus.com/pub/ia64-linux.  These toolchains assume glibc 2.2.
Unfortunately, sigh, there aren't any glibc 2.2 based OS releases yet, but
this shouldn't matter if you are just building kernels.

Jim

