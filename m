From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 23 Apr 2004 06:48:38 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <16520.48198.453014.448285@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Main thing here is the addition of mq support (native support passes
glibc test-suite now; I haven't tried testing the ia32-emulation
code).

Thanks!

	--david

 arch/ia64/ia32/ia32_entry.S  |    8 +++
 arch/ia64/ia32/ia32_signal.c |    8 ++-
 arch/ia64/kernel/entry.S     |   12 ++---
 arch/ia64/kernel/fsys.S      |   12 ++---
 arch/ia64/kernel/iosapic.c   |    2 
 arch/ia64/kernel/signal.c    |   41 +++----------------
 arch/ia64/kernel/traps.c     |    2 
 arch/ia64/pci/pci.c          |   91 +++++++++++++++----------------------------
 include/asm-ia64/ia32.h      |    2 
 include/asm-ia64/siginfo.h   |    2 
 include/asm-ia64/unistd.h    |    6 ++
 11 files changed, 75 insertions(+), 111 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/04/22 1.1920)
   ia64: Add message-queue support to copy_siginfo_from_user().

<jakub@redhat.com> (04/04/21 1.1919)
   [PATCH] ia64: add mq support for ia64
   

<mbp@vexed.ozlabs.hp.com> (04/04/16 1.1713.24.12)
   [PATCH] ia64: fpswa_interface needs to be exported
   
   efivars can be built as a module, but it depends on 'fpswa_interface'
   which is not exported by fpswa.c.  Patch below fixes this problem.

<davidm@tiger.hpl.hp.com> (04/04/13 1.1713.24.11)
   ia64: When delivering a signal, force byte-order to little-endian.

<davidm@tiger.hpl.hp.com> (04/04/13 1.1713.24.10)
   ia64: Drop pci_sal_ext_{read,write}() and instead simply switch to
   	extended config-space addresses when needed.  This avoids
   	the fragile SAL version testing.

<davidm@tiger.hpl.hp.com> (04/04/13 1.1713.24.9)
   ia64: Quiet another compiler-warning.

