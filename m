From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 26 Jul 2020 00:40:08 +0000
Subject: [PATCH 0/5] ia64: delete duplicated words
Message-Id: <20200726004013.20534-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Drop repeated words in arch/ia64/ header files.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org

 arch/ia64/include/asm/pal.h          |    2 +-
 arch/ia64/include/asm/perfmon.h      |    2 +-
 arch/ia64/include/asm/spinlock.h     |    2 +-
 arch/ia64/include/asm/uv/uv_hub.h    |    2 +-
 arch/ia64/kernel/perfmon_mckinley.h  |    2 +-
 arch/ia64/kernel/perfmon_montecito.h |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)
