From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 13 Aug 2004 18:45:34 +0000
Subject: Re: [PATCH] add coherence id for SGI Altix systems
Message-Id: <20040813194534.A14135@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131756.i7DHuWNi036140@shaft.americas.sgi.com>
In-Reply-To: <200408131756.i7DHuWNi036140@shaft.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 13, 2004 at 01:41:13PM -0500, Russ Anderson wrote:
> Christoph Hellwig wrote:
> > 
> > also while you're at it convert the whole file to seq_file and proper
> > coding style.
> 
> Shouldn't coding style changes be a separate patch?  Otherwise
> it's hard to tell the real changes from the code style changes.

"while you're at it" wasn't meant as in the same patch, but as a reminder
that additional patches to clean up that area would be very welcome ;-)
