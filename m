From: John Kohl <jtk@rational.com>
Date: Tue, 02 Jan 2001 15:30:36 +0000
Subject: [Linux-ia64] [re-send] more missing symbols (test12 patch)?
Message-Id: <marc-linux-ia64-105590678205877@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm resending this again, as the list seems to be dead or comatose at
least (if anybody at linuxia64.org is reading this, please fix the list
and its archives).

Date: Mon, 18 Dec 2000 15:20:48 -0500 (EST)
From: John Kohl <jtk@rational.com>
To: linux-ia64@linuxia64.org
Subject: more missing symbols (test12 patch)?

These look like more missing symbol exports from the test12-based patch
kit.  I'm presuming they should be exported without versions, similarly
to what i386 does with its locking-related exports?

#include <asm/semaphore.h>
EXPORT_SYMBOL_NOVERS(__down);
EXPORT_SYMBOL_NOVERS(__down_interruptible);
EXPORT_SYMBOL_NOVERS(__down_trylock);
EXPORT_SYMBOL_NOVERS(__up);
EXPORT_SYMBOL_NOVERS(__down_read_failed);
EXPORT_SYMBOL_NOVERS(__down_write_failed);
EXPORT_SYMBOL_NOVERS(__rwsem_wake);

p.s. we got test12 kernels running on our Big Sur system, after
upgrading to BIOS 60.  (It took a while to determine that our processors
are A2 stepping, and we're arranging to get upgrades soon.)
Thanks for all the suggestions!

-- 
=John Kohl <jtk@rational.com>, Software Engineer
Rational Software, Configuration Management Business Unit
Mark your calendars!  Rational User Conference 2001, July 22-26, 2001
in beautiful Denver, Colorado

