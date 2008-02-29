From: Doug Chapman <doug.chapman@hp.com>
Date: Fri, 29 Feb 2008 20:28:43 +0000
Subject: [PATCH] move gcc_intrin.h from header-y to unifdef-y
Message-Id: <1204316923.8186.14.camel@athlon>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I submitted 0df29025fd0379d5950d206314d0b10a2c8a9607 to ad
an #ifdef __KERNEL__ to include/asm-ia64/gcc_intrin.h a few weeks
ago I neglected to move gcc_intrin.h from header-y to unifdef-y.
Thanks to David Woodhouse for pointing this out.

Signed-off-by: Doug Chapman <doug.chapman@hp.com>
Signed-off-by: Jarod Wilson <jwilson@redhat.com>


diff --git a/include/asm-ia64/Kbuild b/include/asm-ia64/Kbuild
index 4a1e48b..eb24a3f 100644
--- a/include/asm-ia64/Kbuild
+++ b/include/asm-ia64/Kbuild
@@ -3,7 +3,6 @@ include include/asm-generic/Kbuild.asm
 header-y += break.h
 header-y += fpu.h
 header-y += fpswa.h
-header-y += gcc_intrin.h
 header-y += ia64regs.h
 header-y += intel_intrin.h
 header-y += intrinsics.h
@@ -12,5 +11,6 @@ header-y += ptrace_offsets.h
 header-y += rse.h
 header-y += ucontext.h
 
+unifdef-y += gcc_intrin.h
 unifdef-y += perfmon.h
 unifdef-y += ustack.h


