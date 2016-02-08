From: James Hogan <james.hogan@imgtec.com>
Date: Mon, 08 Feb 2016 18:43:48 +0000
Subject: [PATCH 0/3] MIPS: Fix exported asm/siginfo.h breakage
Message-Id: <1454957031-20138-1-git-send-email-james.hogan@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-kernel@vger.kernel.org, Christopher Ferris <cferris@google.com>, James Hogan <james.hogan@imgtec.com>, Arnd Bergmann <arnd@arndb.de>, Petr Malat <oss@malat.biz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-mips@linux-mips.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, stable@vger.kernel.org

These patches fix some issues with the asm/siginfo.h that MIPS exports
in its headers. Primarily the include of another uapi/ header since
v4.0 (patches 2 & 3), and also the continued use of non-strict posix
types since they were removed from the generic siginfo.h (patch 1).

James Hogan (3):
  MIPS: Fix siginfo.h to use strict posix types
  signal: Move generic copy_siginfo() to signal.h
  MIPS: Fix uapi include in exported asm/siginfo.h

 arch/mips/include/uapi/asm/siginfo.h | 22 ++++++++++------------
 include/asm-generic/siginfo.h        | 15 ---------------
 include/linux/signal.h               | 15 +++++++++++++++
 3 files changed, 25 insertions(+), 27 deletions(-)

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Petr Malat <oss@malat.biz>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-mips@linux-mips.org
Cc: linux-arch@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: <stable@vger.kernel.org>
-- 
2.4.10

