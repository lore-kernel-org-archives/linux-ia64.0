From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 16 Feb 2008 06:39:43 +0000
Subject: git-nfsd on ia64
Message-Id: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Cunningly, current git-nfsd causes this, with ia64 allmodconfig:

.config:3397:warning: trying to assign nonexistent symbol NFSD_TCP
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:297:1: warning: "elf_check_arch" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/textsearch.h:9,
                 from include/linux/skbuff.h:26,
                 from include/linux/icmpv6.h:79,
                 from include/linux/ipv6.h:197,
                 from include/net/ipv6.h:18,
                 from include/linux/sunrpc/svcauth.h:18,
                 from include/linux/sunrpc/svc.h:18,
                 from arch/ia64/ia32/sys_ia32.c:37:
include/asm/elf.h:19:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:302:1: warning: "ELF_CLASS" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/textsearch.h:9,
                 from include/linux/skbuff.h:26,
                 from include/linux/icmpv6.h:79,
                 from include/linux/ipv6.h:197,
                 from include/net/ipv6.h:18,
                 from include/linux/sunrpc/svcauth.h:18,
                 from include/linux/sunrpc/svc.h:18,
                 from arch/ia64/ia32/sys_ia32.c:37:
include/asm/elf.h:24:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:304:1: warning: "ELF_ARCH" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/textsearch.h:9,
                 from include/linux/skbuff.h:26,
                 from include/linux/icmpv6.h:79,
                 from include/linux/ipv6.h:197,
                 from include/net/ipv6.h:18,
                 from include/linux/sunrpc/svcauth.h:18,
                 from include/linux/sunrpc/svc.h:18,
                 from arch/ia64/ia32/sys_ia32.c:37:
include/asm/elf.h:26:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:318:1: warning: "ELF_EXEC_PAGESIZE" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/textsearch.h:9,
                 from include/linux/skbuff.h:26,
                 from include/linux/icmpv6.h:79,
                 from include/linux/ipv6.h:197,
                 from include/net/ipv6.h:18,
                 from include/linux/sunrpc/svcauth.h:18,
                 from include/linux/sunrpc/svc.h:18,
                 from arch/ia64/ia32/sys_ia32.c:37:
include/asm/elf.h:34:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:327:1: warning: "ELF_ET_DYN_BASE" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/textsearch.h:9,
                 from include/linux/skbuff.h:26,
                 from include/linux/icmpv6.h:79,
                 from include/linux/ipv6.h:197,
                 from include/net/ipv6.h:18,
                 from include/linux/sunrpc/svcauth.h:18,
                 from include/linux/sunrpc/svc.h:18,
                 from arch/ia64/ia32/sys_ia32.c:37:
include/asm/elf.h:43:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:330:1: warning: "ELF_PLAT_INIT" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/textsearch.h:9,
                 from include/linux/skbuff.h:26,
                 from include/linux/icmpv6.h:79,
                 from include/linux/ipv6.h:197,
                 from include/net/ipv6.h:18,
                 from include/linux/sunrpc/svcauth.h:18,
                 from include/linux/sunrpc/svc.h:18,
                 from arch/ia64/ia32/sys_ia32.c:37:
include/asm/elf.h:140:1: warning: this is the location of the previous definition
In file included from arch/ia64/ia32/sys_ia32.c:59:
arch/ia64/ia32/ia32priv.h:342:1: warning: "SET_PERSONALITY" redefined
In file included from include/linux/elf.h:7,
                 from include/linux/module.h:14,
                 from include/linux/textsearch.h:9,
                 from include/linux/skbuff.h:26,
                 from include/linux/icmpv6.h:79,
                 from include/linux/ipv6.h:197,
                 from include/net/ipv6.h:18,
                 from include/linux/sunrpc/svcauth.h:18,
                 from include/linux/sunrpc/svc.h:18,
                 from arch/ia64/ia32/sys_ia32.c:37:
include/asm/elf.h:180:1: warning: this is the location of the previous definition


I bet you didn't expect that.

Our header files suck.
