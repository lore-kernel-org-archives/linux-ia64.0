From: Chen Gang <xili_gchen_5257@hotmail.com>
Date: Sun, 23 Aug 2015 17:18:58 +0000
Subject: [PATCH] arch: ia64: kernel: perfmon: Check return value of insert_vm_struct()
Message-Id: <COL130-W46DBE61538E64374C967CB9630@phx.gbl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: kernel mailing list <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

In pfm_smpl_buffer_alloc, insert_vm_struct may also return -ENOMEM, so
need check it too.

And insert_vm_struct needn't consider about pfm_remap_buffer in failure
process ("goto error" is enough):

=A0- pfm_remap_buffer doen't consider about remap_pfn_range.

=A0- It is about the relationship between vma and smpl_buf.

=A0- SO if both vma and smpl_buf are released ("goto error"), all things
=A0 =A0are OK.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
=A0arch/ia64/kernel/perfmon.c | 6 +++++-
=A01 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 60e02f7..ae77946 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2330,7 +2330,11 @@ pfm_smpl_buffer_alloc(struct task_struct *task, stru=
ct file *filp, pfm_context_t
=A0	 * now insert the vma in the vm list for the process, must be
=A0	 * done with mmap lock held
=A0	 */
-	insert_vm_struct(mm, vma);
+	if (insert_vm_struct(mm, vma)) {
+		DPRINT(("Can't insert vm structure.\n"));
+		up_write(&task->mm->mmap_sem);
+		goto error;
+	}
=A0
=A0	vm_stat_account(vma->vm_mm, vma->vm_flags, vma->vm_file,
=A0							vma_pages(vma));
--=A0

 		 	   		  