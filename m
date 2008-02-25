From: Shaohua Li <shaohua.li@intel.com>
Date: Mon, 25 Feb 2008 08:38:36 +0000
Subject: [patch 1/3] writeback regset[0] in coredump
Message-Id: <1203928716.3841.19.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These are the patches to support regset in ia64. The patches are on top
of Petr's ptrace cleanup patches.
http://marc.info/?l=linux-ia64&m0276611704615&w=2


Writeback regset[0] before access it to make user memory RSE is up to
date. With Petr's patch, we are using access_process_vm to access user
RSE.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 fs/binfmt_elf.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux/fs/binfmt_elf.c
=================================--- linux.orig/fs/binfmt_elf.c	2008-02-25 15:19:18.000000000 +0800
+++ linux/fs/binfmt_elf.c	2008-02-25 15:20:23.000000000 +0800
@@ -1431,6 +1431,14 @@ static int fill_thread_core_info(struct 
 	unsigned int i;
 
 	/*
+	 * If regset 0 has a writeback call, do it now. On register window
+	 * machines, this makes sure the user memory backing the register data
+	 * is up to date
+	 */
+	if (view->regsets[0].writeback)
+		view->regsets[0].writeback(t->task, &view->regsets[0], 1);
+
+	/*
 	 * NT_PRSTATUS is the one special case, because the regset data
 	 * goes into the pr_reg field inside the note contents, rather
 	 * than being the whole note contents.  We fill the reset in here.


