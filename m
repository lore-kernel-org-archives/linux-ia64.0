From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 21 Nov 2002 19:20:28 +0000
Subject: [Linux-ia64] ia64 objdump bug for brl instruction
Message-Id: <marc-linux-ia64-105590709805467@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We found a bug in ia64 objdump that brl instruction was decoded incorrectly.  The issue is that the mid 39 bit for the long immediate was incorrectly positioned and resulting in incorrect target branch address for branch long instruction.  This bug is on ia64 only.  The following patch fixes the issue. (note, it also fixes a spelling error as well :-).

- Ken

--- opcodes/ia64-dis.c.orig	Tue Mar 13 14:58:35 2001
+++ opcodes/ia64-dis.c	Thu Nov 21 11:16:43 2002
@@ -167,10 +167,10 @@
         }
       else if (odesc - elf64_ia64_operands == IA64_OPND_TGT64)
 	{
-	  /* 60-bit immedate for long branches.  */
+	  /* 60-bit immediate for long branches. */
 	  value = (((insn >> 13) & 0xfffff)
 		   | (((insn >> 36) & 1) << 59)
-		   | (slot[1] << 20)) << 4;
+		   | (((slot[1] >> 2) & 0x7fffffffffLL) << 20)) << 4;
 	}
       else
 	{


