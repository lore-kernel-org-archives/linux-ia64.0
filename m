From: Jim Wilson <wilson@cygnus.com>
Date: Sat, 10 Nov 2001 01:01:00 +0000
Subject: Re: [Linux-ia64] gcc 3.0 questions.
Message-Id: <marc-linux-ia64-105590698805462@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805456@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805456@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> error while loading shared libraries: /home/jholly/lib/libgcc_s.so.1:
>  undefined symbol: __ia64_app_header

This can happen when you try to link together code from incompatible gcc
versions.  One of the libraries somewhere that you are linking against was
compiled by the wrong compiler.

ia64_app_header was a variable that was present from about Oct 2000 to
June 2001 in the gcc start files (crtbegin.o).  It never appeared in any
Trillian compiler release.  It did appear in gcc 3.0.  It was removed before
gcc-3.0.1.  Note in particular that gcc 3.0 is not compatible with 3.0.1,
and 3.0.1 is not compatible with 3.0.2 for a different reason.

>I'm doing this using NUE and the tarball put together by Stephane Eranian
>and running it on my RH 7.1 box.

My guess is that Stephane's tarball was built using 3.0, and that you are
building your application with either 3.0.1 or 3.0.2.  That won't work.
Either everything has to be compiled by 3.0, or everything has to be
compiled by 3.0.1, or everything has to be compiled by 3.0.2.  By the
way, 3.0 won't build glibc, so that one isn't an option.

You can try replacing the file /home/jholly/lib/libgcc_s.so.1 with the
equivalent file from a gcc 3.0.[12] build.  That might be enough to solve
your problem.  It would be better to have a complete build with everything
compiled by the same gcc version.

Jim

