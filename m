From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 03 Feb 2004 19:01:51 +0000
Subject: Re: [PATCH] Add EXPORT_SYMBOL for physical_node_map
Message-Id: <20040203190151.A8692@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040203185728.GX13322@localhost>
In-Reply-To: <20040203185728.GX13322@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 03, 2004 at 01:57:28PM -0500, Martin Hicks wrote:
> Can you please include this EXPORT_SYMBOL in the next release.  A few
> macros that use physical_node_map are used in modules.

which module?  There isn't one in the current tree and it would have to
be horribly SN2-specific as it's a SN2 only variable.

And no, my $RANDOM binary module doesn't count.
