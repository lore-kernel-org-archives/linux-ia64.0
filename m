From: Yann Droneaud <ydroneaud@opteya.com>
Date: Mon, 13 Oct 2014 19:30:58 +0000
Subject: [PATCHv9 1/5] ia64: trivial: replace get_unused_fd() by get_unused_fd_flags(0)
Message-Id: <b8329cd85f075d0886bd837a012b3d922f3174ed.1413223900.git.ydroneaud@opteya.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1413223900.git.ydroneaud@opteya.com>
In-Reply-To: <cover.1413223900.git.ydroneaud@opteya.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <trivial@kernel.org>
Cc: linux-ia64@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

This patch replaces calls to get_unused_fd() with equivalent call to
get_unused_fd_flags(0) to preserve current behavor for existing code.

In a further patch, get_unused_fd() will be removed so that new code
start using get_unused_fd_flags(), with the hope O_CLOEXEC could be
used, either by default or choosen by userspace.

Link: http://lkml.kernel.org/r/cover.1413223900.git.ydroneaud@opteya.com
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: trivial@kernel.org
Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>
---
 arch/ia64/kernel/perfmon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 5845ffea67c3..dc063fe6646a 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2662,7 +2662,7 @@ pfm_context_create(pfm_context_t *ctx, void *arg, int count, struct pt_regs *reg
 
 	ret = -ENOMEM;
 
-	fd = get_unused_fd();
+	fd = get_unused_fd_flags(0);
 	if (fd < 0)
 		return fd;
 
-- 
1.9.3

