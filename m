From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 17 Apr 2009 22:25:51 +0000
Subject: ia64 allmodconfig bustage in 2.6.30-rc2
Message-Id: <20090417152551.381bc522.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


`make allmodconfig'
`make vmlinux'

  CC      arch/ia64/kernel/asm-offsets.s
In file included from include/linux/bitops.h:17,
                 from include/linux/kernel.h:15,
                 from include/linux/sched.h:52,
                 from arch/ia64/kernel/asm-offsets.c:9:
/usr/src/devel/arch/ia64/include/asm/bitops.h: In function `set_bit':
/usr/src/devel/arch/ia64/include/asm/bitops.h:47: error: implicit declaration of function `BUILD_BUG_ON'

I fiddled around a bit but failed to fix it then I got bored.

