From: "Theodore Ts'o" <tytso@mit.edu>
Date: Wed, 30 Jul 2003 21:15:33 +0000
Subject: Re: EXT2_MAX_BLOCK_LOG_SIZE increase?
Message-Id: <marc-linux-ia64-105959996500529@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105958015806246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105958015806246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 30, 2003 at 11:51:33AM -0700, Grant Grundler wrote:
> On Wed, Jul 30, 2003 at 02:21:02PM -0400, Theodore Ts'o wrote:
> > I'd be interested in benchmark runs comparing 4k, 8k, 16k, 32k, and
> > 64k, if you would, please.  
> 
> vary kernel page size or ext2 block size or both together?

Well, varying both, actually.  I'm curious whether it is a large block
size, or block_size = page_size that really matters.

The reason why I care is because it makes a difference as to what the
default mke2fs hueristics should be.  (By the way, even without
hacking e2fsprogs at all, if you use mke2fs -Tlargefile, it will use a
default blocksize = pagesize, and this currently bypasses the
EXT2_MAX_BLOCK_SIZE check entirely.)  The question is whether or not
this is really optimal behaviour....

It probably is, but it would be good to know for soon.  

> re-aim-7 benchmark or something different?
> (and please don't say "dbench" :^)

Dbench is a silly benchmark....

> 32k is not possible in the kernel. Could use 64k.

> > Was any patches necessary for the ia64 kernel before the block sizes >
> > 8k started working for you?
> 
> nope. :^)
> Just twiddle the CONFIG_IA64_PAGE_SIZE_* parameters if one wants 64KB.
> 16KB is the default.

Good to know, thanks.

						- Ted
