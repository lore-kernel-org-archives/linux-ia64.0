From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 12 Aug 2004 09:18:09 +0000
Subject: Re: Altix I/O code reorganization - 7 of 21
Message-Id: <20040812101809.E5988@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408112329.i7BNTP6F163641@fsgi900.americas.sgi.com>
In-Reply-To: <200408112329.i7BNTP6F163641@fsgi900.americas.sgi.com>; from pfg@sgi.com on Wed, Aug 11, 2004 at 06:29:25PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hch@infradead.org

On Wed, Aug 11, 2004 at 06:29:25PM -0500, Pat Gefre wrote:
> Yes, the PCI DMA mapping code is very robust

no.

> and tries to export 
> the many hardware features that are available on our system.  However, not 
> all of these features are "reachable" via the standard Linux PCI mapping 
> interfaces.  We have removed all unreacheable features.  However, we can 
> still support future requirements with these new interfaces when needed.
> 
> Yes, we did look at your patch dated: December 4th 2003.  It was very good, but 

I mean a more recent patch I sent to Colin.

