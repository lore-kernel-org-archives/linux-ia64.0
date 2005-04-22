From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 22 Apr 2005 20:52:39 +0000
Subject: RE: gate page oops
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03541A84@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>While working on the RHEL 4 kernel (based on 2.6.9), i encountered a BUG() 
>in mm/memory.c:get_user_pages() at the line: BUG_ON(pte_none(*pte));
>
>Seems like in_gate_area() returns true, but there is no pte to map the 
>page. That is, the in_gate_area() covers a larger range than what is 
>actually mapped. 
>
>I'm not sure if this is a problem in 2.6.11, as i didn't get a 
>chance to build and test a kernel based on 2.6.11. 

It looks like there is some muddle of usage of PAGE_SIZE
and PERCPU_PAGESIZE here (in the kernel code, not just in
you patch).  Perhaps left over from when the percpu area
was located at the start of region 5??

The gate page only needs to be PAGE_SIZE ... doesn't it?

-Tony
