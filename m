From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 27 Sep 2005 14:25:17 +0000
Subject: Re: [Lhms-devel] Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <1127831117.10315.91.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1127779977.10315.6.camel@localhost>
In-Reply-To: <1127779977.10315.6.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-09-27 at 07:45 -0500, Jack Steiner wrote:
> I haven't looked in detail at SPARSEMEM recently - is one config
> file for ALL hardware platforms easy to do without significantly 
> compromising performance of any individual platform?

On the ppc64 and i386 machines where I've done testing, it hasn't been
an issue.  Usually, the NUMA-Q is a nice canary and will fall over dead
if we're doing any large amount of crazy, new, cross-node accesses.
Compared to discontigmem, it actually gets a wee bit (~1-2%) faster on
thinks like kernbench and SDET.

But, we don't have a vmem_map on i386, so it's not an apples to apples
comparison.  I'd love to see some head-to-head performance numbers,
though.

-- Dave

