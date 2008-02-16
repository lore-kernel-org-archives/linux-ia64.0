From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 16 Feb 2008 06:43:19 +0000
Subject: Re: git-nfsd on ia64
Message-Id: <20080215224319.870e4921.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
In-Reply-To: <20080215223943.d12b8eb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 15 Feb 2008 22:39:43 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> Cunningly, current git-nfsd causes this, with ia64 allmodconfig:
> 
> .config:3397:warning: trying to assign nonexistent symbol NFSD_TCP
> In file included from arch/ia64/ia32/sys_ia32.c:59:
> arch/ia64/ia32/ia32priv.h:297:1: warning: "elf_check_arch" redefined
> In file included from include/linux/elf.h:7,
>                  from include/linux/module.h:14,
>                  from include/linux/textsearch.h:9,
>                  from include/linux/skbuff.h:26,
>                  from include/linux/icmpv6.h:79,
>                  from include/linux/ipv6.h:197,
>                  from include/net/ipv6.h:18,
>                  from include/linux/sunrpc/svcauth.h:18,
>                  from include/linux/sunrpc/svc.h:18,
>                  from arch/ia64/ia32/sys_ia32.c:37:
> include/asm/elf.h:19:1: warning: this is the location of the previous definition

Easy fix:

--- a/include/linux/sunrpc/svcauth.h~git-nfsd-fix
+++ a/include/linux/sunrpc/svcauth.h
@@ -15,7 +15,6 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/hash.h>
-#include <net/ipv6.h>
 
 #define SVC_CRED_NGROUPS	32
 struct svc_cred {
@@ -25,6 +24,7 @@ struct svc_cred {
 };
 
 struct svc_rqst;		/* forward decl */
+struct in6_addr;
 
 /* Authentication is done in the context of a domain.
  *
_


This should have been done in the first place, IMO.  Avoid header file
dependencies, faster compile, avoid crap like the above.

