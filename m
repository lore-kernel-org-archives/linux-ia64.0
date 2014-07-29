From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 29 Jul 2014 15:16:46 +0000
Subject: [PATCH 4/9] reiserfs: use correct structure type name in sizeof
Message-Id: <1406647011-8543-5-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: reiserfs-devel@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org, toralf.foerster@gmx.de, hmh@hmh.eng.br, linux-kernel@vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Correct typo in the name of the type given to sizeof.  Because it is the
size of a pointer that is wanted, the typo has no impact on compilation or
execution.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
semantic patch used can be found in message 0 of this patch series.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 fs/reiserfs/resize.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/reiserfs/resize.c b/fs/reiserfs/resize.c
index 6052d32..e69051b 100644
--- a/fs/reiserfs/resize.c
+++ b/fs/reiserfs/resize.c
@@ -99,7 +99,7 @@ int reiserfs_resize(struct super_block *s, unsigned long block_count_new)
 		 */
 		copy_size = bmap_nr_new < bmap_nr ? bmap_nr_new : bmap_nr;
 		copy_size -		    copy_size * sizeof(struct reiserfs_list_bitmap_node *);
+		    copy_size * sizeof(struct reiserfs_bitmap_node *);
 		for (i = 0; i < JOURNAL_NUM_BITMAPS; i++) {
 			struct reiserfs_bitmap_node **node_tmp;
 			jb = SB_JOURNAL(s)->j_list_bitmap + i;

