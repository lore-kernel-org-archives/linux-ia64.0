From: "H. Peter Anvin (Intel)" <hpa@zytor.com>
Date: Thu, 04 Oct 2018 22:29:48 +0000
Subject: [PATCH 0/5] termios: remove arch redundancy in <asm/termbits.h>
Message-Id: <20181004222953.2229-1-hpa@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-serial@vger.kernel.org
Cc: "H. Peter Anvin (Intel)" <hpa@zytor.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Arnd Bergmann <arnd@arndb.de>, Chris Zankel <chris@zankel.net>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Helge Deller <deller@gmx.de>, James Hogan <jhogan@kernel.org>, Jiri Slaby <jslaby@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, Max Filippov <jcmvbkbc@gmail.com>, Paul Burton <paul.burton@mips.com>, Philippe Ombredanne <pombredanne@nexb.com>, Ralf Baechle <ralf@linux-mips.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-xtensa@linux-xtensa.org

<asm/termbits.h> is one of those files which define an ABI. Some were
made different due to the desire to be compatible with legacy
architectures, others were mostly direct copies of the i386
definitions, which are now in asm-generic.

This folds the IA64, MIPS, PA-RISC, and Xtensa implementations into
the generic one.  IA64 and Xtensa are identical, MIPS and PA-RISC are
trivially different and just need a handful of constants redefined.

<asm-generic/termbits.h> has a few very minor adjustments to allow this.

 arch/ia64/include/uapi/asm/termbits.h   | 210 +-----------------------------
 arch/mips/include/uapi/asm/ioctls.h     |   2 +
 arch/mips/include/uapi/asm/termbits.h   | 213 ++----------------------------
 arch/parisc/include/uapi/asm/termbits.h | 197 +---------------------------
 arch/xtensa/include/uapi/asm/termbits.h | 222 +-------------------------------
 include/uapi/asm-generic/termbits.h     |   7 +-
 6 files changed, 27 insertions(+), 824 deletions(-)

Signed-off-by: H. Peter Anvin (Intel) <hpa@zytor.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Chris Zankel <chris@zankel.net>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Helge Deller <deller@gmx.de>
Cc: James Hogan <jhogan@kernel.org>
Cc: Jiri Slaby <jslaby@suse.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Paul Burton <paul.burton@mips.com>
Cc: Philippe Ombredanne <pombredanne@nexb.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: <linux-ia64@vger.kernel.org>
Cc: <linux-mips@linux-mips.org>
Cc: <linux-parisc@vger.kernel.org>
Cc: <linux-xtensa@linux-xtensa.org>
