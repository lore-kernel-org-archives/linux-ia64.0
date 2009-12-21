From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 21 Dec 2009 00:36:25 +0000
Subject: Re: [PATCH] ia64: Include <linux/personality.h> header in
Message-Id: <20091221003625.GA28326@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1261239943.2418.95.camel@localhost>
In-Reply-To: <1261239943.2418.95.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Dec 19, 2009 at 04:25:43PM +0000, Ben Hutchings wrote:
> The definition of force_o_largefile() references personality, but this
> header does not include <linux/personality.h>.  This happens to work
> for sys_open(), but may not for any other users.  In particular, aufs2
> now uses this macro and so fails to build on ia64.

So include the header there directly.  Or rather don't use it at all,
filesystems have no business at all messing with this.

