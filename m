From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 30 Mar 2004 15:18:05 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <1080659885.3646.2106.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <4063F581.ACC5C511@nospam.org>
	 <1080321646.31638.105.camel@nighthawk>  <40695C68.4A5F551E@nospam.org>
In-Reply-To: <40695C68.4A5F551E@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net
Cc: linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 2004-03-30 at 03:39, Zoltan Menyhart wrote:
> Dave Hansen wrote:
> > 
> > Have you considered any common ground your patch might share with the
> > people doing memory hotplug?
> 
> Comparing my stuff to their work, I just do some small performance enhancements:
> 
> - I do not modify a single line on the existing VM paths - if my stuff has no
>   improvement for you, then yo will not be obliged to pay any overhead
...
> - I handle only the simplest case: private anonymous pages (...a singe PTE...)

By not modifying a single line in the existing VM path, your patch
simply duplicates functionality from that existing code, which I'm not
sure is any better.  

I think there's a lot of commonality with what the swap code, NUMA page
migration, and memory removal have to do.  However, none of them share
any code today.  I think all of the implementations could benefit from
making them a bit more generic.  

-- Dave

