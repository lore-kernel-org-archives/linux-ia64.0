From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 21 Aug 2008 20:14:38 +0000
Subject: RE: linux-next: ia64 allmodconfig
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309E70CD1@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080820233526.14c44ea6.akpm@linux-foundation.org>
In-Reply-To: <20080820233526.14c44ea6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I just did a git-checkout of
> git://git.kernel.org/pub/scm/linux/kernel/git/sfr/linux-next.git
> linux-next/master and got commit:
> e85df409b2ad8528fa772379393c81406c417bbf

Hmmm that looks like the commit for next-20080821, but I see build
failures for 0820 and 0821.

Using "git diff next-20080819 next-20080820" shows the only
change in arch/ia64 is an innocuous looking one to arch/ia64/kvm/irq.h
The only plausible looking stuff is the slab.h and slub_def.h changes
because the first error is reported in efi_initialize_iomem_resources()
which does make a kzalloc() call ... and commenting out the kzalloc()
moves the first reported error out of this function to some other one.

I see the same error with the generic_defconfig ... so it
isn't special to allmodconfig.

I'm using gcc version:
 gcc version 3.4.6 20060404 (Red Hat 3.4.6-8)

So this might be a 3.x vs. 4.x issue.

Heck if I can see where these "__ia64_save_stack_nonlocal" symbols
are coming from though.  I thought that there is some cpp
trickery concatenating tokens ... but a "cc -E" of efi.c didn't
give me any clues :-(

-Tony
