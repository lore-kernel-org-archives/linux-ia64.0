From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 20 Nov 2007 03:12:46 +0000
Subject: [PATCH] set_thread_area fails in IA32 chroot
Message-Id: <20071120031246.GB29070@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I tried to upgrade an IA32 chroot on my IA64 to a new glibc with TLS.
It kept dying because set_thread_area was returning -ESRCH
(bugs.debian.org/451939).

I instrumented arch/ia64/ia32/sys_ia32.c:get_free_idx() and ended up
seeing output like

[pid] idx   desc->a  desc->b
-----------------------------
[2710] 0 -> c6b0ffff 40dff31b
[2710] 1 -> 0 0
[2710] 2 -> 0 0

[2710] 0 -> c6b0ffff 40dff31b
[2710] 1 -> c6b0ffff 40dff31b
[2710] 2 -> 0 0

[2711] 0 -> c6b0ffff 40dff31b
[2711] 1 -> c6b0ffff 40dff31b
[2711] 2 -> 48c0ffff 40dff317

which suggested to me that TLS pointers were surviving exec() calls,
leading to GDT pointers filling up and the eventual failure of
get_free_idx().

I think the solution is flushing the tls array on exec as below.

Cheers,

-i

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>
---

 process.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 2418289..2281a01 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -737,6 +737,7 @@ flush_thread (void)
 		ia32_drop_ia64_partial_page_list(current);
 		current->thread.task_size = IA32_PAGE_OFFSET;
 		set_fs(USER_DS);
+		memset(current->thread.tls_array, 0, sizeof(current->thread.tls_array));
 	}
 #endif
 }

