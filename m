From: Greg Edwards <edwardsg@sgi.com>
Date: Mon, 09 May 2005 16:39:17 +0000
Subject: Re: [PATCH]: IA64: sparse cleanup of shub_mmr.h
Message-Id: <20050509163917.GF18250@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <427F5247.4000309@sgi.com>
In-Reply-To: <427F5247.4000309@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 09, 2005 at 08:06:31AM -0400, Prarit Bhargava wrote:
| This patch is a sparse compile cleanup of shub_mmr.h using both the 
| defconfig and the sn2_defconfig config files.

I'm getting rejects on current Tony's/Linus' git trees.  Want to rediff?

...

| Index: arch/ia64/sn/kernel/sn2/ptc_deadlock.S
| =================================| --- e220183081409fe4c5d1961cf1e56d93a91d7efc/arch/ia64/sn/kernel/sn2/ptc_deadlock.S  (mode:100644 sha1:7947312801eccc797975e338af4e76f12ace0c55)
| +++ deed0faf877ef4aa0feb36fcde2b044a77a73b4c/arch/ia64/sn/kernel/sn2/ptc_deadlock.S  (mode:100644 sha1:96cb71d156820f9b33df9a07ea5049afe3bc77b9)
| @@ -6,6 +6,7 @@
|   * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
|   */
|  
| +#include <asm/types.h>
|  #include <asm/sn/shub_mmr.h>

Shouldn't this be moved to include/asm-ia64/sn/shub_mmr.h, since
that's where we're referencing __IA64_UL_CONST?

Greg
