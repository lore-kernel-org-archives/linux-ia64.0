From: Grant Grundler <iod00d@hp.com>
Date: Thu, 31 Jul 2003 03:35:41 +0000
Subject: Re: EXT2_MAX_BLOCK_LOG_SIZE increase?
Message-Id: <marc-linux-ia64-105962255218555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105958015806246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105958015806246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 30, 2003 at 05:15:33PM -0400, Theodore Ts'o wrote:
> Well, varying both, actually.  I'm curious whether it is a large block
> size, or block_size = page_size that really matters.

sorry - I'm not sure I understand the distinction.
My take is a larger page size (ie 16k is better than 4k).
It looks like ext2 uses PAGE_SIZE to size it's IOs:

> The reason why I care is because it makes a difference as to what the
> default mke2fs hueristics should be.

My gut feeling is native page_size and then warn about compatibility
if that is > 4k.

> (By the way, even without
> hacking e2fsprogs at all, if you use mke2fs -Tlargefile, it will use a
> default blocksize = pagesize, and this currently bypasses the
> EXT2_MAX_BLOCK_SIZE check entirely.)  The question is whether or not
> this is really optimal behaviour....

re-aim-7 seems to think so.
I sent you privately the 4k and 16k pagesize runs that I had posted earlier.

grant
