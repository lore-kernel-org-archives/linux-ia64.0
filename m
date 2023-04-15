From: Stanislav Kinsburskii <skinsburskii@linux.microsoft.com>
Date: Sat, 15 Apr 2023 11:17:48 +0000
Subject: [PATCH 5/7] ia64: asm/io.h: Expect immutable pointer in virt_to_phys prototype
Message-Id: <168155746830.13678.8071954787135972276.stgit@skinsburskii.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <168155718437.13678.714141668943813263.stgit@skinsburskii.localdomain>
In-Reply-To: <168155718437.13678.714141668943813263.stgit@skinsburskii.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: 
Cc: Stanislav Kinsburskii <stanislav.kinsburskii@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Stanislav Kinsburskii <stanislav.kinsburskii@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Stanislav Kinsburskii <stanislav.kinsburskii@gmail.com>

These helper function - virt_to_phys - doesn't need the address pointer to
be mutable.

In the same time expecting it to be mutable leads to the following build
warning for constant pointers:

  warning: passing argument 1 of ‘virt_to_phys’ discards ‘const’ qualifier from pointer target type

Signed-off-by: Stanislav Kinsburskii <stanislav.kinsburskii@gmail.com>
CC: Geert Uytterhoeven <geert@linux-m68k.org>
CC: Helge Deller <deller@gmx.de>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Bjorn Helgaas <bhelgaas@google.com>
CC: Stanislav Kinsburskii <stanislav.kinsburskii@gmail.com>
CC: linux-ia64@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 arch/ia64/include/asm/io.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 83a492c8d298..c56ad21ba1e9 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -74,7 +74,7 @@ extern unsigned int num_io_spaces;
  * Change virtual addresses to physical addresses and vv.
  */
 static inline unsigned long
-virt_to_phys (volatile void *address)
+virt_to_phys (const volatile void *address)
 {
 	return (unsigned long) address - PAGE_OFFSET;
 }

