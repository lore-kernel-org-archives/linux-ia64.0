From: Keith Owens <kaos@sgi.com>
Date: Sun, 09 Jan 2005 23:26:13 +0000
Subject: Re: [PATCH] ia64: reset console_loglevel so INIT output always goes to console
Message-Id: <14372.1105313173@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105140871.25267.50.camel@eeyore>
In-Reply-To: <1105140871.25267.50.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 9 Jan 2005 11:06:37 -0600 (CST), 
Russ Anderson <rja@sgi.com> wrote:
>For example, having SAL rendezvous all the CPUs before calling OS_MCA 
>may have been reasonable when linux lacked the ability to recover from 
>an MCA.  But now that is changing, the descision to rendezvous CPUs
>should get made later, in linux, if it cannot recover from the MCA.
>Does it really make sense to rendezvous 512 CPUs just because one
>CPU happened to hit a memory uncorrectable in a user application
>(and recovers by killing the appication and discarding the page)?

I do not see any alternative.  SAL has no idea if the OS can recover
from a memory MCA or not, that decision has to be made by the OS.
Leaving the rendezvous decision to the OS would significantly
complicate the OS/SAL interface, it requires another SAL call by the
OS, changes to every SAL version and code in the OS to work out if the
current prom supports the SAL change or not.  If memory is failing, we
want the other cpus to keep off that physical memory while we work
around the problem and decide if we can recover, so we need to stop the
other cpus anyway.

MCA/INIT events are very rare and, in most cases, the rendezvous is a
standard interrupt which is reasonably fast.  I will take simplicity of
OS coding over speed every time for this case.  The simplest method is
for SAL to rendezvous all the cpus unless SAL knows unequivocally that
the error will be recovered.  If there is any uncertainty about whether
the OS will recover or not, then do the full rendezvous.

>Does it still make sense to have only one call into OS_MCA at
>a time?  Or is it more reasonable to support multiple OS_MCAs
>and let the linux MCA code coordinate processing of the OS_MCA,
>when needed?

I believe that option is already allowed by the SAL specification.
Linux has never supported it because it never had the per cpu
infrastructure.

