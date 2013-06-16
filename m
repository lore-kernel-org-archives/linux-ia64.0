From: ddaney.cavm@gmail.com
Date: Sun, 16 Jun 2013 20:06:27 +0000
Subject: [PATCH 0/2] Fix v3.10-rc6 failures in ia64 and mn10300
Message-Id: <1371413189-2568-1-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com
Cc: david.s.daney@gmail.com, David Daney <david.daney@cavium.com>

From: David Daney <david.daney@cavium.com>

My patch f21afc25f (smp.h: Use local_irq_{save,restore}() in !SMP
version of on_each_cpu().) seems to have broken ia64 and mn10300.

We can fix the breakage by resolving the unmet include dependencies.

David Daney (2):
  ia64: Fix include dependency in asm/irqflags.h
  mn10300: Fix include dependency in irqflags.h

 arch/ia64/include/asm/irqflags.h    | 1 +
 arch/mn10300/include/asm/irqflags.h | 3 ++-
 arch/mn10300/include/asm/smp.h      | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

-- 
1.7.11.7

