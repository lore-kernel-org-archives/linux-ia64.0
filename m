From: Grant Grundler <iod00d@hp.com>
Date: Thu, 31 Jul 2003 04:00:56 +0000
Subject: Re: EXT2_MAX_BLOCK_LOG_SIZE increase?
Message-Id: <marc-linux-ia64-105962406619445@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105958015806246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105958015806246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 30, 2003 at 08:35:41PM -0700, Grant Grundler wrote:
> It looks like ext2 uses PAGE_SIZE to size it's IOs:

sorry..hit send key a bit too fast...here's the bit of code I wanted
to quote:
fs/ext2/ialloc.c:       inode->i_blksize = PAGE_SIZE;   /* This is the optimal IO size (for stat), not the fs block size */

Does this really mean ext2 tries to do IO in page size chunks?
I'll assume it does (usually) unless told otherwise since 4k vs 16k
block size on 16k page size gave basically the same result.

grant
