From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 14 Dec 2004 19:31:12 +0000
Subject: Should we relax in udelay()?
Message-Id: <20041214193112.GT27199@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Would the following patch be a good idea?  Obviously, this is a busy-loop,
but does itc tick correctly while we're relaxing?

Index: include/asm-ia64/delay.h
=================================RCS file: /var/cvs/linux-2.6/include/asm-ia64/delay.h,v
retrieving revision 1.4
diff -u -p -r1.4 delay.h
--- linux/include/asm-ia64/delay.h	23 May 2004 23:52:58 -0000	1.4
+++ linux/include/asm-ia64/delay.h	14 Dec 2004 18:20:51 -0000
@@ -91,7 +91,7 @@ udelay (unsigned long usecs)
 	unsigned long cycles = usecs*local_cpu_data->cyc_per_usec;
 
 	while (ia64_get_itc() - start < cycles)
-		/* skip */;
+		cpu_relax();
 }
 
 #endif /* _ASM_IA64_DELAY_H */

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
