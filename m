From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 18 Feb 2004 17:06:01 +0000
Subject: Re: [2.6 PATCH] Altix update
Message-Id: <20040218170601.A10490@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402181441.i1IEfIWX024531@fsgi900.americas.sgi.com>
In-Reply-To: <200402181441.i1IEfIWX024531@fsgi900.americas.sgi.com>; from pfg@sgi.com on Wed, Feb 18, 2004 at 08:41:18AM -0600
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: akpm@osdl.org, davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Feb 18, 2004 at 08:41:18AM -0600, Pat Gefre wrote:
> Andrew,
> 
> Here's a small mod for Altix. It breaks up our 'pci fixup' function and
> has some other smallish clean ups.
> 
> For the ia64 crowd I've added 'platform_data' back into
> include/asm-ia64/pci.h
> 
> Can you take this ?

The patch looks okay, but this whole fixup-based pci initialization is
just plain wrong to start with.  I still wonder how this crap managed
to enter the tree..

