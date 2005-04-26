From: Jason Baron <jbaron@redhat.com>
Date: Tue, 26 Apr 2005 17:10:06 +0000
Subject: RE: gate page oops
Message-Id: <Pine.LNX.4.61.0504261304020.28688@dhcp83-105.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 22 Apr 2005, Luck, Tony wrote:

> >While working on the RHEL 4 kernel (based on 2.6.9), i encountered a BUG() 
> >in mm/memory.c:get_user_pages() at the line: BUG_ON(pte_none(*pte));
> >
> >Seems like in_gate_area() returns true, but there is no pte to map the 
> >page. That is, the in_gate_area() covers a larger range than what is 
> >actually mapped. 
> >
> >I'm not sure if this is a problem in 2.6.11, as i didn't get a 
> >chance to build and test a kernel based on 2.6.11. 
> 
> It looks like there is some muddle of usage of PAGE_SIZE
> and PERCPU_PAGESIZE here (in the kernel code, not just in
> you patch).  Perhaps left over from when the percpu area
> was located at the start of region 5??
> 
> The gate page only needs to be PAGE_SIZE ... doesn't it?
> 

I'm not really sure...i was hoping somebody on the list would know :) If 
you look at setup_gate(), it establishes two gate pages, the comment says:

* Map the gate page twice: once read-only to export the ELF headers etc. and once
* execute-only page to enable privilege-promotion via "epc":

So the patch i proposed was intended to allow user access to these two 
regions. Currently, that isn't being done properly, leading to an oops.

-Jason
