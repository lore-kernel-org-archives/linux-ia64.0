From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 Sep 2005 06:32:04 +0000
Subject: 2.6.14-rc1 ia64 rebuilds everything every time
Message-Id: <23363.1126593124@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Because of the recursive definition in ia64 asm-offset.c, where the
file has to exist with a dummy line before it can be generated, we end
up with this recursive dependency.

arch/ia64/kernel/asm-offsets.s -> include/asm/asm-offsets.h (.cmd file)
include/asm/asm-offsets.h -> arch/ia64/kernel/asm-offsets.s (explicit)

Every 2.6.14-rc1 build rebuilds asm-offsets.s, because it asm-offsets.h
is newer.  Which then rebuilds asm-offsets.h, which in turn rebuilds
everything else.

Best solution: remove (and forbid) recursive definitions in asm-offset.c.

Kludge 1: edit arch/$(ARCH)/kernel/.asm-offsets.s.cmd to remove
include/asm/asm-offsets.h.

Kludge 2: Build arch/$(ARCH)/kernel/asm-offsets.s as a temporary file
then check if it has changed or not, only updating the real
arch/$(ARCH)/kernel/asm-offsets.s if there is any change.

