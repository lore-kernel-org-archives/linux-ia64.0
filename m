From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 24 Jan 2017 00:28:58 +0000
Subject: Re: [PATCH v2 00/10] Finalize separation of extable.h from module.h
Message-Id: <878tq1joqt.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109204010.5047-1-paul.gortmaker@windriver.com>
In-Reply-To: <20170109204010.5047-1-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, David Howells <dhowells@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Linus Torvalds <torvalds@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Richard Henderson <rth@twiddle.net>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Tony Luck <tony.luck@intel.com>

BTW, you missed Jeyu, the current module maintainer.

Not that we care, I think, it's pretty trivial:

Acked-by: Rusty Russell <rusty@rustcorp.com.au> (module.h parts)

Cheers,
Rusty.

Paul Gortmaker <paul.gortmaker@windriver.com> writes:
> Some of the arch specific changes have already been picked up by the
> arch maintainers in v1, so I'm assuming the other folks just figured I'd
> ask Linus to pull the remainder.  Which is the current plan ; soak this
> in linux-next on 4.10-rc3 and request a pull in the next merge window.
>
> So please shout if you are an arch maintainer and see something here you
> have questions or comments on.  Otherwise, you don't have to do anything.
>
> Once all the old users who expected extable content via module.h are
> gone, then and only then can we remove the back compat line as done in
> the final patch in this series.
>
> I've been build testing this locally on a regular basis in with my other
> pending work, on a bunch of different architectures, so hopefully we
> don't see anything go pear shaped when it goes into sfr's linux-next.
>
> The only real change in the v1 ---> v2 aside from dropping merged
> content was the restructuring in the ia64 based on comments from Al
> Viro to improve some header separation at the same time.  I'd resent
> just those two for follow up comments and nobody seemed to have further 
> suggestions.  Note that I'm not able to run test ia64; just compile.
>
> There was also a minor context refresh required due to the recent
> treewide asm/uaccess --> linux/uaccess change, which gave me the
> motivation to get this out of my queue and finalized.
>
> RFC/V1: https://lkml.kernel.org/r/CA+55aFyDw_jK609LcjpWvVMTzCWuH6nLUXiZDeYC2tpSaZqhXA@mail.gmail.com
> ia64: https://lkml.kernel.org/r/20160920022924.9537-1-paul.gortmaker@windriver.com
>
> ---
>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Chris Zankel <chris@zankel.net>
> Cc: David Howells <dhowells@redhat.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: linux-alpha@vger.kernel.org
> Cc: linux-am33-list@redhat.com
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: linux-xtensa@linux-xtensa.org
> Cc: Matt Turner <mattst88@gmail.com>
> Cc: Max Filippov <jcmvbkbc@gmail.com>
> Cc: Richard Henderson <rth@twiddle.net>
> Cc: Rich Felker <dalias@libc.org>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
>
> Paul Gortmaker (10):
>   ia64: move ia64_done_with_exception out of asm/uaccess.h
>   ia64: ensure exception table search users include extable.h
>   m32r: migrate exception table users off module.h and onto extable.h
>   arm: migrate exception table users off module.h and onto extable.h
>   alpha: migrate exception table users off module.h and onto extable.h
>   mn10300: migrate exception table users off module.h and onto extable.h
>   xtensa: migrate exception table users off module.h and onto extable.h
>   sh: migrate exception table users off module.h and onto extable.h
>   core: migrate exception table users off module.h and onto extable.h
>   module.h: remove extable.h include now users have migrated
>
>  arch/alpha/kernel/traps.c         |  2 +-
>  arch/alpha/mm/fault.c             |  2 +-
>  arch/arm/mm/extable.c             |  2 +-
>  arch/arm/mm/fault.c               |  2 +-
>  arch/ia64/include/asm/exception.h | 35 +++++++++++++++++++++++++++++++++++
>  arch/ia64/include/asm/uaccess.h   | 15 ---------------
>  arch/ia64/kernel/kprobes.c        |  4 ++--
>  arch/ia64/kernel/traps.c          |  6 ++++--
>  arch/ia64/kernel/unaligned.c      |  4 +++-
>  arch/ia64/mm/fault.c              |  2 ++
>  arch/m32r/mm/extable.c            |  2 +-
>  arch/m32r/mm/fault.c              |  2 +-
>  arch/mn10300/mm/extable.c         |  2 +-
>  arch/mn10300/mm/misalignment.c    |  2 +-
>  arch/sh/include/asm/uaccess.h     |  1 -
>  arch/sh/kernel/kprobes.c          |  2 +-
>  arch/sh/kernel/traps.c            |  3 ++-
>  arch/sh/mm/extable_32.c           |  2 +-
>  arch/sh/mm/extable_64.c           |  2 +-
>  arch/xtensa/mm/fault.c            |  2 +-
>  include/linux/module.h            |  1 -
>  init/main.c                       |  1 +
>  kernel/extable.c                  |  1 +
>  kernel/module.c                   |  1 +
>  24 files changed, 63 insertions(+), 35 deletions(-)
>  create mode 100644 arch/ia64/include/asm/exception.h
>
> -- 
> 2.11.0
