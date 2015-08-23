From: Chen Gang <xili_gchen_5257@hotmail.com>
Date: Sun, 23 Aug 2015 17:21:52 +0000
Subject: [PATCH] mm: mmap: Check all failures before set values
Message-Id: <COL130-W55CFB40ACE11D2A0083E04B9630@phx.gbl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: kernel mailing list <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

When failure occurs and return, vma->vm_pgoff is already set, which is
not a good idea.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
=A0mm/mmap.c | 13 +++++++------
=A01 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 8e0366e..b5a6f09 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2878,6 +2878,13 @@ int insert_vm_struct(struct mm_struct *mm, struct vm=
_area_struct *vma)
=A0	struct vm_area_struct *prev;
=A0	struct rb_node **rb_link, *rb_parent;
=A0
+	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
+			 =A0 &prev, &rb_link, &rb_parent))
+		return -ENOMEM;
+	if ((vma->vm_flags & VM_ACCOUNT) &&
+	 =A0 =A0 security_vm_enough_memory_mm(mm, vma_pages(vma)))
+		return -ENOMEM;
+
=A0	/*
=A0	 * The vm_pgoff of a purely anonymous vma should be irrelevant
=A0	 * until its first write fault, when page's anon_vma and index
@@ -2894,12 +2901,6 @@ int insert_vm_struct(struct mm_struct *mm, struct vm=
_area_struct *vma)
=A0		BUG_ON(vma->anon_vma);
=A0		vma->vm_pgoff =3D vma->vm_start>> PAGE_SHIFT;
=A0	}
-	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
-			 =A0 &prev, &rb_link, &rb_parent))
-		return -ENOMEM;
-	if ((vma->vm_flags & VM_ACCOUNT) &&
-	 =A0 =A0 security_vm_enough_memory_mm(mm, vma_pages(vma)))
-		return -ENOMEM;
=A0
=A0	vma_link(mm, vma, prev, rb_link, rb_parent);
=A0	return 0;
--=A0
1.9.3

 		 	   		  