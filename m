From: Pat Gefre <pfg@sgi.com>
Date: Mon, 18 Oct 2004 17:02:52 +0000
Subject: RE: Double spin_unlock in bte.c
Message-Id: <Pine.SGI.3.96.1041018120112.104915A-100000@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014114003.GF19122@lnx-holt.americas.sgi.com>
In-Reply-To: <20041014114003.GF19122@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 14 Oct 2004, Luck, Tony wrote:

+ >Tony, I don't think there's any hurry on this one, so you can 
+ >just send it along post-2.6.9 if you want.  Hopefully it won't conflict 
+ >with Pat's big sn2 patches.
+ 
+ It looks like it applies corectly on top of Pat's re-org patch. So
+ I'll send it along after that goes in.
+ 
+ -Tony
+ -
+ To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
+ the body of a message to majordomo@vger.kernel.org
+ More majordomo info at  http://vger.kernel.org/majordomo-info.html
+ 

Tony,

I have another bte mod too - I've added it to the list - it's
008-bugon-fix on the oss site.



# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/14 10:43:41-05:00 pfg@sgi.com 
#   arch/ia64/sn/kernel/bte.c
#       BUG_ON test was backwards
# 
# arch/ia64/sn/kernel/bte.c
#   2004/10/14 10:43:32-05:00 pfg@sgi.com +3 -3
#   BUG_ON test was backwards
# 
diff -Nru a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
--- a/arch/ia64/sn/kernel/bte.c	2004-10-14 10:44:34 -05:00
+++ b/arch/ia64/sn/kernel/bte.c	2004-10-14 10:44:34 -05:00
@@ -79,9 +79,9 @@
 		return BTE_SUCCESS;
 	}
 
-	BUG_ON(!((len & L1_CACHE_MASK) ||
-		 (src & L1_CACHE_MASK) || (dest & L1_CACHE_MASK)));
-	BUG_ON(len < ((BTE_LEN_MASK + 1) << L1_CACHE_SHIFT));
+	BUG_ON((len & L1_CACHE_MASK) ||
+		 (src & L1_CACHE_MASK) || (dest & L1_CACHE_MASK));
+	BUG_ON(!(len < ((BTE_LEN_MASK + 1) << L1_CACHE_SHIFT)));
 
 	if (mode & BTE_USE_DEST) {
 		/* try remote then local */

