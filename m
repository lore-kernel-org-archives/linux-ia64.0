From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 31 Mar 2008 13:01:06 +0000
Subject: Re: [PATCH 2/2] x86 TS_RESTORE_SIGMASK
Message-Id: <20080331130106.GA15198@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain> <20080329001341.7F93826FA1D@magilla.localdomain> <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org> <20080329022408.0DD4726FA1D@magilla.localdomain> <20080329031413.EA38926FA1D@magilla.localdomain> <20080329031451.D2E1226FA1D@magilla.localdomain>
In-Reply-To: <20080329031451.D2E1226FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org


* Roland McGrath <roland@redhat.com> wrote:

> Replace TIF_RESTORE_SIGMASK with TS_RESTORE_SIGMASK and define our own 
> set_restore_sigmask() function.  This saves the costly SMP-safe 
> set_bit operation, which we do not need for the sigmask flag since 
> TIF_SIGPENDING always has to be set too.
> 
> Signed-off-by: Roland McGrath <roland@redhat.com>
> ---
>  arch/x86/ia32/ia32_signal.c      |    2 +-
>  arch/x86/kernel/signal_32.c      |   19 ++++++++++---------
>  arch/x86/kernel/signal_64.c      |   16 +++++++++-------
>  include/asm-x86/thread_info_32.h |   13 +++++++++++--
>  include/asm-x86/thread_info_64.h |   13 +++++++++++--
>  5 files changed, 42 insertions(+), 21 deletions(-)

the x86 bits look nice - but i guess this all wants to go into 2.6.26 
via -mm (or linux-next), due to its cross-arch nature?

	Ingo
