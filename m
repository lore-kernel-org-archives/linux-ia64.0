From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 14 Mar 2003 21:57:55 +0000
Subject: Re: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590709806118@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jesse" = Jesse Barnes <jbarnes@sgi.com> writes:

Jesse> Just FYI, I tried 2.5.64 out on my Bug Sur, and it seems to work ok
Jesse> with the following exceptions:
Jesse> o the AT keyboard support seems broken (characters are slow to show
Jesse> up on the screen and are sometimes repeated)
Jesse> o agp support for 460GX causes a link failure

AT keyboard and PS/2 mouse both!

Jesse> But by using a USB keyboard and turning off agp support, I was able to
Jesse> get an SMP+preempt kernel going, and it seems fine.


On a dual McKinley prototype machine I was able to get lockups with
preempt under heavy I/O and cpu load (e.g., make -j4 in glibc).  I'm
waiting for production model McKinleys SMP to retry, as I couldn't
reproduce the problem on production-model Itanium 1, and there were no
symptoms that I could debug.

Also FYI, if you're using posix threads in userland, the port of the
next generation library is almost complete, and, with the kernel
preemption patch, will give much lower latencies for heavily threaded
code, depending on exactly what you're doing.

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

