From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 08 Nov 2000 02:46:07 +0000
Subject: [Linux-ia64] fix for hang on rmmod
Message-Id: <marc-linux-ia64-105590678205666@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a patch that should fix the problem with "rmmod" hanging.
I don't use modules much, but I tried Stephane's test case and
rmmod seems to work fine on it.

Thanks to Asit for tracking this down.

	--david

--- arch/ia64/kernel/unwind.c~	Wed Nov  1 22:49:13 2000
+++ arch/ia64/kernel/unwind.c	Tue Nov  7 18:16:43 2000
@@ -2025,32 +2025,26 @@
 			return;
 		}
 		prevt->next = table->next;
+	}
+	spin_unlock_irqrestore(&unw.lock, flags);
 
-		/* next, remove hash table entries for this table */
+	/* next, remove hash table entries for this table */
 
-		for (index = 0; index <= UNW_HASH_SIZE; ++index) {
-			if (unw.hash[index] >= UNW_CACHE_SIZE)
-				continue;
+	for (index = 0; index <= UNW_HASH_SIZE; ++index) {
+		tmp = unw.cache + unw.hash[index];
+		if (unw.hash[index] >= UNW_CACHE_SIZE
+		    || tmp->ip < table->start || tmp->ip >= table->end)
+			continue;
 
-			tmp = unw.cache + unw.hash[index];
-			prev = 0;
-			while (1) {
-				write_lock(&tmp->lock);
-				{
-					if (tmp->ip >= table->start && tmp->ip < table->end) {
-						if (prev)
-							prev->coll_chain = tmp->coll_chain;
-						else
-							unw.hash[index] = -1;
-						tmp->ip = 0;
-					} else
-						prev = tmp;
-				}
-				write_unlock(&tmp->lock);
+		write_lock(&tmp->lock);
+		{
+			if (tmp->ip >= table->start && tmp->ip < table->end) {
+				unw.hash[index] = tmp->coll_chain;
+				tmp->ip = 0;
 			}
 		}
+		write_unlock(&tmp->lock);
 	}
-	spin_unlock_irqrestore(&unw.lock, flags);
 
 	kfree(table);
 }

