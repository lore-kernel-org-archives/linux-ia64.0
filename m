From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 11 Mar 2004 06:17:03 +0000
Subject: Re: BUG in fs/buffer.c under heavy ext3 file-system load
Message-Id: <20040311061703.GA12682@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078959918.12405.64.camel@bluto.andrew>
In-Reply-To: <1078959918.12405.64.camel@bluto.andrew>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 10, 2004 at 04:05:18PM -0700, Andrew Patterson wrote:
> I also tried running the same test on the ext2 file-system.  I did not
> run into this bug, but instead got data corruption problems.  I get the
> same data corruption problems on an ia32 system, so it is not a
> ia64-only issue.

If you don't think it's ia64 specific, you should probably post this
message to linux-kernel@vger.kernel.org as well (I didn't see it in the
Cc list).  It might be a generic block layer problem or an ext2/3
problem...

Jesse
