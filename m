From: Tony Luck <tony.luck@intel.com>
Date: Mon, 28 Jun 2010 18:53:31 +0000
Subject: Re: [RFC PATCH --take 2] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT
Message-Id: <AANLkTiklDwfzQ9gr_K5htMPG0fagi25ky9zCashZmBgZ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
In-Reply-To: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch is incomplete. I'm seeing errors

include/linux/irqflags.h:59:26: error: asm/irqflags.h: No such file or directory

because the patch didn't create arch/ia64/include/asm/irqflags.h


Could you provide a bit more detail on what the issues are that
require touching each of the generic files (or at least something
on whether these changes are temporary workarounds that should
go away later, or real stuff that needs changes)

 fs/ioctl.c                     |    1
 fs/open.c                      |    1
 fs/read_write.c                |    1
 include/linux/irqflags.h       |    2
 include/linux/lockdep.h        |    2
 kernel/fork.c                  |    4 +
 kernel/lockdep.c               |    8 +++
 kernel/sys.c                   |    1
 kernel/timer.c                 |    1
 kernel/trace/trace_irqsoff.c   |    6 ++

-Tony
