From: Jakub Jelinek <jakub@redhat.com>
Date: Wed, 24 Sep 2003 07:43:19 +0000
Subject: Re: PATCH: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106439675127150@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106438485815490@msgid-missing>
In-Reply-To: <marc-linux-ia64-106438485815490@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 24, 2003 at 10:36:21AM +0200, Andreas Schwab wrote:
> >> x+0 would work in this case; I'd guess it'd work for most of the
> >> cases that syscalls need to handle.
> >> 
> >
> > This patch works for me.
> >
> >
> > H.J.
> > ---
> > 2003-09-22  H.J. Lu  <hongjiu.lu@intel.com>
> >
> > 	* sysdeps/unix/sysv/linux/ia64/sysdep.h (LOAD_ARGS_1): Use
> > 	__typeof ((outX) + 0) instead of long.
> 
> Hopefully we don't have any occurences of LOAD_ARGS_n(...,0,..) where the
> kernel expects long.

I think that's very risky and could mean hard to find bugs.
I don't think the 0-1 cycle speedup is not worth the troubles.

	Jakub
