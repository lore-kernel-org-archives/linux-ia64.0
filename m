From: Piet/Pete Delaney <piet@sgi.com>
Date: Tue, 30 Apr 2002 18:25:35 +0000
Subject: Re: [Linux-ia64] use of gdb for ia64 kernel debug
Message-Id: <marc-linux-ia64-105590701905543@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905532@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905532@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 30, 2002 at 02:02:10PM +0100, Doug Rabson wrote:
> On Mon, 29 Apr 2002, David Mosberger wrote:
> 
> > >>>>> On Fri, 26 Apr 2002 17:33:37 -0500, Ray Bryant <raybry@engr.sgi.com> said:
> >
> >   Ray> Is is possible to use an IA32 system as a gdb host and run a
> >   Ray> remote debugging session on an IA64 box (e. g. a Big Sur)?
> >
> > You need a gdb stub in the kernel for doing that.  I seem to recall
> > someone wrote such a stub for FreeBSD (or was it NetBSD)?  If so, you
> > could use that as a starting point.
> 
> There is a 'stub of a stub' in the FreeBSD-current kernel but it certainly
> isn't functional on ia64. I don't yet use gdb for kernel debugging on
> FreeBSD.

I notced it don't look compete; I got the impression from "David O'Brien" <obrien@FreeBSD.org>
that it's working; perhaps they just haven't checked it all in yet:

	"I don't know about ia64, but all the hard core sparc64 developers are
	using serial console and perfer it."

Often the trap code can take a lot of time to get right; this is the primary
reason I thought it might be easier to use skdb and leave the ia64 low level
details to kdb. Once working I was hoping we could add an option to kdb to
provide checksums on consile I/O like the stub protocol uses.

-piet

