From: Keith Owens <kaos@sgi.com>
Date: Tue, 19 Oct 2004 08:20:05 +0000
Subject: [patch 2.6.9] Avoid a rare deadlock during unwind
Message-Id: <9718.1098174005@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a rare deadlock condition during unwind script creation.  If
build_script() is interrupted in the middle of creating the script, it
holds the script write lock.  If the interrupt handler needs to call
unwind for some failure condition, unwind will try to read the
incomplete script and will deadlock on the script lock.

The fix is to disable interrupts while building the script, so
interrupt handlers never see partial scripts.

Promoting spin_lock_irqsave() from script_new() to find_save_locs()
changes the indentation, so the patch looks bigger than it really is.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/unwind.c
=================================--- linux.orig/arch/ia64/kernel/unwind.c	Tue Oct 19 12:19:32 2004
+++ linux/arch/ia64/kernel/unwind.c	Tue Oct 19 17:58:19 2004
@@ -1279,7 +1279,6 @@ script_new (unsigned long ip)
 {
 	struct unw_script *script, *prev, *tmp;
 	unw_hash_index_t index;
-	unsigned long flags;
 	unsigned short head;
 
 	STAT(++unw.stat.script.news);
@@ -1288,13 +1287,9 @@ script_new (unsigned long ip)
 	 * Can't (easily) use cmpxchg() here because of ABA problem
 	 * that is intrinsic in cmpxchg()...
 	 */
-	spin_lock_irqsave(&unw.lock, flags);
-	{
-		head = unw.lru_head;
-		script = unw.cache + head;
-		unw.lru_head = script->lru_chain;
-	}
-	spin_unlock(&unw.lock);
+	head = unw.lru_head;
+	script = unw.cache + head;
+	unw.lru_head = script->lru_chain;
 
 	/*
 	 * We'd deadlock here if we interrupted a thread that is holding a read lock on
@@ -1305,43 +1300,39 @@ script_new (unsigned long ip)
 	if (!write_trylock(&script->lock))
 		return NULL;
 
-	spin_lock(&unw.lock);
-	{
-		/* re-insert script at the tail of the LRU chain: */
-		unw.cache[unw.lru_tail].lru_chain = head;
-		unw.lru_tail = head;
-
-		/* remove the old script from the hash table (if it's there): */
-		if (script->ip) {
-			index = hash(script->ip);
-			tmp = unw.cache + unw.hash[index];
-			prev = NULL;
-			while (1) {
-				if (tmp = script) {
-					if (prev)
-						prev->coll_chain = tmp->coll_chain;
-					else
-						unw.hash[index] = tmp->coll_chain;
-					break;
-				} else
-					prev = tmp;
-				if (tmp->coll_chain >= UNW_CACHE_SIZE)
-				/* old script wasn't in the hash-table */
-					break;
-				tmp = unw.cache + tmp->coll_chain;
-			}
+	/* re-insert script at the tail of the LRU chain: */
+	unw.cache[unw.lru_tail].lru_chain = head;
+	unw.lru_tail = head;
+
+	/* remove the old script from the hash table (if it's there): */
+	if (script->ip) {
+		index = hash(script->ip);
+		tmp = unw.cache + unw.hash[index];
+		prev = NULL;
+		while (1) {
+			if (tmp = script) {
+				if (prev)
+					prev->coll_chain = tmp->coll_chain;
+				else
+					unw.hash[index] = tmp->coll_chain;
+				break;
+			} else
+				prev = tmp;
+			if (tmp->coll_chain >= UNW_CACHE_SIZE)
+			/* old script wasn't in the hash-table */
+				break;
+			tmp = unw.cache + tmp->coll_chain;
 		}
+	}
 
-		/* enter new script in the hash table */
-		index = hash(ip);
-		script->coll_chain = unw.hash[index];
-		unw.hash[index] = script - unw.cache;
+	/* enter new script in the hash table */
+	index = hash(ip);
+	script->coll_chain = unw.hash[index];
+	unw.hash[index] = script - unw.cache;
 
-		script->ip = ip;	/* set new IP while we're holding the locks */
+	script->ip = ip;	/* set new IP while we're holding the locks */
 
-		STAT(if (script->coll_chain < UNW_CACHE_SIZE) ++unw.stat.script.collisions);
-	}
-	spin_unlock_irqrestore(&unw.lock, flags);
+	STAT(if (script->coll_chain < UNW_CACHE_SIZE) ++unw.stat.script.collisions);
 
 	script->flags = 0;
 	script->hint = 0;
@@ -1840,6 +1831,7 @@ find_save_locs (struct unw_frame_info *i
 {
 	int have_write_lock = 0;
 	struct unw_script *scr;
+	unsigned long flags = 0;
 
 	if ((info->ip & (local_cpu_data->unimpl_va_mask | 0xf)) || info->ip < TASK_SIZE) {
 		/* don't let obviously bad addresses pollute the cache */
@@ -1851,8 +1843,10 @@ find_save_locs (struct unw_frame_info *i
 
 	scr = script_lookup(info);
 	if (!scr) {
+		spin_lock_irqsave(&unw.lock, flags);
 		scr = build_script(info);
 		if (!scr) {
+			spin_unlock_irqrestore(&unw.lock, flags);
 			UNW_DPRINT(0,
 				   "unwind.%s: failed to locate/build unwind script for ip %lx\n",
 				   __FUNCTION__, info->ip);
@@ -1865,9 +1859,10 @@ find_save_locs (struct unw_frame_info *i
 
 	run_script(scr, info);
 
-	if (have_write_lock)
+	if (have_write_lock) {
 		write_unlock(&scr->lock);
-	else
+		spin_unlock_irqrestore(&unw.lock, flags);
+	} else
 		read_unlock(&scr->lock);
 	return 0;
 }

