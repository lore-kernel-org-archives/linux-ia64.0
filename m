From: "Theodore Ts'o" <tytso@mit.edu>
Date: Wed, 30 Jul 2003 18:21:02 +0000
Subject: Re: EXT2_MAX_BLOCK_LOG_SIZE increase?
Message-Id: <marc-linux-ia64-105958930019343@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105958015806246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105958015806246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 30, 2003 at 09:38:40AM -0600, Grant Grundler wrote:
> Ted,
> Can you bump up the EXT2_MAX_BLOCK_LOG_SIZE value?
> 
> willy tells me you are the maintainer of ext2 tools.
> In lib/ext2fs/ext2_fs.h (debian e2fsprogs package):
> 
> - #define EXT2_MAX_BLOCK_LOG_SIZE         13      /* 8192 */
> + #define EXT2_MAX_BLOCK_LOG_SIZE         16      /* 64K */
> 
> ia64 supports 4/8/16/64k page sizes.
> I'll post re-aim-7 benchmark runs using ext2 w/16k block on lkml.
> 

I'd be interested in benchmark runs comparing 4k, 8k, 16k, 32k, and
64k, if you would, please.  

Was any patches necessary for the ia64 kernel before the block sizes >
8k started working for you?


						- Ted

