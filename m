From: Rich Altmaier <richa@engr.sgi.com>
Date: Thu, 18 Jan 2001 20:43:06 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_PAGE_SIZE
Message-Id: <marc-linux-ia64-105590693005085@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005077@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005077@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I very much like larger page sizes for their performance boosts,
typically the VM efficiency helps both code+data allocation and
helps IO operation setup/teardown.

However be aware of one significant downside to larger page sizes,
for workloads involving a large number of small processes.
Suppose you fire up 1000 processes on a system, then the
additional physical memory consumption is significant.
I actually don't know the correct calculation but guesstimate
that per-process data structures which increase in size
include kernel stack, task struct, each shared lib data segment,
user data segment.  If the pagesize is increased from 4K to 64K,
then 4 such elements yield  60K*4*1000 processes = 240Mbyte.

Some customers do complain about this (and I tell them to buy
more memory and enjoy the performance).
Thanks, Rich


>
>
> On Thu, Jan 18, 2001 at 09:55:32AM -0800, Broadfoot, KenX wrote:
> >
> > Anyone in the know,
> >
> > I am using a 16KB page size for my Lion systems.
> >
> > Under the help section of make menuconfig is says:
> >
> > 4KB   best for ia32
> >
> > 8KB   best for ia64
> >
> > 16KB  best for ia64
> >
> > 64KB  Not for Itanium
> >
> >
> > I just want to know what is the gain or loss if I used 8KB instead of 16KB
> > page size.
> >
> > Also why is the 64KB page size bad for Itanium?
> >
> > Thanks.
> >
> > --ken
> >


