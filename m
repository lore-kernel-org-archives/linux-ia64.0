From: Christoph Lameter <christoph@lameter.com>
Date: Fri, 04 Jun 2004 14:29:08 +0000
Subject: Re: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized
Message-Id: <Pine.LNX.4.58.0406040727420.15208@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 3 Jun 2004, Ulrich Drepper wrote:

> David Mosberger wrote:
>
> > Does anyone else find it annoying that gettimeofday() only provides
> > micro-second resolution?  We can do syscalls significantly faster than
> > that (especially with a light-weight syscall handler).  Time for a
> > kernel extension?
>
> What do you think clock_gettime(CLOCK_REALTIME) is for?

clock_gettime(CLOCK_REALTIME) calls gettimeofday internally and then
multiplies with 1000. I have a patch that supports CLOCK_REALTIME_HR and
CLOCK_MONOTONIC_HR to access the full resolution of the clocks.


