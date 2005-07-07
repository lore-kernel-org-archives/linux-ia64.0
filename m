From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Thu, 07 Jul 2005 23:57:38 +0000
Subject: RE: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <516F50407E01324991DD6D07B0531AD54FA4FE@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Wed, 29 Jun 2005, Magenheimer, Dan (HP Labs Fort Collins) wrote:
> > Also unlike Xen/x86, Linux/ia64 with CONFIG_XEN enabled runs 
> > successfully on Xen, but also run natively on hardware (called 
> > "transparent paravirtualization").
> 
> That's neat indeed.

Thanks!
 
> > This should be appealing to Linux/ia64 distributors as different
> > kernels need not be shipped for running on Xen or running native.
> 
> What's the performance impact for using transparanent 
> paravirtualization? 
> Is it sufficiently low that distributors really can consider using a 
> single kernel for both native and Xen "hosting"?

I believe so.  No benchmarks yet but I'm guessing it will
be barely measurable.  If someone who has experience measuring
very small differences in benchmarks wants to give it a try,
I would be happy to help!

Dan

