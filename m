From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 08 Aug 2000 19:10:21 +0000
Subject: Re: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205282@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	I get 40 MB kernels, although the size of text/data/bss/etc. are about the
	same as the 7-8 MB kernels shipped with the RedHat distro on my machine.

Strip out the debug info if you don't want it.  That accounts for most of
the extra size.  There are people working on fixing the dwarf2 debug info
size problem, but I don't know when the result will be available or how well
it will work.

	And, trying to get the newer compiler to work on the RedHat distro has
	been a little problematic.

Which "new" compiler are you trying to use?  000216-final is the latest
compiler release that we have made.  If you try to use something from the
FSF (e.g. gcc.gnu.org), you are likely to run into lots of problem.
We will be making a new compiler release soon, in conjunction with the
glibc 2.2 release that Jes Sorensen is working on.  You might want to wait
for that.

Jim

