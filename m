From: Christoph Hellwig <hch@lst.de>
Date: Thu, 19 Oct 2017 15:02:49 +0000
Subject: Re: refactor dma_cache_sync V2
Message-Id: <20171019150249.GA24079@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
	<87817c6a-b03f-6da0-4e69-22ea68d44bd5@arm.com>
	<20171016124442.GB2177@lst.de>
In-Reply-To: <20171016124442.GB2177-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>

On Mon, Oct 16, 2017 at 02:44:42PM +0200, Christoph Hellwig wrote:
> On Tue, Oct 03, 2017 at 12:49:51PM +0100, Robin Murphy wrote:
> > Reviewed-by: Robin Murphy <robin.murphy@arm.com>
> 
> Thanks Robin.  I've heard very little from the arch maintainers,
> but if people remain silent I will apply the whole series to the
> dma-mapping tree in the next days.

Applied to the dma-mapping tree for 4.15.
