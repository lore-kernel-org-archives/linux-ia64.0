From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 03 Jun 2004 21:21:09 +0000
Subject: Re: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized
Message-Id: <Pine.LNX.4.58.0406031415280.696@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 3 Jun 2004, Andreas Schwab wrote:

> That needs to be libmemusage-sysdep_routines.

>
> > +		int fd = open ("/proc/sal/itc_drift", O_RDONLY);
>
> This is Linux-specific, isn't it?  Thus it belongs under
> sysdeps/.../linux/ia64.

Quite a bit of the code is linux specific. Do I leave the generic code
broken?

I could put some hooks in that have to be satisfied by the
operating system specific versions.

That would require the following functins:

int itc_drifting(void)	-> OS dependent way of determining if ITC is drifting.

int __get_freq(void)	-> Determine ITC frequency that has to be simulated.

Are these to be put into a separate file? itc_drift.c that satisfied those
dependencies in an OS specific way?

