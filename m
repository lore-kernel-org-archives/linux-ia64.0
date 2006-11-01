From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Nov 2006 19:46:27 +0000
Subject: Re: cross-compiling ia64 kernels?
Message-Id: <Pine.LNX.4.64.0611011145020.14406@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 1 Nov 2006, Christoph Lameter wrote:

> Ok. It builds now.  One has to edit gcc-3.4.2-glibc-2.3.3.dat to have

And it failed again:

mv -f 
/home/christoph/explore/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-3.4.2-glibc-2.3.3/build-glibc-headers/sysd-syscallsT 
/home/christoph/explore/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-3.4.2-glibc-2.3.3/build-glibc-headers/sysd-syscalls
make[1]: Failed to remake makefile 
`/home/christoph/explore/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-3.4.2-glibc-2.3.3/build-glibc-headers/config.make'.
make[1]: Leaving directory 
`/home/christoph/explore/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-3.4.2-glibc-2.3.3/glibc-2.3.3'
make[1]: Entering directory 
`/home/christoph/explore/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-3.4.2-glibc-2.3.3/glibc-2.3.3'
autoconf  sysdeps/ia64/elf/configure.in > sysdeps/ia64/elf/configure.new
autoconf: Undefined macros:
***BUG in Autoconf--please report*** AC_FD_MSG
make[1]: Failed to remake makefile 
`/home/christoph/explore/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-3.4.2-glibc-2.3.3/build-glibc-headers/config.make'.
make[1]: `sysdeps/gnu/errlist.c' is up to date.
make[1]: Leaving directory 
`/home/christoph/explore/crosstool-0.42/build/ia64-unknown-linux-gnu/gcc-3.4.2-glibc-2.3.3/glibc-2.3.3'
make: *** [sysdeps/gnu/errlist.c] Error 2

Building a cross compiler seems to be a waste of time. It just plainly 
never works right without spending a week or so fixing broken stuff all 
over the place.


