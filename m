From: Jes Sorensen <jes@linuxcare.com>
Date: Wed, 09 Aug 2000 15:09:15 +0000
Subject: Re: [Linux-ia64] Where are sources?
Message-Id: <marc-linux-ia64-105590678205290@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jim" = Jim Wilson <wilson@cygnus.com> writes:

Jim> We are working on a new toolchain release to replace this one.
Jim> This release will be made in conjunction with the glibc-2.2
Jim> release, because of numerous incompatible ABI changes.
Jim> Meanwhile, you might try an SRPM from one of the other linux
Jim> releases.

Jim> You will have to rebuild everything from scratch when the new
Jim> toolchain/glibc releases come out though.

I am currently working on preparing glibc-2.2 for a release, it is my
intention to provide a tarball of library+compiler that people can use
to start compiling their own applications. threads don't work at the
moment, but most other things seem to be ok (I haven't worked on debug
and profiling libs yet).

Before release I want to test the changes to siginfo and sigevent that
were made yesterday but for some reason I have been unable to compile
a booting kernel for about a month (using different compilers).

Jes

