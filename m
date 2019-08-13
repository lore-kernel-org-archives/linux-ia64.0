From: Christoph Hellwig <hch@lst.de>
Date: Tue, 13 Aug 2019 07:25:08 +0000
Subject: [PATCH 22/28] ia64: remove the unused sn_coherency_id symbol
Message-Id: <20190813072514.23299-23-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190813072514.23299-1-hch@lst.de>
In-Reply-To: <20190813072514.23299-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Mike Travis <mike.travis@hpe.com>, Dimitri Sivanich <sivanich@hpe.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org

The sn_coherency_id symbol isn't used anywhere, remove it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/uv/kernel/setup.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/ia64/uv/kernel/setup.c b/arch/ia64/uv/kernel/setup.c
index 6ac4bd314d92..b081f5138f5c 100644
--- a/arch/ia64/uv/kernel/setup.c
+++ b/arch/ia64/uv/kernel/setup.c
@@ -16,9 +16,6 @@
 DEFINE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
 EXPORT_PER_CPU_SYMBOL_GPL(__uv_hub_info);
 
-long sn_coherency_id;
-EXPORT_SYMBOL_GPL(sn_coherency_id);
-
 struct redir_addr {
 	unsigned long redirect;
 	unsigned long alias;
-- 
2.20.1
