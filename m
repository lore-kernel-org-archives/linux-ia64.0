From: Grant Grundler <grundler@parisc-linux.org>
Date: Wed, 30 Jul 2003 15:38:40 +0000
Subject: EXT2_MAX_BLOCK_LOG_SIZE increase?
Message-Id: <marc-linux-ia64-105958015806246@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ted,
Can you bump up the EXT2_MAX_BLOCK_LOG_SIZE value?

willy tells me you are the maintainer of ext2 tools.
In lib/ext2fs/ext2_fs.h (debian e2fsprogs package):

- #define EXT2_MAX_BLOCK_LOG_SIZE         13      /* 8192 */
+ #define EXT2_MAX_BLOCK_LOG_SIZE         16      /* 64K */

ia64 supports 4/8/16/64k page sizes.
I'll post re-aim-7 benchmark runs using ext2 w/16k block on lkml.

thanks,
grant

Grant Grundler
iod00d@hp.com
grundler@parisc-linux.org
