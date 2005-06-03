From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 03 Jun 2005 18:11:25 +0000
Subject: RE: Initialization of cr.dcr
Message-Id: <200506031811.j53IBNg30320@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A01CA2.8010209@hob.de>
In-Reply-To: <42A01CA2.8010209@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christian Hildner wrote on Friday, June 03, 2005 2:02 AM
> playing around with speculation I found that on initialization dcr.dm is 
> not set, while the comment says "Initialize default control register to 
> defer all speculative faults". To be conform to the comment (and also to 
> the expected behavior) the value IA64_DCR_DM should be added in 
> arch/ia64/kernel/setup.c.

It should be the other way around: update the comments to reflect what
the code does.  Turning off dcr.dm is a big win for speculative load
where you do want the tlb miss to be serviced up front.

- Ken

