From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 03 Feb 2004 19:06:30 +0000
Subject: Re: [PATCH] Add EXPORT_SYMBOL for physical_node_map
Message-Id: <20040203190630.A8759@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040203185728.GX13322@localhost>
In-Reply-To: <20040203185728.GX13322@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 03, 2004 at 02:04:53PM -0500, Martin Hicks wrote:
> > which module?  There isn't one in the current tree and it would have to
> > be horribly SN2-specific as it's a SN2 only variable.
> > 
> > And no, my $RANDOM binary module doesn't count.
> 
> Yes, that's what it is.  Some-random-binary-module.
> 
> It does pollute GENERIC a bit, but I didn't think that would matter too
> much.

Well, then you're on your own.  Export it in the SGI tree if your lawyers
feel comfortable with it.

