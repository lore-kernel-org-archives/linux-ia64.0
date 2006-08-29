From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 29 Aug 2006 21:29:45 +0000
Subject: Re: Move perfmon tables from thread_struct to pfm_context
Message-Id: <20060829212945.GP22011@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829110856.A23515@unix-os.sc.intel.com>
In-Reply-To: <20060829110856.A23515@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph,

On Tue, Aug 29, 2006 at 08:55:28PM +0100, Christoph Hellwig wrote:
> On Tue, Aug 29, 2006 at 11:08:56AM -0700, Keshavamurthy Anil S wrote:
> > This patch renders thread_struct->pmcs[] and thread_struct->pmds[]
> > OBSOLETE. The actual table is moved to pfm_context structure which 
> > is the right thing to do. Also this will in future avoid KABI breakages
> > for the distro as well when the table size changes.
> 
> NACK.  There is no such thing as a KABI, and any patch the claims to
> help towards it will automatically be rejected.  You should get a doctor
> to help you stop seeing things like that.

This patch deals with the existing (old) perfmon on IA-64 only. This has
nothing to do with our current discussion on LKML about perfmon and KAPI
(kernel level perfmon API).

Anil is talking about the kernel ABI backward compatibility guarantee
that some distributors provide. We had perfmon related arrays in thread_struct
which is a struct visible to kernel modules and thus considered part of the
kernel ABI.

For Montecito, we had to grow those structures given the increase in the number
of performance counters. Thereby it broke the ABI guarantee. To work around
this problem, we now have those arrays in a perfmon private struct not exposed
to modules or user. Of course, to maintain the compatibility, we kept the two
orginal arrays in thread_struct, we just do not use them anymore. 

This problem is solved in the new perfmon code base under review on LKML.

Now I understand you may have issues about ABI guarantees in general, but I think
this is a different discussion.

-- 
-Stephane
