From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 17 Sep 2003 21:41:16 +0000
Subject: Re: [PATCH] 2.4 force_successful_syscall()
Message-Id: <marc-linux-ia64-106383490016442@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106323341214232@msgid-missing>
In-Reply-To: <marc-linux-ia64-106323341214232@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 17 September 2003 2:00 pm, Marcelo Tosatti wrote:
> 
> On Wed, 10 Sep 2003, Bjorn Helgaas wrote:
> 
> > Here's a 2.4 backport of this change to 2.5:
> > 
> >     http://linux.bkbits.net:8080/linux-2.5/cset@1.1046.238.7?nav=index.html
> > 
> > Alpha, ppc, and sparc64 define force_successful_syscall_return() in 2.5,
> > but since it's not obvious to me how to do it correctly in 2.4, I left
> > them unchanged.
> 
> Whats the reasoning behing this patch?

Basically we don't want a large unsigned return value to be
misinterpreted as a syscall failure because it looks like
a small negative number.

From David's description of the 2.5 patch (the link above has
the explanation):

Many architectures (alpha, ia64, ppc, ppc64, sparc, and sparc64 at least)
use a syscall convention which provides for a return value and a separate
error flag.  On those architectures, it can be beneficial if the kernel
provides a mechanism to signal that a syscall call has completed
successfully, even when the returned value is potentially a (small)
negative number.  The patch below provides a hook for such a mechanism via
a macro called force_successful_syscall_return().  On x86, this would be
simply a no-op (because on x86, user-level has to be hacked to handle such
cases).

