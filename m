From: Greg KH <greg@kroah.com>
Date: Thu, 09 Jun 2005 16:59:28 +0000
Subject: Re: [PATCH 00/10] IOCHK interface for I/O error handling/detecting
Message-Id: <20050609165928.GE9597@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com>
In-Reply-To: <42A8386F.2060100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

On Thu, Jun 09, 2005 at 09:39:11PM +0900, Hidetoshi Seto wrote:
> Hi, long time no see :-D
> 
> This is a continuation of previous post quite a while ago:
> "[PATCH/RFC] I/O-check interface for driver's error handling"
> 
> Reflecting every comments, I brushed up my patch for generic part.
> So today I'll post it again, and also post "ia64 part", which
> surely implements ia64-arch specific error checking. I think
> latter will be a sample of basic implement for other arch.

Overall, the idea and implementation looks very nice.  I just had a few
comments on the code style and how you implemented the .h and .c files.
Good job.

thanks,

greg k-h
