From: Julia Lawall <Julia.Lawall@inria.fr>
Date: Fri, 18 Mar 2022 10:37:18 +0000
Subject: [PATCH] ia64: ptrace: fix typos in comments
Message-Id: <20220318103729.157574-23-Julia.Lawall@inria.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Various spelling mistakes in comments.
Detected with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@inria.fr>

---
 arch/ia64/kernel/ptrace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 6a1439eaa050..32f544baf7ae 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -2025,7 +2025,7 @@ static void syscall_get_args_cb(struct unw_frame_info *info, void *data)
 	 * - epsinstruction: cfm is set by br.call
 	 *   locals don't exist.
 	 *
-	 * For both cases argguments are reachable in cfm.sof - cfm.sol.
+	 * For both cases arguments are reachable in cfm.sof - cfm.sol.
 	 * CFM: [ ... | sor: 17..14 | sol : 13..7 | sof : 6..0 ]
 	 */
 	cfm = pt->cr_ifs;
