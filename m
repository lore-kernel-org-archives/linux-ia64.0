From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 27 Aug 2004 15:21:27 +0000
Subject: Re: Latest Altix I/O code reorganization code
Message-Id: <20040827162127.A32090@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <20040806141836.A9854@infradead.org> <411AAABB.8070707@sgi.com> <412F4EC9.7050003@sgi.com> <412F4FCF.6010507@sgi.com>
In-Reply-To: <412F4FCF.6010507@sgi.com>; from pfg@sgi.com on Fri, Aug 27, 2004 at 10:14:23AM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 27, 2004 at 10:14:23AM -0500, Patrick Gefre wrote:
> 
> Patch 1 of 26
> 
> This patch is too large for email see:
> 
> ftp://oss.sgi.com/projects/sn2/sn2-update/001-kill-files


Stoop again.  This absolutely does not look like a change after which the
tree build, right?  After how many of the patches do we get a useable
kernel for SN2?  Please split your changes into LOGICAL steps, e.g.

 - dma mapping rework
 - usage of SAL interfaces
 - hwgrpah removal
 - renaming of files without code changes
 - addition of new hardware support
 - etc..

everything else is simply not reviewable. (and the above is intentionally
an order which I think would make sense)

