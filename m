From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 24 Sep 2003 18:56:13 +0000
Subject: Re: PATCH: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106442983803876@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106438485815490@msgid-missing>
In-Reply-To: <marc-linux-ia64-106438485815490@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 24, 2003 at 10:36:21AM +0200, Andreas Schwab wrote:
> "H. J. Lu" <hjl@lucon.org> writes:
> 
> > On Mon, Sep 22, 2003 at 04:21:23PM -0700, Richard Henderson wrote:
> >> On Mon, Sep 22, 2003 at 12:39:18PM -0700, H. J. Lu wrote:
> >> > Can I get char * from char [300]?
> >> 
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
> 

I don't think it will be the problem. Compiler will do

	addl outN = constant, r0

to pass a constant to the function, regardless what the type is. Am I
correct?


H.J.

