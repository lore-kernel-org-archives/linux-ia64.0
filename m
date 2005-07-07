From: Gerald Pfeifer <gp@suse.de>
Date: Thu, 07 Jul 2005 22:18:05 +0000
Subject: Re: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <Pine.LNX.4.63.0507080010110.12399@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 29 Jun 2005, Magenheimer, Dan (HP Labs Fort Collins) wrote:
> Also unlike Xen/x86, Linux/ia64 with CONFIG_XEN enabled runs 
> successfully on Xen, but also run natively on hardware (called 
> "transparent paravirtualization").

That's neat indeed.

> This should be appealing to Linux/ia64 distributors as different
> kernels need not be shipped for running on Xen or running native.

What's the performance impact for using transparanent paravirtualization? 
Is it sufficiently low that distributors really can consider using a 
single kernel for both native and Xen "hosting"?

Gerald
