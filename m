From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 11 Jun 2004 20:13:11 +0000
Subject: Re: wait4 causes segfault in i386 chroot
Message-Id: <40CA1257.2010606@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040610051605.GA21936@cse.unsw.EDU.AU>
In-Reply-To: <20040610051605.GA21936@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/10/2004 7:02 PM, Ian Wienand wrote:

> A guess : the only major difference with the optimised libraries is
> they enable __thread which has the effect of putting errno in the TLS
> area (sysdeps/unix/sysv/linux/i386).  TLS uses the %gs register to get
> at the thread local data.  Now for some reason the gs register gets
> trashed somewhere along the way, say in a signal handler, it's
> possible that you'd get a segfault?  Anyone got any other ideas (cc:
> debian-glibc@lists.debian.org in case they do).
> 

Sounds like a variant of this problem:

http://lia64.bkbits.net:8080/linux-ia64-2.5/cset@3f9717925gK7Yi_LUHPyFzsyLpHMsA?nav=index.html|src/|src/arch|src/arch/ia64|src/arch/ia64/ia32|related/arch/ia64/ia32/ia32_signal.c

Is it possible for you to make a tarball for this particular glibc available ? It doesn't fail for me with 

# rpm -q glibc
glibc-2.3.2-95.3

	-Arun

