From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Oct 2008 21:58:48 +0000
Subject: RE: [PATCH 32/32] ia64/pv_ops: paravirtualized istruction checker.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA353274D37@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1223963507-28056-1-git-send-email-yamahata@valinux.co.jp>
	<1223963507-28056-33-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1223963507-28056-33-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Isaku Yamahata <yamahata@valinux.co.jp>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: "xen-ia64-devel@lists.xensource.com" <xen-ia64-devel@lists.xensource.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>

> This patch implements a checker to detect instructions which
> should be paravirtualized instead of direct writing raw instruction.
> This patch does rough check so that it doesn't fully cover all cases,
> but it can detects most cases of paravirtualization breakage of hand
> written assembly codes.

There are still some "itc.d" instructions in ivt.S (in the #ifndef
CONFIG_SMP code).  This checker caught them ... but the error messages
from the build were not as elegant as they might be

  AS      arch/ia64/kernel/pvchk-ivt.o
arch/ia64/kernel/ivt.S: Assembler messages:
arch/ia64/kernel/ivt.S:583: Warning: itc.d should not be used directly.
arch/ia64/kernel/ivt.S:583: Error: junk at end of line, first unrecognized character is `r'
arch/ia64/kernel/ivt.S:649: Warning: itc.i should not be used directly.
arch/ia64/kernel/ivt.S:649: Error: junk at end of line, first unrecognized character is `r'
arch/ia64/kernel/ivt.S:701: Warning: itc.d should not be used directly.
arch/ia64/kernel/ivt.S:701: Error: junk at end of line, first unrecognized character is `r'
make[1]: *** [arch/ia64/kernel/pvchk-ivt.o] Error 1
make: *** [arch/ia64/kernel] Error 2


I'll hold off on applying part32/32 until the CONFIG_SMP=n case
is fixed.

-Tony
