From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 27 Mar 2003 23:33:51 +0000
Subject: Re: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590723705343@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

My box is still running strong, so no kernel issues that I know of
(aside from the kernel eating all my CPU time whenever someone mounts
an exported nfs volume)

[jbarnes@spamtin jbarnes]$ uname -a;uptime
Linux spamtin 2.5.64 #7 SMP Fri Mar 14 14:10:36 PST 2003 ia64 unknown
 15:33:01  up 13 days, 51 min,  7 users,  load average: 0.70, 0.30, 0.14

Thanks,
Jesse


On Thu, Mar 27, 2003 at 05:31:15PM -0600, Mario Smarduch wrote:
> So it appears like drivers are having issues and that's
> to be expected if they're not reentrant. But what about
> the kernel proper, has anyone observed issues there or
> knows of any outstanding issues?
> 
>     - Mario.
> 
> 
> Peter Chubb wrote:
> 
> > >>>>> "Jesse" = Jesse Barnes <jbarnes@sgi.com> writes:
> >
> > Jesse> Just FYI, I tried 2.5.64 out on my Bug Sur, and it seems to work ok
> > Jesse> with the following exceptions:
> > Jesse> o the AT keyboard support seems broken (characters are slow to show
> > Jesse> up on the screen and are sometimes repeated)
> > Jesse> o agp support for 460GX causes a link failure
> >
> > AT keyboard and PS/2 mouse both!
> >
> > Jesse> But by using a USB keyboard and turning off agp support, I was able to
> > Jesse> get an SMP+preempt kernel going, and it seems fine.
> >
> > On a dual McKinley prototype machine I was able to get lockups with
> > preempt under heavy I/O and cpu load (e.g., make -j4 in glibc).  I'm
> > waiting for production model McKinleys SMP to retry, as I couldn't
> > reproduce the problem on production-model Itanium 1, and there were no
> > symptoms that I could debug.
> >
> > Also FYI, if you're using posix threads in userland, the port of the
> > next generation library is almost complete, and, with the kernel
> > preemption patch, will give much lower latencies for heavily threaded
> > code, depending on exactly what you're doing.
> >
> > --
> > Dr Peter Chubb                              peterc@gelato.unsw.edu.au
> > You are lost in a maze of BitKeeper repositories, all almost the same.
> >
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64

