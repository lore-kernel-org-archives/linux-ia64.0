From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 22 Feb 2009 01:33:28 +0000
Subject: [PATCH] ia64: beyond ARRAY_SIZE of unw.hash
Message-Id: <49A0AB68.30600@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

static struct {

... :114
        unsigned short hash[UNW_HASH_SIZE];

... :147
} unw = {

... :228
        .hash = { [0 ... UNW_HASH_SIZE - 1] = -1 },
...
};

This is a bug, isn't it?
--------------------------->8-------------8<------------------------------
Do not go beyond ARRAY_SIZE of unw.hash

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index 67810b7..b6c0e63 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -2149,7 +2149,7 @@ unw_remove_unwind_table (void *handle)
 
 	/* next, remove hash table entries for this table */
 
-	for (index = 0; index <= UNW_HASH_SIZE; ++index) {
+	for (index = 0; index < UNW_HASH_SIZE; ++index) {
 		tmp = unw.cache + unw.hash[index];
 		if (unw.hash[index] >= UNW_CACHE_SIZE
 		    || tmp->ip < table->start || tmp->ip >= table->end)
