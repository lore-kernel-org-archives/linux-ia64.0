From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 15 Aug 2000 07:22:24 +0000
Subject: [Linux-ia64] Glide patches for IA-64
Message-Id: <marc-linux-ia64-105590678205327@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As promised, here is the patch necessary to make Glide_V3 work on
IA-64 Linux.  I tested this with an AGP Vodoo 3 1000, though it should
work with other cards, too.  The patch is relative to
Glide_V3-DRI-3.10-6.src.rpm available from 3dfx (sorry, I didn't
bother checking out the CVS tree at sourceforge).

Caveat: the patch below may break backwards compatibility with 16-bit
platforms.  If anyone still cares about building on such a platform,
you may want to scan the patch below for uses of "int" and use
FxI32/FxU32 instead.

To develop this patch, my approach was to first build Glide using the
"standlone" mode.  I got a bunch of test programs to work that way
(test00, test01, etc. up to about test08) and then I realized that
something was seriously wrong with the buffer allocation code (beyond
64-bit problems), so I didn't bother to push it any further and
switched to the DRI mode instead.  In DRI mode, those buffer
allocation problems do not exist and all works fine as far as I know.

In the patch, getting rid of some of the compiler warnings may seem
pedantic, but I think it would have been a LOT harder to find some of
the bad casts if the other warnings had been left unfixed.  I'd
strongly recommend to merge in those changes.  A clean build with gcc
-O -Wall" goes a long way towards 64-bit cleanliness.

On the DRI front: note that you'll still need a 64-bit cleanup patch
(and IA-64) support for the X server before DRM/DRI works on IA-64.  I
plan to send that patch sometime tomorrow or on Wednesday.

Enjoy,

	--david

PS: If you're interested in seeing the IA-64 Linux Voodoo in action,
    visit the HP booth at Linux World Expo in San Jose this week. ;-)

diff -urN Glide_V3-DRI-3.10/ChangeLog Glide_V3-DRI-3.10-lia/ChangeLog
--- Glide_V3-DRI-3.10/ChangeLog	Wed Dec 31 16:00:00 1969
+++ Glide_V3-DRI-3.10-lia/ChangeLog	Mon Aug 14 23:51:43 2000
@@ -0,0 +1,326 @@
+2000-08-14  David Mosberger  <davidm@hpl.hp.com>
+
+	* swlibs/texus/lib/util.c (txYABtoPal256): Change type of yabTable
+	from "long*" to "int*".  Declare Y, A, and B to be of type "int*"
+	instead of "long*".
+	(txNearestColor): Change ir, ig, and ib arguments from "long" to
+	"int".
+
+	* swlibs/texus/lib/texusint.h (txYABtoPal256): Change yabTable
+	argument from "long*" to "int*".
+	(txNearestColor): Change ir, ig, and ib arguments from "long" to
+	"int".
+
+	* swlibs/texus/lib/texus.h [__LP64__]: Define FxI32 as "signed
+	int" and FxU32 as "unsigned int".
+
+	* swlibs/texus/lib/rgt.c (swapShorts): Change type of "length"
+	from "long" to "int".
+	(swapLongs): Ditto.
+	(swapRGB): Ditto.
+	(_txReadRGTData): Change cast of info->width to "long".
+
+	* swlibs/texus/lib/quantize.c: Put braces around each sub-array
+	initializer to keep compiler happy.
+	(_txPixQuantize_RGB332): Change type of argb from "unsigned long"
+	to "unsigned int".
+	(_txPixQuantize_RGB332_D4x4): Ditto.
+	(_txPixQuantize_RGB332_DErr): Ditto.
+	(_txPixQuantize_RGB332_A8): Ditto.
+	(_txPixQuantize_RGB332_I8): Ditto.
+	(_txPixQuantize_RGB332_AI44): Ditto.
+	(_txPixQuantize_RGB332_AI44_D4x4): Ditto.
+	(_txPixQuantize_RGB332_AI44_DErr): Ditto.
+	(_txPixQuantize_RGB332_ARGB8332): Ditto.
+	(_txPixQuantize_RGB332_ARGB8332_D4x4): Ditto.
+	(_txPixQuantize_RGB332_ARGB8332_DErr): Ditto.
+	(_txPixQuantize_RGB565): Ditto.
+	(_txPixQuantize_RGB565_D4x4): Ditto.
+	(_txPixQuantize_RGB565_DErr): Ditto.
+	(_txPixQuantize_ARGB1555): Ditto.
+	(_txPixQuantize_ARGB1555_D4x4): Ditto.
+	(_txPixQuantize_ARGB1555_DErr): Ditto.
+	(_txPixQuantize_ARGB4444): Ditto.
+	(_txPixQuantize_ARGB4444_D4x4): Ditto.
+	(_txPixQuantize_ARGB4444_DErr): Ditto.
+	(_txPixQuantize_AI88): Ditto.
+	(_txImgQuantize): Change type of quantizer callback to have a
+	first argument of type "unsigned int" instead of "unsigned long".
+	Cast "src" pointer to "unsigned int*" instead of "unsigned long*".
+	
+	* swlibs/texus/lib/pal256.c (Box): Change type of mean, weight,
+	and freq from "ulong" to "uint".
+	(Histogram): Change element type from "ulong" to "uint".
+	(SumPixels): Ditto.
+	(ColormaxI): Ditto.
+	(QuantHistogram): Change type of "pixels" from "ulong*" to
+	"uint*".
+	(txMipPal256): Change return value cast of txMalloc from "ulong*"
+	to "uint *".
+	(txMipPal256): In calls to bzero(), multiply by sizeof(uint)
+	instead of sizeof(ulong).
+	(txMipPal256): In call to QuantHistogram, change cast from
+	"ulong*" to "uint*".
+	(txMipPal256): Declare r, g, and b as "uint" instead of "ulong"
+	and truncate results of expressions for these variables to this
+	type as well.  Change type of src from "ulong*" to "uint*".
+	(QuantHistogram): Change type of rf, gf, and bf from "ulong*" to
+	"uint *".
+	(FindCutpoint): Change type of optweight and curweight from
+	"ulong" to "uint".
+	(UpdateFrequencies): Change type of myfreq and 8 to "uint" and
+	"uint*", respectively.  In calls to bzero(), multiply by
+	sizeof(uint) instead of sizeof(ulong).
+
+	* swlibs/texus/lib/nccnnet.c (struct _weight): Change member types
+	from "long" to "int".
+	(struct _vector): Ditto.
+	(errR): Change type from "long" to "int".
+	(errG): Ditto.
+	(errB): Ditto.
+	(errMax): Ditto.
+	(totR): Ditto.
+	(totG): Ditto.
+	(totB): Ditto.
+	(_nn_modifyNeurons): Change type of arguments from "long" to
+	"int".  Change type of "d", "dr", "dg", and "db" from "long" to
+	"int".
+	(txMapPal256toYAB): Change type of "bstR", "bstG", "bstB",
+	"bstMax" na "dyab2pal[]" from "long" to "int". Remove superfluous
+	cast in call to txYABtoPal256().
+	(txMipNccNNet): Change type of "yabTable[]" from "long" to "int".
+	Remove superfluous cast in call to txYABtoPal256().
+
+	* swlibs/texus/lib/ncc.c: Put braces around each sub-array
+	initializer to keep compiler happy.
+	(_txImgNcc): Change type of idata from "unsigned long*" to
+	"unsigned int *".
+	(txMipNcc): Remove superfluous cast to "long*".
+
+	* swlibs/texus/lib/mipmap.c (_txImgHalve): Change type of "indata"
+	from "long*" to "int*".
+
+	* swlibs/texus/lib/dequant.c (_txImgDequantizeYIQ422): Change type
+	of yabTable from "long*" to FxU32*.  Remove superfluous type casts
+	when passing argument to txYABtoPal256.
+	(_txImgDequantizeAYIQ8422): Change type of yab from "long*" to
+	FxU32*.  Declare "pal[]" as array of type FxU32 instead of "long".
+	Remove superfluous type cast when passing pallete to
+	_txImgDequantizeYIQ422() and _txImgDequantizeAYIQ8422().
+
+	* swlibs/newpci/pcilib/pcilib.h (FxPlatformIOProces): Change type
+	of addrUnmap's linearAddr argument from FxU32 to "long*".  Change
+	type of addrSetPermission's addrBase argument from FxU32 to
+	"long*".
+
+	* swlibs/newpci/pcilib/fxpci.h (pciMapPhysicalToLinear): Change
+	type of linear_addr from FxU32* to "long*".
+	(pciMapPhysicalDeviceToLinear): Ditto.
+	(pciUnmapPhysical): Change type of linear_addr from FxU32 to
+	"long".
+	(pciLinearRangeSetPermission): Change type of addrBase from FxU32
+	to "long".
+	
+	* swlibs/newpci/pcilib/fxpci.c (pciMapCardMulti): Change type of
+	virtAddress from FxU32 to "long".
+	(pciMapCardMulti): Cast "length" to "long" before casting it
+	to a pointer to avoid compiler warning.
+	(pciMapPhysicalToLinear): Change type of linear_addr from FxU32*
+	to "long*".
+	(pciMapPhysicalDeviceToLinear): Ditto.
+	(pciUnmapPhysical): Change type of linear_addr from FxU32 to "long".
+	(pciLinearRangeSetPermission): change type of addrBase from FxU32
+	to "long".
+
+	* swlibs/newpci/pcilib/fxlinux.c (pciMapLinearLinux): Change
+	linear_addr argument from FxU32* to "long*" type.
+	(pciUnmapLinearLinux): Change linear_addr type from FxU32 to
+	"long".
+	(pciSetPermissionLinux): Ditto.
+	(pciMapLinearLinux): Cast return value of mmap() to "long" instead
+	of FxU32 to avoid truncating top 32 bits.
+
+	* swlibs/include/make/3dfx.mak (CNODEBUG): Don't use x86 specific
+	compiler option "-m486" and reduce optimization level to -O3.
+
+	* swlibs/fxmisc/linutil.c: Explicitly give "init_done" a type of "int"
+	to avoid compiler warning.
+
+	* swlibs/fxmisc/fxos.c (fxFopenPath): Explicitly compare result
+	of assignment against NULL to avoid compiler warning.
+
+	* swlibs/fxmisc/fximg.c (_imgGuessType): Don't use non-portable
+	multi-byte character constants.
+	(_imgWriteP6Header): Remove extraneous argument in fprintf() call.
+	(imgReadFile): Explicitly compare result of assignment against
+	NULL to avoid compiler warning.
+
+	* swlibs/fxmisc/3dfx.h [__LP64__]: Define FxI32 as "signed int"
+	and FxU32 as "unsigned int".
+
+	* set-for-standalone: New script to set source for standalone
+	compilation.
+	* set-for-dri: New script to set up source for compilation with
+	DRI.
+
+	* h3/minihwc/minihwc.h: Change type of linearAddress[] from FxU32
+	to "long".  Change type of ioMemBase, cmdAGPBase, waxBase, sstBase,
+	lfbBase, and rawLfbBase from FxU32 to "long".
+
+	* h3/minihwc/minihwc.c (hwcMapBoard): Do not cast return value of
+	pciMapCardMulti() to FxU32 to avoid truncating top 32 bits.
+
+	* h3/minihwc/linhwc.c.save (P6FENCE) [__ia64__]: Make P6FENCE
+	expand into "mf.a" instruction.
+	(loadEnvFile): Rename local "first" to "is_first" to avoid
+	collision with global "first" list head pointer.
+	(hwcInitRegisters): Cast pointers to "long" instead of FxU32.
+
+	* h3/minihwc/linhwc.c.dri (P6FENCE) [__ia64__]: Make P6FENCE
+	expand into "mf.a" instruction.
+	(loadEnvFile): Rename local "first" to "is_first" to avoid
+	collision with global "first" list head pointer.
+	(hwcMapBoard): Cast pointers to "long" instead of FxU32.
+	(_grImportFifo): Declare as external function.
+	(_grInvalidateAll): Ditto.
+	(_grExportFifo): Ditto.
+	(grDRIResetSAREA): Cast fifoPtr to (int *).
+
+	* h3/minihwc/hwcext.h (struct hwcExtLinearADdrRes_s): Change type
+	of baseAddresses[] from FxU32 to "long".
+
+	* h3/incsrc/h3regs.h (struct vertex_Rec): Declare members as
+	FxU32/FxI32 instead of "unsigned long"/"long" to guarantee 32-bit
+	width.
+	(struct sstregs): Ditto.
+
+	* h3/incsrc/h3info.h (FxU32) [__LP64__]: Define FxU32 as "unsigned
+	int".
+	* h3/incsrc/h3regs.h: Ditto.
+
+	* h3/incsrc/h3defs.h (FLOAT_ISNEG): Define more suitable version
+	for IA-64.
+	(ISIGN): Ditto.
+	(FSIGN): Ditto.
+	(SST_WRAP): Cast "sst" pointer to "long" instead of FxI32 before
+	doing arithmetic on it.
+	(SST_CHIP): Ditto.
+	(SST_TMU): Ditto.
+	(SST_BASE_ADDRESS): Ditto.
+	
+	* h3/incsrc/gdebug.h (GDBG_INFO) [__GNUC__]: Use GNU CPP varag
+	macros to avoid flood of compiler warnings due to useless
+	expressions.
+	(GDBG_INFO_MORE): Ditto.
+	(GDBG_PRINF): Ditto.
+	(GDBG_ERROR_SET_CALLBACK): Ditto.
+	(GDBG_ERROR_CLEAR_CALLBACK): Ditto.
+
+	* h3/glide3/src/makefile.linux (FX_GLIDE_CTRISETUP): Define as 1
+	to use C source code instead of assembly code (should be done only
+	on platforms that don't have assembly versions of the triangle
+	setup code).
+
+	* h3/glide3/src/gthread.c (setThreadValue): Change argument type
+	from FxU32 to "long".
+	(getThreadValueSlow): Change return value from FxU32 to "long".
+
+	* h3/glide3/src/gtexdl.c (_grTexDownloadPalette): Put parens around
+	logical AND to avoid compiler warning.
+
+	* h3/glide3/src/gsst.c.save (initGC): Cast pointers to "long"
+	before doing arithmetic on them.  Cast pointer to "long" before
+	using it as a thread value.
+	(grSstWinOpen): Cast pointers to "long" instead of FxU32 before
+	doing arithmetic on them.  Explicitly compare return value of
+	assignment against != 0 to avoid compiler warning.
+	(grSstWinClose): Cast pointer to "long" before using it as a
+	thread value.
+
+	* h3/glide3/src/gpci.c (_triSetupProcs): Explicitly cast
+	_trisetup_null to GrTriSetupProc to avoid compiler warning.
+	(DllMain): Cast pointer to "long" before using it as a thread value.
+
+	* h3/glide3/src/glide.h (GrContext_t): Change type from FxU32 to
+	"unsigned long".
+
+	* h3/glide3/src/glfb.c.dri (grLfbWriteRegion): Cast pointer to
+	(long) instead of (int) before doing arithmetic on it.
+	(grLfbReadRegion): Ditto.
+
+	* h3/glide3/src/gglide.c.save b(grGlideShutdown): Fix typo: replace
+	"readPtr0 != readPtr1" with "depth0 != depth1".  Cast "gc" to
+	"long" instead of FxU32.
+
+	* h3/glide3/src/gglide.c.dri (grDRIBufferSwap): Write 0xCC as
+	0xCCu to avoid compiler warning regarding implicit conversion of
+	constant from signed to unsigned int.
+	(grGlideShutdown): Fix typo: replace "readPtr0 != readPtr1" with
+	"depth0 != depth1".  Cast "gc" to "long" instead of FxU32.
+
+	* h3/glide3/src/gerror.c (_grAssert): Cast pointers to (long"
+	instead of (FxU32) before doing arithmetic on them.  *
+	h3/glide3/src/gglide.c.dri: Ditto.
+
+	* h3/glide3/src/gdraw.c (GR_ENTRY): Don't assume that function
+	parameters are being passed on the stack.  Instead, explicitly use
+	and initialize the new "vertices[]"" array with the "a" and "b"
+	pointers.
+	(DA_END): Cast pointers to "long" instead of FxU32 before doing
+	arithmetic on them.
+	(_grDrawPoints): If mode is not zero, initialize "stride" to the
+	number of floats that corresponds to the size of a pointer (1 on a
+	32-bit platform, 2 on a 64-bit platform).  This code works
+	properly as long as sizeof(void*)=N*sizeof(float) for some
+	integer constant N.
+	(_grDrawLineStrip): Ditto.
+	(_grDrawTriangles_Default): Ditto.
+	(_grDrawLineStrip): Cast &ADY and &DX to "int *" instead of "long *".
+
+	* h3/glide3/src/gaa.c (aaVpDrawArrayEdgeSense): Cast pointers to
+	"long" instead of "int" before doing arithmetic on them.
+	(_grAADrawPoints): Ditto.
+	(_grAADrawLineStrip): Ditto.
+	(aaDrawArrayEdgeSense): Ditto.
+
+	* h3/glide3/src/g3df.c: Include <ctype.h> to avoid warning due to
+	implicit declaration of "toupper".
+
+	* h3/glide3/src/fxglide.h (GR_TEX_FLUSH_WRITE): Cast pointers to
+	"long" instead of FxU32 before doing arithmetic on them.
+	(GrGC_s): Change type of "fifoRead", "lfbBuffers[]", and
+	"lockPtrs[]" from FxU32 to "long".
+	(P6FENCE) [__ia64__]: Make P6FENCE expand into "mf.a"
+	instruction.
+	(threadValueLinux): Change type from FxU32 to "long".
+	(setThreadValue): Change thread value type from FxU32 to "long".
+	(getThreadValueSLOW): Ditto.
+	(GR_ASSERT) [!GLIDE_SANITY_ASSERT && __GNUC__]: Define GR_ASSERT()
+	as no-op.
+	(FARRAY): Cast pointer to "long" before doing arithmetic on it.
+
+	* h3/glide3/src/fxcmd.h (REG_GROUP_END): Cast poitners to "long"
+	instead of FxU32 before doing arithmetic on them.
+	(TRI_END): Ditto.
+	(FIFO_LINEAR_WRITE_BEGIN): Ditto.
+	(FIFO_LINEAR_WRITE_END): Ditto.
+	(AA_TRI_VP_SETFS): Ditto.
+	(REG_GROUP_SETF_CLAMP): Remove trailing whitespace.
+
+	* h3/glide3/src/fifo.c (_grHwFifoPtr): Change return type from
+	FxU32 to "long".
+	* h3/glide3/src/distrip.c (GR_DIENTRY): Cast pointers to "long"
+	instead of FxU32 before doing arithmetic on them.  *
+	h3/glide3/src/fifo.c (GEN_INDEX): Ditto.
+	(_grCommandTransportMakeRoom): Comment out unused variable
+	"wrapAddr".
+
+	* h3/glide3/src/disst.c (GR_DIENTRY): Cast thread value to (long)
+	not FxU32.
+
+	* h3/glide3/src/diget.c (GR_DIENTRY): For GR_SURFACE_TEXTURE,
+	verify plength has the size of a "long" and return tBuffer address
+	as a "long".
+
+	* h3/glide3/src/cpudtect.S: Add (minimal) IA-64 suppot.
+
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/cpudtect.S Glide_V3-DRI-3.10-lia/h3/glide3/src/cpudtect.S
--- Glide_V3-DRI-3.10/h3/glide3/src/cpudtect.S	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/cpudtect.S	Wed Aug  9 13:36:45 2000
@@ -49,6 +49,19 @@
 /*  Neutered mutiplatform multiheaded monster. */
 
 
+#ifdef __ia64__
+
+	.align 32
+	.global _cpu_detect_asm
+	.proc _cpu_detect_asm
+
+_cpu_detect_asm:
+	mov ret0=0
+	br.ret.sptk.few b0
+
+	.end _cpu_detect_asm
+
+#else /* !__ia64__ */
 
 .file "cpudtect.asm"
 
@@ -324,3 +337,5 @@
 .size double_precision_asm,.L_END_double_precision_asm-double_precision_asm
 
 .end
+
+#endif /* !__ia64__ */
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/diget.c Glide_V3-DRI-3.10-lia/h3/glide3/src/diget.c
--- Glide_V3-DRI-3.10/h3/glide3/src/diget.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/diget.c	Mon Aug 14 21:38:41 2000
@@ -615,10 +615,10 @@
     break;
 
   case GR_SURFACE_TEXTURE:
-    if (plength = 4) {
+    if (plength = sizeof(long)) {
       GR_DCL_GC;
 
-      *params = (FxU32) &gc->tBuffer;
+      *(long *)params = (long) &gc->tBuffer;
       retVal = plength;
     }
     break;
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/disst.c Glide_V3-DRI-3.10-lia/h3/glide3/src/disst.c
--- Glide_V3-DRI-3.10/h3/glide3/src/disst.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/disst.c	Wed Aug  9 14:58:01 2000
@@ -183,7 +183,7 @@
     GrErrorCallback( "grSstSelect:  non-existent SST", FXTRUE );
 
   _GlideRoot.current_sst = which;
-  setThreadValue( (FxU32)&_GlideRoot.GCs[_GlideRoot.current_sst] );
+  setThreadValue( (long)&_GlideRoot.GCs[_GlideRoot.current_sst] );
 
 #ifdef GLIDE_MULTIPLATFORM
   _GlideRoot.curGCFuncs = _GlideRoot.curGC->gcFuncs;
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/distrip.c Glide_V3-DRI-3.10-lia/h3/glide3/src/distrip.c
--- Glide_V3-DRI-3.10/h3/glide3/src/distrip.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/distrip.c	Wed Aug  9 23:57:00 2000
@@ -544,10 +544,10 @@
     else {
       void *b_ptr, *c_ptr;
       while ((int)Count >= 3) {
-        b_ptr = (void *)((FxU32)pointers + stride);
-        c_ptr = (void *)((FxU32)pointers + stride*2);
+        b_ptr = (void *)((long)pointers + stride);
+        c_ptr = (void *)((long)pointers + stride*2);
         TRISETUP(pointers, b_ptr, c_ptr);
-        pointers = (void *)((FxU32)c_ptr + stride);
+        pointers = (void *)((long)c_ptr + stride);
         Count -= 3;
       }
     }
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/fifo.c Glide_V3-DRI-3.10-lia/h3/glide3/src/fifo.c
--- Glide_V3-DRI-3.10/h3/glide3/src/fifo.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/fifo.c	Thu Aug 10 00:07:26 2000
@@ -475,7 +475,7 @@
 } ;
 
 
-#define GEN_INDEX(a) ((((FxU32) a) - ((FxU32) gc->reg_ptr)) >> 2)
+#define GEN_INDEX(a) ((((long) a) - ((long) gc->reg_ptr)) >> 2)
 
 void
 _grFifoWriteDebug(FxU32 addr, FxU32 val, FxU32 fifoPtr)
@@ -833,7 +833,9 @@
     gc->contextP = 1; 
 #endif
     if (gc->contextP) {
+#if 0
       FxU32 wrapAddr = 0x00UL;
+#endif
       FxU32 checks;
 
       GR_ASSERT(blockSize > 0);
@@ -973,7 +975,9 @@
           
         P6FENCE;
     
+#if 0
         wrapAddr = (FxU32)gc->cmdTransportInfo.fifoPtr;
+#endif
           
         /* Update roomXXX fields for the actual wrap */
         gc->cmdTransportInfo.roomToReadPtr -= gc->cmdTransportInfo.roomToEnd;
@@ -1047,10 +1051,10 @@
 }
 
 
-FxU32
+long
 _grHwFifoPtr(FxBool ignored)
 {
-  FxU32 rVal = 0;
+  long rVal = 0;
 
   FxU32 status, readPtrL1, readPtrL2;
   GR_DCL_GC;
@@ -1069,7 +1073,7 @@
 #endif      
       readPtrL2 = GET(gc->cRegs->cmdFifo0.readPtrL);
     } while (readPtrL1 != readPtrL2);
-    rVal = (((FxU32)gc->cmdTransportInfo.fifoStart) + 
+    rVal = (((long)gc->cmdTransportInfo.fifoStart) + 
             readPtrL2 - 
             (FxU32)gc->cmdTransportInfo.fifoOffset);
   }
@@ -1191,13 +1195,13 @@
   gcFifo=&gc->cmdTransportInfo;
   readPos=readPos-gcFifo->fifoOffset;
   gcFifo->fifoPtr = gcFifo->fifoStart + (readPos>>2);
-  gcFifo->fifoRead = (FxU32)gcFifo->fifoPtr;
+  gcFifo->fifoRead = (long)gcFifo->fifoPtr;
 #else
   gcFifo=&gc->cmdTransportInfo;
   gcFifo->fifoPtr = gc->rawLfb+(fifoPtr>>2);
   gcFifo->fifoRead = ((int)gc->rawLfb)+fifoRead;
 #endif
-  gcFifo->roomToReadPtr = gcFifo->fifoRead-((int)gcFifo->fifoPtr)-FIFO_END_ADJUST-sizeof(FxU32);
+  gcFifo->roomToReadPtr = gcFifo->fifoRead-((long)gcFifo->fifoPtr)-FIFO_END_ADJUST-sizeof(FxU32);
   if (gcFifo->roomToReadPtr<0) gcFifo->roomToReadPtr+=gcFifo->fifoSize;
   gcFifo->roomToEnd = gcFifo->fifoSize - 
     ((gcFifo->fifoPtr-gcFifo->fifoStart)<<2) -
@@ -1215,7 +1219,7 @@
   GR_DCL_GC;
   gcFifo=&gc->cmdTransportInfo;
   *fifoPtr=(gcFifo->fifoPtr-gc->rawLfb)<<2;
-  *fifoRead=(gcFifo->fifoRead-(int)gc->rawLfb);
+  *fifoRead=(gcFifo->fifoRead-(long)gc->rawLfb);
 }
 
 #endif
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/fxcmd.h Glide_V3-DRI-3.10-lia/h3/glide3/src/fxcmd.h
--- Glide_V3-DRI-3.10/h3/glide3/src/fxcmd.h	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/fxcmd.h	Wed Aug  9 23:39:35 2000
@@ -182,7 +182,7 @@
 /* NB: This should be used sparingly because it does a 'real' hw read
  * which is *SLOW*.
  */
-FxU32 _grHwFifoPtr(FxBool);
+long _grHwFifoPtr(FxBool);
 #define HW_FIFO_PTR(a) _grHwFifoPtr(a)
 
 #if FIFO_ASSERT_FULL
@@ -716,8 +716,8 @@
 
 #define REG_GROUP_END() \
   ASSERT(_checkP); \
-  ASSERT((((FxU32)_regGroupFifoPtr - (FxU32)gc->cmdTransportInfo.fifoPtr) >> 2) = _groupNum + 1); \
-  gc->cmdTransportInfo.fifoRoom -= ((FxU32)_regGroupFifoPtr - (FxU32)gc->cmdTransportInfo.fifoPtr); \
+  ASSERT((((long)_regGroupFifoPtr - (long)gc->cmdTransportInfo.fifoPtr) >> 2) = _groupNum + 1); \
+  gc->cmdTransportInfo.fifoRoom -= ((long)_regGroupFifoPtr - (long)gc->cmdTransportInfo.fifoPtr); \
   gc->cmdTransportInfo.fifoPtr = (FxU32*)_regGroupFifoPtr; \
   GDBG_INFO(gc->myLevel + 200, "\tGroupEnd: (0x%X : 0x%X)\n", \
             gc->cmdTransportInfo.fifoPtr, gc->cmdTransportInfo.fifoRoom); \
@@ -1028,7 +1028,7 @@
 
 #define TRI_END \
   TRI_ASSERT(); \
-  gc->cmdTransportInfo.fifoRoom -= ((FxU32)tPackPtr - (FxU32)gc->cmdTransportInfo.fifoPtr); \
+  gc->cmdTransportInfo.fifoRoom -= ((long)tPackPtr - (long)gc->cmdTransportInfo.fifoPtr); \
   gc->cmdTransportInfo.fifoPtr = tPackPtr; \
   GDBG_INFO(gc->myLevel + 200, "\tTriEnd: (0x%X : 0x%X)\n", tPackPtr, gc->cmdTransportInfo.fifoRoom); \
   FIFO_ASSERT(); \
@@ -1047,12 +1047,12 @@
   GR_CHECK_COMPATABILITY(FN_NAME, \
                          !gc->open, \
                          "Called before grSstWinOpen()"); \
-  GR_ASSERT(((FxU32)(packetPtr) & FIFO_ALIGN_MASK) = 0);        /* alignment */ \
+  GR_ASSERT(((long)(packetPtr) & FIFO_ALIGN_MASK) = 0);        /* alignment */ \
   GR_ASSERT((__numWords) > 0);                                   /* packet size */ \
   GR_ASSERT((__numWords) < ((0x01 << 19) - 2)); \
   GR_ASSERT((((FxU32)(__numWords) + 2) << 2) <= (FxU32)gc->cmdTransportInfo.fifoRoom); \
-  GR_ASSERT(((FxU32)packetPtr + (((__numWords) + 2) << 2)) < \
-            (FxU32)gc->cmdTransportInfo.fifoEnd); \
+  GR_ASSERT(((unsigned long)packetPtr + (((__numWords) + 2) << 2)) < \
+            (unsigned long)gc->cmdTransportInfo.fifoEnd); \
   GR_ASSERT((hdr2 & 0xE0000000UL) = 0x00UL); \
   GR_ASSERT(((__addr) & 0x03UL) = 0x00UL); \
   FIFO_ASSERT(); \
@@ -1097,8 +1097,8 @@
 
 #define FIFO_LINEAR_WRITE_END \
   DEBUGFIFODUMP_LINEAR(gc->cmdTransportInfo.fifoPtr); \
-  GR_ASSERT((((FxU32)packetPtr - (FxU32)gc->cmdTransportInfo.fifoPtr) >> 2) = __writeSize + 2); \
-  gc->cmdTransportInfo.fifoRoom -= ((FxU32)packetPtr - (FxU32)gc->cmdTransportInfo.fifoPtr); \
+  GR_ASSERT((((long)packetPtr - (long)gc->cmdTransportInfo.fifoPtr) >> 2) = __writeSize + 2); \
+  gc->cmdTransportInfo.fifoRoom -= ((long)packetPtr - (long)gc->cmdTransportInfo.fifoPtr); \
   gc->cmdTransportInfo.fifoPtr = packetPtr; \
   GDBG_INFO(gc->myLevel + 200, "\tLinearEnd: (0x%X : 0x%X)\n", \
             packetPtr, gc->cmdTransportInfo.fifoRoom); \
@@ -1312,7 +1312,7 @@
 #define REG_GROUP_SETF_CLAMP(__regBase, __regAddr, __val) \
 do { \
   const FxU32 fpClampVal = FP_FLOAT_CLAMP(__val); \
-  REG_GROUP_ASSERT(__regAddr, fpClampVal, FXTRUE); \  
+  REG_GROUP_ASSERT(__regAddr, fpClampVal, FXTRUE); \
   SET(((FxU32*)(__regBase))[offsetof(SstRegs, __regAddr) >> 2], fpClampVal); \
   GR_INC_SIZE(sizeof(FxU32)); \
 } while(0)
@@ -1512,7 +1512,7 @@
     } \
     else { \
       FxU32 argb; \
-      argb = *((FxU32 *)((int)_s + i)) & 0x00ffffff; \
+      argb = *((FxU32 *)((long)_s + i)) & 0x00ffffff; \
       TRI_SETF(*((float *)&argb)); \
       dataElem++; \
       i = gc->tsuDataList[dataElem]; \
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/fxglide.h Glide_V3-DRI-3.10-lia/h3/glide3/src/fxglide.h
--- Glide_V3-DRI-3.10/h3/glide3/src/fxglide.h	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/fxglide.h	Wed Aug  9 23:35:20 2000
@@ -1039,7 +1039,7 @@
           SET(*curFifoPtr++, *curPktData++); \
         } \
         GR_INC_SIZE((__writeCount) * sizeof(FxU32)); \
-        gc->cmdTransportInfo.fifoRoom -= ((FxU32)curFifoPtr - (FxU32)gc->cmdTransportInfo.fifoPtr); \
+        gc->cmdTransportInfo.fifoRoom -= ((long)curFifoPtr - (long)gc->cmdTransportInfo.fifoPtr); \
         gc->cmdTransportInfo.fifoPtr = curFifoPtr; \
       } \
       GR_CHECK_SIZE(); \
@@ -1158,7 +1158,7 @@
                           */
     
     FxU32* fifoPtr;      /* Current write pointer into fifo */
-    FxU32  fifoRead;     /* Last known hw read ptr. 
+    long   fifoRead;     /* Last known hw read ptr. 
                           * If on an sli enabled system this will be
                           * the 'closest' hw read ptr of the sli
                           * master and slave.
@@ -1244,11 +1244,12 @@
     curBuffer,
     frontBuffer,
     backBuffer,
-    buffers[4],
+    buffers[4];
+  long
     lfbBuffers[4];              /* Tile relative addresses of the color/aux
                                  * buffers for lfbReads.
                                  */  
-  FxU32 lockPtrs[2];        /* pointers to locked buffers */
+  long lockPtrs[2];        /* pointers to locked buffers */
   FxU32 fbStride;
 
   struct {
@@ -1475,6 +1476,8 @@
 #  define P6FENCE __eieio()
 #elif defined(__GNUC__) && defined(__i386__)
 #define P6FENCE asm("xchg %%eax, %0" : : "m" (_GlideRoot.p6Fencer) : "eax");
+#elif defined(__GNUC__) && defined(__ia64__)
+# define P6FENCE asm volatile ("mf.a" ::: "memory");
 #else  /* !defined ( P6FENCE ) */
 #  error "P6 Fencing code needs to be added for this compiler"
 #endif /* !defined ( P6FENCE ) */
@@ -1798,7 +1801,7 @@
 #endif
 
 #ifdef __linux__
-extern FxU32 threadValueLinux;
+extern long threadValueLinux;
 #define getThreadValueFast() threadValueLinux
 #endif
 
@@ -1813,9 +1816,9 @@
 initThreadStorage( void );
 
 void 
-setThreadValue( FxU32 value );
+setThreadValue( long value );
 
-FxU32
+long
 getThreadValueSLOW( void );
 
 void 
@@ -2093,7 +2096,11 @@
 #if defined(GLIDE_SANITY_ASSERT)
 #define GR_ASSERT(exp) ((void)((!(exp)) ? (_grAssert(#exp,  __FILE__, __LINE__),0) : 0xFFFFFFFF))
 #else
-#define GR_ASSERT(exp) ((void)(0 && ((FxU32)(exp))))
+# ifdef __GNUC__
+#  define GR_ASSERT(exp)	((void) 0)
+# else
+#  define GR_ASSERT(exp) ((void)(0 && ((FxU32)(exp))))
+# endif
 #endif
 
 #define INTERNAL_CHECK(__name, __cond, __msg, __fatalP) \
@@ -2163,7 +2170,7 @@
 #define HW_TEX_PTR(__b)        ((FxU32*)(((FxU32)(__b)) + HW_TEXTURE_OFFSET))   
 
 /* access a floating point array with a byte index */
-#define FARRAY(p,i)    (*(float *)((i)+(int)(p)))
+#define FARRAY(p,i)    (*(float *)((i)+(long)(p)))
 #define ArraySize(__a) (sizeof(__a) / sizeof((__a)[0]))
 
 #if GDBG_INFO_ON
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/g3df.c Glide_V3-DRI-3.10-lia/h3/glide3/src/g3df.c
--- Glide_V3-DRI-3.10/h3/glide3/src/g3df.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/g3df.c	Wed Aug  9 23:23:12 2000
@@ -70,6 +70,7 @@
  * Added GR_DIENTRY for di glide functions
 **
 */
+#include <ctype.h>
 #include <stdio.h>
 #include <string.h>
 #include <3dfx.h>
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gaa.c Glide_V3-DRI-3.10-lia/h3/glide3/src/gaa.c
--- Glide_V3-DRI-3.10/h3/glide3/src/gaa.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gaa.c	Wed Aug  9 23:36:10 2000
@@ -378,8 +378,8 @@
   }
   else {
     ia = gc->state.vData.pargbInfo.offset;
-    *((FxU32 *)&v1a)=*((FxU32 *)((int)a + ia))&0x00ffffff;
-    *((FxU32 *)&v2a)=*((FxU32 *)((int)b + ia))&0x00ffffff;
+    *((FxU32 *)&v1a)=*((FxU32 *)((long)a + ia))&0x00ffffff;
+    *((FxU32 *)&v2a)=*((FxU32 *)((long)b + ia))&0x00ffffff;
   }
 
   {
@@ -678,7 +678,7 @@
               FxU32 argb;
               
               if (i = ia) {
-                argb = *((FxU32 *)((int)e + i)) & 0x00ffffff;
+                argb = *((FxU32 *)((long)e + i)) & 0x00ffffff;
                 TRI_SETF(*((float *)&argb));
               }
               else {
@@ -855,8 +855,8 @@
         ady = -ady;
       
       if (gc->state.vData.colorType != GR_FLOAT) {
-        *((FxU32 *)&v1a)=*((FxU32 *)((int)v1 + ia))&0x00ffffff;
-        *((FxU32 *)&v2a)=*((FxU32 *)((int)v2 + ia))&0x00ffffff;
+        *((FxU32 *)&v1a)=*((FxU32 *)((long)v1 + ia))&0x00ffffff;
+        *((FxU32 *)&v2a)=*((FxU32 *)((long)v2 + ia))&0x00ffffff;
       }
       
       if (adx >= ady) {           /* X major line */
@@ -1255,8 +1255,8 @@
   }
   else {
     ia = gc->state.vData.pargbInfo.offset;
-    *((FxU32 *)&v1a)=*((FxU32 *)((int)a + ia))&0x00ffffff;
-    *((FxU32 *)&v2a)=*((FxU32 *)((int)b + ia))&0x00ffffff;
+    *((FxU32 *)&v1a)=*((FxU32 *)((long)a + ia))&0x00ffffff;
+    *((FxU32 *)&v2a)=*((FxU32 *)((long)b + ia))&0x00ffffff;
   }
 
   {
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gdraw.c Glide_V3-DRI-3.10-lia/h3/glide3/src/gdraw.c
--- Glide_V3-DRI-3.10/h3/glide3/src/gdraw.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gdraw.c	Thu Aug 10 23:52:27 2000
@@ -233,13 +233,15 @@
 GR_ENTRY(grDrawLine, void, (const void *a, const void *b))
 {
 #define FN_NAME "grDrawLine"
+  const void *vertices[2] = {a, b};
+
   GR_BEGIN_NOFIFOCHECK(FN_NAME, 91);
   GDBG_INFO_MORE(gc->myLevel, "(a = 0x%x, b = 0x%x)\n", a, b);
 
   if (gc->state.grEnableArgs.primitive_smooth_mode & GR_AA_ORDERED_LINES_MASK)
-    _grAADrawLineStrip(GR_VTX_PTR_ARRAY, GR_LINES, 2, (void *)&a);
+    _grAADrawLineStrip(GR_VTX_PTR_ARRAY, GR_LINES, 2, vertices);
   else
-    _grDrawLineStrip(GR_VTX_PTR_ARRAY, GR_LINES, 2, (void *)&a);
+    _grDrawLineStrip(GR_VTX_PTR_ARRAY, GR_LINES, 2, vertices);
 #undef FN_NAME
 } /* grDrawLine */
 
@@ -323,7 +325,7 @@
   GR_INC_SIZE(sizeof(FxU32))
 
 #define DA_END \
-  gc->cmdTransportInfo.fifoRoom -= ((FxU32)packetPtr - (FxU32)gc->cmdTransportInfo.fifoPtr); \
+  gc->cmdTransportInfo.fifoRoom -= ((long)packetPtr - (long)gc->cmdTransportInfo.fifoPtr); \
   gc->cmdTransportInfo.fifoPtr = packetPtr; \
   FIFO_ASSERT(); \
 }
@@ -348,7 +350,7 @@
    * except the data set up is from the pointer array and 
    * its data layout
    */
-  FxI32 stride = mode;
+  FxI32 stride;
 
   /* we snap to an integer by adding a large enough number that it
    * shoves all fraction bits off the right side of the mantissa.
@@ -382,8 +384,10 @@
    */
 #define POINTS_BUFFER  100
 
-  if (stride = 0)
+  if (mode = 0)
     stride = gc->state.vData.vStride;
+  else
+    stride = sizeof(float *) / sizeof (float);
 
   if (gc->state.grCoordinateSpaceArgs.coordinate_space_mode = GR_WINDOW_COORDS) {
     while (count > 0) {
@@ -573,7 +577,7 @@
   int j;
   FxI32 sCount;
   FxU32 vertexParamOffset;
-  FxI32 stride = mode;
+  FxI32 stride;
 
 #define  DX gc->pool.ftemp1
 #define ADY gc->pool.ftemp2
@@ -589,8 +593,11 @@
 
 #define LINES_BUFFER  100
 
-  if (stride = 0)
+  if (mode = 0)
     stride = gc->state.vData.vStride;
+  else
+    stride = sizeof(float *) / sizeof (float);
+
   if (ltype = GR_LINES)
     sCount = count >> 1; /* line list */
   else
@@ -618,16 +625,16 @@
         ** compute absolute deltas and draw from low Y to high Y
         */
         ADY = FARRAY(b, gc->state.vData.vertexInfo.offset+4) - FARRAY(a, gc->state.vData.vertexInfo.offset+4);
-        i = *(long *)&ADY;
+        i = *(int *)&ADY;
         if (i < 0) {
           float *tv;
           tv = a; a = b; b = tv;
           i ^= 0x80000000;            /* ady = -ady; */
-          (*(long *)&ADY) = i;
+          (*(int *)&ADY) = i;
         }
         
         DX = FARRAY(b, gc->state.vData.vertexInfo.offset) - FARRAY(a, gc->state.vData.vertexInfo.offset);
-        j = *(long *)&DX;
+        j = *(int *)&DX;
         if (j < 0) {
           j ^= 0x80000000;            /* adx = -adx; */
         }
@@ -797,7 +804,7 @@
         ** compute absolute deltas and draw from low Y to high Y
         */
         ADY = tmp2 - tmp1;
-        i = *(long *)&ADY;
+        i = *(int *)&ADY;
         if (i < 0) {
           float *tv;          
           owa = oowb; owb = oowa;
@@ -805,7 +812,7 @@
           fby = tmp1;
           tv = a; a = b; b = tv;
           i ^= 0x80000000;            /* ady = -ady; */
-          (*(long *)&ADY) = i;
+          (*(int *)&ADY) = i;
         }
         fax = FARRAY(a, gc->state.vData.vertexInfo.offset)
           *owa*gc->state.Viewport.hwidth+gc->state.Viewport.ox;
@@ -813,7 +820,7 @@
           *owb*gc->state.Viewport.hwidth+gc->state.Viewport.ox;
         
         DX = fbx - fax;
-        j = *(long *)&DX;
+        j = *(int *)&DX;
         if (j < 0) {
           j ^= 0x80000000;            /* adx = -adx; */
         }
@@ -901,7 +908,7 @@
     vSize,
 #endif
     k;
-  FxI32 stride = mode;
+  FxI32 stride;
   float *vPtr;
 
   GR_BEGIN_NOFIFOCHECK(FN_NAME, 90);
@@ -917,9 +924,10 @@
   GDBG_INFO(110, "%s:  paramMask = 0x%x\n", FN_NAME, gc->cmdTransportInfo.paramMask);
 #endif
 
-  if (stride = 0)
+  if (mode = 0)
     stride = gc->state.vData.vStride;
-
+  else
+    stride = sizeof(float *) / sizeof (float);
 
   gc->stats.trisProcessed+=(count/3);
 
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gerror.c Glide_V3-DRI-3.10-lia/h3/glide3/src/gerror.c
--- Glide_V3-DRI-3.10/h3/glide3/src/gerror.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gerror.c	Wed Aug  9 23:26:01 2000
@@ -280,7 +280,7 @@
     
     gdbg_printf("Command Fifo:\n");
     gdbg_printf("\tSoftware:\n");
-    gdbg_printf("\t\tfifoPtr:           0x%X\n", (FxU32)gc->cmdTransportInfo.fifoPtr - (FxU32) gc->rawLfb);
+    gdbg_printf("\t\tfifoPtr:           0x%X\n", (long)gc->cmdTransportInfo.fifoPtr - (long) gc->rawLfb);
     gdbg_printf("\t\tfifoOffset:        0x%X\n", gc->cmdTransportInfo.fifoOffset); 
     gdbg_printf("\t\tfifoEnd:           0x%X\n", gc->cmdTransportInfo.fifoEnd - gc->rawLfb);
     gdbg_printf("\t\tfifoSize:          0x%X\n", gc->cmdTransportInfo.fifoSize); 
@@ -290,7 +290,7 @@
 
     if ( !gc->windowed ) {
       gdbg_printf("\tHardware:\n");
-      gdbg_printf("\t\treadPtrL:          0x%X\n", HW_FIFO_PTR(FXTRUE) - (FxU32)gc->rawLfb);
+      gdbg_printf("\t\treadPtrL:          0x%X\n", HW_FIFO_PTR(FXTRUE) - (long)gc->rawLfb);
       gdbg_printf("\t\tdepth:             0x%X\n", GR_CAGP_GET(depth));
       gdbg_printf("\t\tholeCount:         0x%X\n", GR_CAGP_GET(holeCount));
       gdbg_printf("\t\tbaseAddrL:         0x%X\n", GR_CAGP_GET(baseAddrL));
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gglide.c Glide_V3-DRI-3.10-lia/h3/glide3/src/gglide.c
--- Glide_V3-DRI-3.10/h3/glide3/src/gglide.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gglide.c	Wed Aug  9 23:41:48 2000
@@ -1179,8 +1179,8 @@
     for ( i = 0; i < MAX_BUFF_PENDING && j = -1; i++) {
       if (gc->bufferSwaps[i] = 0xffffffff) {
         gc->bufferSwaps[i] -          (FxU32) gc->cmdTransportInfo.fifoPtr -
-          (FxU32) gc->cmdTransportInfo.fifoStart; 
+          (long) gc->cmdTransportInfo.fifoPtr -
+          (long) gc->cmdTransportInfo.fifoStart; 
         j = i;
       }
     }
@@ -1222,7 +1222,7 @@
       REG_GROUP_SET_WAX(hw, srcXY, x | ((driInfo.y+(y-driInfo.y))<<16));
       REG_GROUP_SET_WAX(hw, dstSize, (w&0x1FFF)|((h&0x1FFF)<<16));
       REG_GROUP_SET_WAX(hw, dstXY, (x&0x1FFF) | ((y&0x1FFF)<<16));
-      REG_GROUP_SET_WAX(hw, command, (0xCC<<24) | 0x1 | BIT(8));
+      REG_GROUP_SET_WAX(hw, command, (0xCCu<<24) | 0x1 | BIT(8));
       REG_GROUP_END();
     } while (cnt);
 
@@ -1315,7 +1315,7 @@
     do {
       depth0 = GET(gc->cRegs->cmdFifo0.depth);
       depth1 = GET(gc->cRegs->cmdFifo0.depth);
-    } while (readPtr0 != readPtr1);
+    } while (depth0 != depth1);
 
     if (depth0 = 0) {
       for (i = 0; i < MAX_BUFF_PENDING; i++)
@@ -2114,7 +2114,7 @@
            * continuing so that any internal glide calls have a valid
            * gc from tls via GR_DCL_GC. F*ck this up at your own peril.
            */
-          setThreadValue((FxU32)gc);
+          setThreadValue((long)gc);
 #if (GLIDE_PLATFORM & GLIDE_OS_WIN32)
           /* Flush any remaining commands and cleanup any per gc state */
           grSurfaceReleaseContext((GrContext_t)gc);
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gglide.c.dri Glide_V3-DRI-3.10-lia/h3/glide3/src/gglide.c.dri
--- Glide_V3-DRI-3.10/h3/glide3/src/gglide.c.dri	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gglide.c.dri	Wed Aug  9 23:41:48 2000
@@ -1179,8 +1179,8 @@
     for ( i = 0; i < MAX_BUFF_PENDING && j = -1; i++) {
       if (gc->bufferSwaps[i] = 0xffffffff) {
         gc->bufferSwaps[i] -          (FxU32) gc->cmdTransportInfo.fifoPtr -
-          (FxU32) gc->cmdTransportInfo.fifoStart; 
+          (long) gc->cmdTransportInfo.fifoPtr -
+          (long) gc->cmdTransportInfo.fifoStart; 
         j = i;
       }
     }
@@ -1222,7 +1222,7 @@
       REG_GROUP_SET_WAX(hw, srcXY, x | ((driInfo.y+(y-driInfo.y))<<16));
       REG_GROUP_SET_WAX(hw, dstSize, (w&0x1FFF)|((h&0x1FFF)<<16));
       REG_GROUP_SET_WAX(hw, dstXY, (x&0x1FFF) | ((y&0x1FFF)<<16));
-      REG_GROUP_SET_WAX(hw, command, (0xCC<<24) | 0x1 | BIT(8));
+      REG_GROUP_SET_WAX(hw, command, (0xCCu<<24) | 0x1 | BIT(8));
       REG_GROUP_END();
     } while (cnt);
 
@@ -1315,7 +1315,7 @@
     do {
       depth0 = GET(gc->cRegs->cmdFifo0.depth);
       depth1 = GET(gc->cRegs->cmdFifo0.depth);
-    } while (readPtr0 != readPtr1);
+    } while (depth0 != depth1);
 
     if (depth0 = 0) {
       for (i = 0; i < MAX_BUFF_PENDING; i++)
@@ -2114,7 +2114,7 @@
            * continuing so that any internal glide calls have a valid
            * gc from tls via GR_DCL_GC. F*ck this up at your own peril.
            */
-          setThreadValue((FxU32)gc);
+          setThreadValue((long)gc);
 #if (GLIDE_PLATFORM & GLIDE_OS_WIN32)
           /* Flush any remaining commands and cleanup any per gc state */
           grSurfaceReleaseContext((GrContext_t)gc);
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gglide.c.save Glide_V3-DRI-3.10-lia/h3/glide3/src/gglide.c.save
--- Glide_V3-DRI-3.10/h3/glide3/src/gglide.c.save	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gglide.c.save	Wed Aug  9 19:19:07 2000
@@ -1163,7 +1163,7 @@
     do {
       depth0 = GET(gc->cRegs->cmdFifo0.depth);
       depth1 = GET(gc->cRegs->cmdFifo0.depth);
-    } while (readPtr0 != readPtr1);
+    } while (depth0 != depth1);
 
     if (depth0 = 0) {
       for (i = 0; i < MAX_BUFF_PENDING; i++)
@@ -1962,7 +1962,7 @@
            * continuing so that any internal glide calls have a valid
            * gc from tls via GR_DCL_GC. F*ck this up at your own peril.
            */
-          setThreadValue((FxU32)gc);
+          setThreadValue(gc);
 #if (GLIDE_PLATFORM & GLIDE_OS_WIN32)
           /* Flush any remaining commands and cleanup any per gc state */
           grSurfaceReleaseContext((GrContext_t)gc);
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/glfb.c Glide_V3-DRI-3.10-lia/h3/glide3/src/glfb.c
--- Glide_V3-DRI-3.10/h3/glide3/src/glfb.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/glfb.c	Wed Aug  9 23:59:31 2000
@@ -712,7 +712,7 @@
     case GR_LFB_SRC_FMT_ZA16:
       dstData = (FxU32*)(((FxU16*)dstData) + dst_x);
       length  = src_width * 2;
-      aligned = !((int)dstData&0x2);
+      aligned = !((long)dstData&0x2);
       srcJump = src_stride - length;
       dstJump = info.strideInBytes - length;
       if (aligned) {
@@ -917,7 +917,7 @@
     length   = src_width * 2;
     dstJump  = dst_stride - length;
     srcJump  = info.strideInBytes - length;
-    aligned  = !((int)srcData&0x2);
+    aligned  = !((long)srcData&0x2);
     odd      = (src_y+src_height) & 0x1;
     
     if (aligned) {
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/glfb.c.dri Glide_V3-DRI-3.10-lia/h3/glide3/src/glfb.c.dri
--- Glide_V3-DRI-3.10/h3/glide3/src/glfb.c.dri	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/glfb.c.dri	Wed Aug  9 23:59:31 2000
@@ -712,7 +712,7 @@
     case GR_LFB_SRC_FMT_ZA16:
       dstData = (FxU32*)(((FxU16*)dstData) + dst_x);
       length  = src_width * 2;
-      aligned = !((int)dstData&0x2);
+      aligned = !((long)dstData&0x2);
       srcJump = src_stride - length;
       dstJump = info.strideInBytes - length;
       if (aligned) {
@@ -917,7 +917,7 @@
     length   = src_width * 2;
     dstJump  = dst_stride - length;
     srcJump  = info.strideInBytes - length;
-    aligned  = !((int)srcData&0x2);
+    aligned  = !((long)srcData&0x2);
     odd      = (src_y+src_height) & 0x1;
     
     if (aligned) {
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/glide.h Glide_V3-DRI-3.10-lia/h3/glide3/src/glide.h
--- Glide_V3-DRI-3.10/h3/glide3/src/glide.h	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/glide.h	Wed Aug  9 18:33:13 2000
@@ -53,7 +53,7 @@
 typedef FxU8  GrAlpha_t;
 typedef FxU32 GrMipMapId_t;
 typedef FxU8  GrFog_t;
-typedef FxU32 GrContext_t;
+typedef unsigned long GrContext_t;
 typedef int (FX_CALL *GrProc)();
 
 /*
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gpci.c Glide_V3-DRI-3.10-lia/h3/glide3/src/gpci.c
--- Glide_V3-DRI-3.10/h3/glide3/src/gpci.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gpci.c	Wed Aug  9 23:24:03 2000
@@ -418,14 +418,14 @@
   {
     /* Window coords */
     {
-      { _trisetup_null, _trisetup_null },
-      { _trisetup_null, _trisetup_null },
+      { (GrTriSetupProc) _trisetup_null, (GrTriSetupProc) _trisetup_null },
+      { (GrTriSetupProc) _trisetup_null, (GrTriSetupProc) _trisetup_null },
     },
 
     /* Clip coordinates */
     {
-      { _trisetup_null, _trisetup_null },
-      { _trisetup_null, _trisetup_null },
+      { (GrTriSetupProc) _trisetup_null, (GrTriSetupProc) _trisetup_null },
+      { (GrTriSetupProc) _trisetup_null, (GrTriSetupProc) _trisetup_null },
     },
   },
 };
@@ -1024,7 +1024,7 @@
       GR_DCL_GC;
 
       /* If there is no current gc in tls then set the current context. */
-      if (gc = NULL) setThreadValue((FxU32)&_GlideRoot.GCs[_GlideRoot.current_sst]);
+      if (gc = NULL) setThreadValue((long)&_GlideRoot.GCs[_GlideRoot.current_sst]);
     }
     break;
   case DLL_THREAD_DETACH:
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gsst.c Glide_V3-DRI-3.10-lia/h3/glide3/src/gsst.c
--- Glide_V3-DRI-3.10/h3/glide3/src/gsst.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gsst.c	Thu Aug 10 00:13:53 2000
@@ -542,30 +542,30 @@
 
 ResEntry
 _resTable[] = {
-  GR_RESOLUTION_320x200, 320, 200, /* 0x0 */
-  GR_RESOLUTION_320x240, 320,  240, /*   0x1 */
-  GR_RESOLUTION_400x256, 400,  256, /*   0x2 */
-  GR_RESOLUTION_512x384, 512,  384, /*   0x3 */
-  GR_RESOLUTION_640x200, 640,  200, /*   0x4 */
-  GR_RESOLUTION_640x350, 640,  350, /*   0x5 */
-  GR_RESOLUTION_640x400, 640,  400, /*   0x6 */
-  GR_RESOLUTION_640x480, 640,  480, /*   0x7 */
-  GR_RESOLUTION_800x600, 800,  600, /*   0x8 */
-  GR_RESOLUTION_960x720, 960,  720, /*   0x9 */
-  GR_RESOLUTION_856x480, 856,  480, /*   0xa */
-  GR_RESOLUTION_512x256, 512,  256, /*   0xb */
-  GR_RESOLUTION_1024x768, 1024,  768, /*  0xC */
-  GR_RESOLUTION_1280x1024, 1280,  1024, /* 0xD */
-  GR_RESOLUTION_1600x1200, 1600,  1200, /* 0xE */
-  GR_RESOLUTION_400x300, 400,  300, /*   0xF */
-  GR_RESOLUTION_1152x864, 1152,  864, /*  0x10 */
-  GR_RESOLUTION_1280x960, 1280,  960, /*  0x11 */
-  GR_RESOLUTION_1600x1024, 1600,  1024, /* 0x12 */
-  GR_RESOLUTION_1792x1344, 1792,  1344, /* 0x13 */
-  GR_RESOLUTION_1856x1392, 1856,  1392, /* 0x14 */
-  GR_RESOLUTION_1920x1440, 1920,  1440, /* 0x15 */
-  GR_RESOLUTION_2048x1536, 2048,  1536, /* 0x16 */
-  GR_RESOLUTION_2048x2048, 2048,  2048 /* 0x17 */
+  { GR_RESOLUTION_320x200, 320, 200 }, /* 0x0 */
+  { GR_RESOLUTION_320x240, 320,  240 }, /*   0x1 */
+  { GR_RESOLUTION_400x256, 400,  256 }, /*   0x2 */
+  { GR_RESOLUTION_512x384, 512,  384 }, /*   0x3 */
+  { GR_RESOLUTION_640x200, 640,  200 }, /*   0x4 */
+  { GR_RESOLUTION_640x350, 640,  350 }, /*   0x5 */
+  { GR_RESOLUTION_640x400, 640,  400 }, /*   0x6 */
+  { GR_RESOLUTION_640x480, 640,  480 }, /*   0x7 */
+  { GR_RESOLUTION_800x600, 800,  600 }, /*   0x8 */
+  { GR_RESOLUTION_960x720, 960,  720 }, /*   0x9 */
+  { GR_RESOLUTION_856x480, 856,  480 }, /*   0xa */
+  { GR_RESOLUTION_512x256, 512,  256 }, /*   0xb */
+  { GR_RESOLUTION_1024x768, 1024,  768 }, /*  0xC */
+  { GR_RESOLUTION_1280x1024, 1280,  1024 }, /* 0xD */
+  { GR_RESOLUTION_1600x1200, 1600,  1200 }, /* 0xE */
+  { GR_RESOLUTION_400x300, 400,  300 }, /*   0xF */
+  { GR_RESOLUTION_1152x864, 1152,  864 }, /*  0x10 */
+  { GR_RESOLUTION_1280x960, 1280,  960 }, /*  0x11 */
+  { GR_RESOLUTION_1600x1024, 1600,  1024 }, /* 0x12 */
+  { GR_RESOLUTION_1792x1344, 1792,  1344 }, /* 0x13 */
+  { GR_RESOLUTION_1856x1392, 1856,  1392 }, /* 0x14 */
+  { GR_RESOLUTION_1920x1440, 1920,  1440 }, /* 0x15 */
+  { GR_RESOLUTION_2048x1536, 2048,  1536 }, /* 0x16 */
+  { GR_RESOLUTION_2048x2048, 2048,  2048 } /* 0x17 */
 };
 
 /* ---------------------------------------------
@@ -756,8 +756,8 @@
     gc->bufferSwaps[t] = 0xffffffff;
   }
   
-  gc->bufferSwaps[0] = ((FxU32) gc->cmdTransportInfo.fifoPtr -
-                        (FxU32) gc->cmdTransportInfo.fifoStart);
+  gc->bufferSwaps[0] = ((long) gc->cmdTransportInfo.fifoPtr -
+                        (long) gc->cmdTransportInfo.fifoStart);
   
   gc->swapsPending = 1;
   
@@ -946,7 +946,7 @@
    * current gc. This gc is valid for all threads in the fullscreen
    * context.
    */
-  setThreadValue( (FxU32)&_GlideRoot.GCs[_GlideRoot.current_sst] );
+  setThreadValue( (long)&_GlideRoot.GCs[_GlideRoot.current_sst] );
   
   {
     /* Partial Argument Validation */
@@ -1076,12 +1076,12 @@
     for (buffer = 0; buffer < nColBuffers; buffer++) {
       gc->buffers[buffer] = bufInfo->colBuffStart[buffer];
       GDBG_INFO(80, "Buffer %d:  Start: 0x%x\n", buffer, gc->buffers[buffer]);
-      gc->lfbBuffers[buffer] = (FxU32)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
+      gc->lfbBuffers[buffer] = (long)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
     }
     if (nAuxBuffers != 0) {
       gc->buffers[buffer] = bufInfo->auxBuffStart;
       GDBG_INFO(80, "Aux Buffer:  Start: 0x%x\n", gc->buffers[buffer]);
-      gc->lfbBuffers[buffer] = (FxU32)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
+      gc->lfbBuffers[buffer] = (long)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
     }
   
     vInfo->hWnd     = gc->grHwnd;
@@ -1190,7 +1190,7 @@
     gc->tBuffer.bufBPP = 0xffffffff; /* Don't matter to me */
 
     GDBG_INFO(1, "autoBump: 0x%x\n", _GlideRoot.environment.autoBump);
-    if (gc->cmdTransportInfo.autoBump = _GlideRoot.environment.autoBump) {
+    if ((gc->cmdTransportInfo.autoBump = _GlideRoot.environment.autoBump) != 0) {
       if (!hwcInitFifo( bInfo, gc->cmdTransportInfo.autoBump)) {
         hwcRestoreVideo(bInfo);
         GrErrorCallback(hwcGetErrorString(), FXFALSE);
@@ -1226,7 +1226,7 @@
     gc->tmu_state[0].total_mem = gc->tramSize;
 #else
     /* gc->fbOffset               = (FxU32)fxHalFbiGetMemory((SstRegs*)gc->reg_ptr); */
-    gc->fbOffset                  = (FxU32)gc->rawLfb;
+    gc->fbOffset                  = (long)gc->rawLfb;
     gc->tmuMemInfo[0].tramOffset  = 0x200000;
     gc->tmuMemInfo[0].tramSize    = 0x200000;
     gc->tmuMemInfo[1].tramOffset  = gc->tmuMemInfo[0].tramSize + gc->tmuMemInfo[0].tramOffset;
@@ -1440,7 +1440,10 @@
               gcFifo->fifoPtr ); 
 
 #ifdef __linux__
-    _grImportFifo(*driInfo.fifoPtr, *driInfo.fifoRead);
+    {
+      extern void _grImportFifo (int, int);
+      _grImportFifo(*driInfo.fifoPtr, *driInfo.fifoRead);
+    }		
 #endif
     
     /* The hw is now in a usable state from the fifo macros.
@@ -1591,7 +1594,7 @@
    * the tls gc explicitly otherwise other whacky-ness (read 'random
    * crashes' will ensue). 
    */
-  setThreadValue((FxU32)gc);
+  setThreadValue((long) gc);
   if ((gc != NULL) && gc->open) grFlush();
 
   /* Make sure that the user specified gc is not whacked */
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gsst.c.dri Glide_V3-DRI-3.10-lia/h3/glide3/src/gsst.c.dri
--- Glide_V3-DRI-3.10/h3/glide3/src/gsst.c.dri	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gsst.c.dri	Thu Aug 10 00:13:53 2000
@@ -542,30 +542,30 @@
 
 ResEntry
 _resTable[] = {
-  GR_RESOLUTION_320x200, 320, 200, /* 0x0 */
-  GR_RESOLUTION_320x240, 320,  240, /*   0x1 */
-  GR_RESOLUTION_400x256, 400,  256, /*   0x2 */
-  GR_RESOLUTION_512x384, 512,  384, /*   0x3 */
-  GR_RESOLUTION_640x200, 640,  200, /*   0x4 */
-  GR_RESOLUTION_640x350, 640,  350, /*   0x5 */
-  GR_RESOLUTION_640x400, 640,  400, /*   0x6 */
-  GR_RESOLUTION_640x480, 640,  480, /*   0x7 */
-  GR_RESOLUTION_800x600, 800,  600, /*   0x8 */
-  GR_RESOLUTION_960x720, 960,  720, /*   0x9 */
-  GR_RESOLUTION_856x480, 856,  480, /*   0xa */
-  GR_RESOLUTION_512x256, 512,  256, /*   0xb */
-  GR_RESOLUTION_1024x768, 1024,  768, /*  0xC */
-  GR_RESOLUTION_1280x1024, 1280,  1024, /* 0xD */
-  GR_RESOLUTION_1600x1200, 1600,  1200, /* 0xE */
-  GR_RESOLUTION_400x300, 400,  300, /*   0xF */
-  GR_RESOLUTION_1152x864, 1152,  864, /*  0x10 */
-  GR_RESOLUTION_1280x960, 1280,  960, /*  0x11 */
-  GR_RESOLUTION_1600x1024, 1600,  1024, /* 0x12 */
-  GR_RESOLUTION_1792x1344, 1792,  1344, /* 0x13 */
-  GR_RESOLUTION_1856x1392, 1856,  1392, /* 0x14 */
-  GR_RESOLUTION_1920x1440, 1920,  1440, /* 0x15 */
-  GR_RESOLUTION_2048x1536, 2048,  1536, /* 0x16 */
-  GR_RESOLUTION_2048x2048, 2048,  2048 /* 0x17 */
+  { GR_RESOLUTION_320x200, 320, 200 }, /* 0x0 */
+  { GR_RESOLUTION_320x240, 320,  240 }, /*   0x1 */
+  { GR_RESOLUTION_400x256, 400,  256 }, /*   0x2 */
+  { GR_RESOLUTION_512x384, 512,  384 }, /*   0x3 */
+  { GR_RESOLUTION_640x200, 640,  200 }, /*   0x4 */
+  { GR_RESOLUTION_640x350, 640,  350 }, /*   0x5 */
+  { GR_RESOLUTION_640x400, 640,  400 }, /*   0x6 */
+  { GR_RESOLUTION_640x480, 640,  480 }, /*   0x7 */
+  { GR_RESOLUTION_800x600, 800,  600 }, /*   0x8 */
+  { GR_RESOLUTION_960x720, 960,  720 }, /*   0x9 */
+  { GR_RESOLUTION_856x480, 856,  480 }, /*   0xa */
+  { GR_RESOLUTION_512x256, 512,  256 }, /*   0xb */
+  { GR_RESOLUTION_1024x768, 1024,  768 }, /*  0xC */
+  { GR_RESOLUTION_1280x1024, 1280,  1024 }, /* 0xD */
+  { GR_RESOLUTION_1600x1200, 1600,  1200 }, /* 0xE */
+  { GR_RESOLUTION_400x300, 400,  300 }, /*   0xF */
+  { GR_RESOLUTION_1152x864, 1152,  864 }, /*  0x10 */
+  { GR_RESOLUTION_1280x960, 1280,  960 }, /*  0x11 */
+  { GR_RESOLUTION_1600x1024, 1600,  1024 }, /* 0x12 */
+  { GR_RESOLUTION_1792x1344, 1792,  1344 }, /* 0x13 */
+  { GR_RESOLUTION_1856x1392, 1856,  1392 }, /* 0x14 */
+  { GR_RESOLUTION_1920x1440, 1920,  1440 }, /* 0x15 */
+  { GR_RESOLUTION_2048x1536, 2048,  1536 }, /* 0x16 */
+  { GR_RESOLUTION_2048x2048, 2048,  2048 } /* 0x17 */
 };
 
 /* ---------------------------------------------
@@ -756,8 +756,8 @@
     gc->bufferSwaps[t] = 0xffffffff;
   }
   
-  gc->bufferSwaps[0] = ((FxU32) gc->cmdTransportInfo.fifoPtr -
-                        (FxU32) gc->cmdTransportInfo.fifoStart);
+  gc->bufferSwaps[0] = ((long) gc->cmdTransportInfo.fifoPtr -
+                        (long) gc->cmdTransportInfo.fifoStart);
   
   gc->swapsPending = 1;
   
@@ -946,7 +946,7 @@
    * current gc. This gc is valid for all threads in the fullscreen
    * context.
    */
-  setThreadValue( (FxU32)&_GlideRoot.GCs[_GlideRoot.current_sst] );
+  setThreadValue( (long)&_GlideRoot.GCs[_GlideRoot.current_sst] );
   
   {
     /* Partial Argument Validation */
@@ -1076,12 +1076,12 @@
     for (buffer = 0; buffer < nColBuffers; buffer++) {
       gc->buffers[buffer] = bufInfo->colBuffStart[buffer];
       GDBG_INFO(80, "Buffer %d:  Start: 0x%x\n", buffer, gc->buffers[buffer]);
-      gc->lfbBuffers[buffer] = (FxU32)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
+      gc->lfbBuffers[buffer] = (long)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
     }
     if (nAuxBuffers != 0) {
       gc->buffers[buffer] = bufInfo->auxBuffStart;
       GDBG_INFO(80, "Aux Buffer:  Start: 0x%x\n", gc->buffers[buffer]);
-      gc->lfbBuffers[buffer] = (FxU32)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
+      gc->lfbBuffers[buffer] = (long)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
     }
   
     vInfo->hWnd     = gc->grHwnd;
@@ -1190,7 +1190,7 @@
     gc->tBuffer.bufBPP = 0xffffffff; /* Don't matter to me */
 
     GDBG_INFO(1, "autoBump: 0x%x\n", _GlideRoot.environment.autoBump);
-    if (gc->cmdTransportInfo.autoBump = _GlideRoot.environment.autoBump) {
+    if ((gc->cmdTransportInfo.autoBump = _GlideRoot.environment.autoBump) != 0) {
       if (!hwcInitFifo( bInfo, gc->cmdTransportInfo.autoBump)) {
         hwcRestoreVideo(bInfo);
         GrErrorCallback(hwcGetErrorString(), FXFALSE);
@@ -1226,7 +1226,7 @@
     gc->tmu_state[0].total_mem = gc->tramSize;
 #else
     /* gc->fbOffset               = (FxU32)fxHalFbiGetMemory((SstRegs*)gc->reg_ptr); */
-    gc->fbOffset                  = (FxU32)gc->rawLfb;
+    gc->fbOffset                  = (long)gc->rawLfb;
     gc->tmuMemInfo[0].tramOffset  = 0x200000;
     gc->tmuMemInfo[0].tramSize    = 0x200000;
     gc->tmuMemInfo[1].tramOffset  = gc->tmuMemInfo[0].tramSize + gc->tmuMemInfo[0].tramOffset;
@@ -1440,7 +1440,10 @@
               gcFifo->fifoPtr ); 
 
 #ifdef __linux__
-    _grImportFifo(*driInfo.fifoPtr, *driInfo.fifoRead);
+    {
+      extern void _grImportFifo (int, int);
+      _grImportFifo(*driInfo.fifoPtr, *driInfo.fifoRead);
+    }		
 #endif
     
     /* The hw is now in a usable state from the fifo macros.
@@ -1591,7 +1594,7 @@
    * the tls gc explicitly otherwise other whacky-ness (read 'random
    * crashes' will ensue). 
    */
-  setThreadValue((FxU32)gc);
+  setThreadValue((long) gc);
   if ((gc != NULL) && gc->open) grFlush();
 
   /* Make sure that the user specified gc is not whacked */
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gsst.c.save Glide_V3-DRI-3.10-lia/h3/glide3/src/gsst.c.save
--- Glide_V3-DRI-3.10/h3/glide3/src/gsst.c.save	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gsst.c.save	Wed Aug  9 19:50:51 2000
@@ -937,7 +937,7 @@
    * current gc. This gc is valid for all threads in the fullscreen
    * context.
    */
-  setThreadValue( (FxU32)&_GlideRoot.GCs[_GlideRoot.current_sst] );
+  setThreadValue( (long)&_GlideRoot.GCs[_GlideRoot.current_sst] );
   
   {
     /* Partial Argument Validation */
@@ -1056,12 +1056,12 @@
     for (buffer = 0; buffer < nColBuffers; buffer++) {
       gc->buffers[buffer] = bufInfo->colBuffStart[buffer];
       GDBG_INFO(80, "Buffer %d:  Start: 0x%x\n", buffer, gc->buffers[buffer]);
-      gc->lfbBuffers[buffer] = (FxU32)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
+      gc->lfbBuffers[buffer] = (long)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
     }
     if (nAuxBuffers != 0) {
       gc->buffers[buffer] = bufInfo->auxBuffStart;
       GDBG_INFO(80, "Aux Buffer:  Start: 0x%x\n", gc->buffers[buffer]);
-      gc->lfbBuffers[buffer] = (FxU32)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
+      gc->lfbBuffers[buffer] = (long)gc->rawLfb + bufInfo->lfbBuffAddr[buffer];
     }
   
     vInfo->hWnd     = gc->grHwnd;
@@ -1552,7 +1552,7 @@
    * the tls gc explicitly otherwise other whacky-ness (read 'random
    * crashes' will ensue). 
    */
-  setThreadValue((FxU32)gc);
+  setThreadValue((long)gc);
   if ((gc != NULL) && gc->open) grFlush();
 
   /* Make sure that the user specified gc is not whacked */
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gtexdl.c Glide_V3-DRI-3.10-lia/h3/glide3/src/gtexdl.c
--- Glide_V3-DRI-3.10/h3/glide3/src/gtexdl.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gtexdl.c	Thu Aug 10 00:05:56 2000
@@ -417,7 +417,7 @@
         while(i < start + slopCount) {
           FxU32 entry;
           
-          entry = (0x80000000 | ((i & 0xFE) << 23) | pal->data[i] & 0xFFFFFF);
+          entry = (0x80000000 | ((i & 0xFE) << 23) | (pal->data[i] & 0xFFFFFF));
           
           gc->state.shadow.paletteRow[i>>3].data[i&7] = entry;
           REG_GROUP_SET(hw, nccTable0[4 + (i & 0x07)], entry );
@@ -435,7 +435,7 @@
         while(i < endIndex) {
           FxU32 entry;
           
-          entry = (0x80000000 | ((i & 0xFE) << 23) | pal->data[i] & 0xFFFFFF);
+          entry = (0x80000000 | ((i & 0xFE) << 23) | (pal->data[i] & 0xFFFFFF));
           
           gc->state.shadow.paletteRow[i>>3].data[i&7] = entry;
           REG_GROUP_SET(hw, nccTable0[4 + (i & 0x07)], entry );
@@ -454,7 +454,7 @@
         while(i <= end) {
           FxU32 entry;
           
-          entry = (0x80000000 | ((i & 0xFE) << 23) | pal->data[i] & 0xFFFFFF);
+          entry = (0x80000000 | ((i & 0xFE) << 23) | (pal->data[i] & 0xFFFFFF));
           
           gc->state.shadow.paletteRow[i>>3].data[i&7] = entry;
           REG_GROUP_SET(hw, nccTable0[4 + (i & 0x07)], entry );
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/gthread.c Glide_V3-DRI-3.10-lia/h3/glide3/src/gthread.c
--- Glide_V3-DRI-3.10/h3/glide3/src/gthread.c	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/gthread.c	Wed Aug  9 15:02:18 2000
@@ -63,13 +63,13 @@
 
 } /* initThreadStorage */
 
-void setThreadValue( FxU32 value ) {
+void setThreadValue( long value ) {
     GR_CHECK_F( "setThreadValue", !threadInit, "Thread storage not initialized\n" );
     TlsSetValue( _GlideRoot.tlsIndex, (void*)value );
 }
 
 #pragma warning (4:4035)        /* No return value */
-FxU32 getThreadValueSLOW( void ) {
+long getThreadValueSLOW( void ) {
     GR_CHECK_F( "getThreadValue", !threadInit, "Thread storage not initialized\n" );
 
 #if 0
@@ -122,7 +122,7 @@
 {
 }
 
-void setThreadValue( FxU32 value )
+void setThreadValue( long value )
 {
 	_threadValueMacOS = value;
 }
@@ -157,18 +157,18 @@
 #include "fxglide.h"
 #include "fxcmd.h"
 
-FxU32 threadValueLinux;
+long threadValueLinux;
 
 void initThreadStorage(void)
 {
 }
 
-void setThreadValue( FxU32 value )
+void setThreadValue( long value )
 {
 	threadValueLinux = value;
 }
 
-FxU32 getThreadValueSLOW( void )
+long getThreadValueSLOW( void )
 {
 	return threadValueLinux;
 }
diff -urN Glide_V3-DRI-3.10/h3/glide3/src/makefile.linux Glide_V3-DRI-3.10-lia/h3/glide3/src/makefile.linux
--- Glide_V3-DRI-3.10/h3/glide3/src/makefile.linux	Thu Mar  2 14:53:42 2000
+++ Glide_V3-DRI-3.10-lia/h3/glide3/src/makefile.linux	Wed Aug  9 13:34:45 2000
@@ -43,7 +43,7 @@
 
 FX_GLIDE_REAL_HW=       1
 FX_GLIDE_NO_FIFO=       1
-FX_GLIDE_CTRISETUP =    0
+FX_GLIDE_CTRISETUP =    1
 
 HWSPEC          =       fifo.c
 LCDEFS          +=      -DH3 $(CMDXPORTDEFS)
diff -urN Glide_V3-DRI-3.10/h3/glide3/tests/.gdbinit Glide_V3-DRI-3.10-lia/h3/glide3/tests/.gdbinit
--- Glide_V3-DRI-3.10/h3/glide3/tests/.gdbinit	Wed Dec 31 16:00:00 1969
+++ Glide_V3-DRI-3.10-lia/h3/glide3/tests/.gdbinit	Wed Aug  9 15:46:12 2000
@@ -0,0 +1,3 @@
+dir /r/erikson/usr/src/redhat/BUILD/Glide_V3-DRI-3.10/h3/glide3/src:/r/erikson/usr/src/redhat/BUILD/Glide_V3-DRI-3.10/h3/minihwc:/r/erikson/usr/src/redhat/BUILD/XFree86-4.0/xc/lib/Xxf86vm
+set gdbg_debuglevel[80]%5
+set gdbg_debuglevel[280]%5
diff -urN Glide_V3-DRI-3.10/h3/incsrc/gdebug.h Glide_V3-DRI-3.10-lia/h3/incsrc/gdebug.h
--- Glide_V3-DRI-3.10/h3/incsrc/gdebug.h	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/incsrc/gdebug.h	Wed Aug  9 23:08:21 2000
@@ -67,12 +67,21 @@
 #pragma disable_message (111, 201, 302)
 #endif /* defined(__WATCOMC__) || defined(__WATCOM_CPLUSPLUS__) */
 
-#define GDBG_INFO      0 && (unsigned long)
-#define GDBG_INFO_MORE 0 && (unsigned long)
-#define GDBG_PRINTF    0 && (unsigned long)
+#ifdef __GNUC__
+# define GDBG_INFO(x...)
+# define GDBG_INFO_MORE(x...)
+# define GDBG_PRINTF(x...)
 
-#define GDBG_ERROR_SET_CALLBACK   0 && (unsigned long)
-#define GDBG_ERROR_CLEAR_CALLBACK 0 && (unsigned long)
+# define GDBG_ERROR_SET_CALLBACK(x...)
+# define GDBG_ERROR_CLEAR_CALLBACK(x...)
+#else
+# define GDBG_INFO      0 && (unsigned long)
+# define GDBG_INFO_MORE 0 && (unsigned long)
+# define GDBG_PRINTF    0 && (unsigned long)
+
+# define GDBG_ERROR_SET_CALLBACK   0 && (unsigned long)
+# define GDBG_ERROR_CLEAR_CALLBACK 0 && (unsigned long)
+#endif
 
 #define GDBG_GET_DEBUGLEVEL(x) 0
 #define GDBG_SET_DEBUGLEVEL(a,b)
diff -urN Glide_V3-DRI-3.10/h3/incsrc/h3defs.h Glide_V3-DRI-3.10-lia/h3/incsrc/h3defs.h
--- Glide_V3-DRI-3.10/h3/incsrc/h3defs.h	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/incsrc/h3defs.h	Thu Aug 10 00:02:29 2000
@@ -56,11 +56,21 @@
 
 // this crazy macro tests the sign bit of a float by loading it into
 // an integer register and then testing the sign bit of the integer
-#define FLOAT_ISNEG(f) ((*(int *)(&(f))) < 0)
+#ifdef __ia64__
+  /* On IA-64, it's faster to do this the obvious way... --davidm 00/08/09 */
+# define FLOAT_ISNEG(f)	((f) < 0.0)
+#else
+# define FLOAT_ISNEG(f) ((*(int *)(&(f))) < 0)
+#endif
 
 // these crazy macros returns the sign of a number (1 if >= 0; -1 if < 0)
-#define ISIGN(x) (((x) | 0x40000000L) >> 30)
-#define FSIGN(f) ISIGN(*(long *)&f)
+#ifdef __ia64__
+# define ISIGN(x) ((x) >= 0 ? 1 : -1)
+# define FSIGN(f) ((f) >= 0.0 ? 1 : -1)
+#else
+# define ISIGN(x) (((x) | 0x40000000L) >> 30)
+# define FSIGN(f) ISIGN(*(long *)&f)
+#endif
 
 #define BIT(n)  (1UL<<(n))
 #define SST_MASK(n) (0xFFFFFFFFL >> (32-(n)))
@@ -1257,9 +1267,9 @@
 
 //----------------- useful addressing macros -----------------------
 // return pointer to SST at specified WRAP, CHIP, or TREX
-#define SST_WRAP(sst,n) ((SstRegs *)((n)*0x4000+(FxI32)(sst)))
-#define SST_CHIP(sst,n) ((SstRegs *)((n)*0x400+(FxI32)(sst)))
-#define SST_TMU(sst,n)  ((SstRegs *)((0x800<<(n))+(FxI32)(sst)))
+#define SST_WRAP(sst,n) ((SstRegs *)((n)*0x4000+(long)(sst)))
+#define SST_CHIP(sst,n) ((SstRegs *)((n)*0x400+(long)(sst)))
+#define SST_TMU(sst,n)  ((SstRegs *)((0x800<<(n))+(long)(sst)))
 #define SST_TREX(sst,n) SST_TMU(sst,n)
 
 // offsets from the base of memBaseAddr0
@@ -1304,7 +1314,7 @@
 
 #define SST_IS_REGISTER_ADDR(a)  ( (a) >= SST_IO_OFFSET       && (a) < SST_TEX_OFFSET )
 
-#define SST_BASE_ADDRESS(sst)   ((FxI32)(sst)-SST_3D_OFFSET)
+#define SST_BASE_ADDRESS(sst)   ((long)(sst)-SST_3D_OFFSET)
 #define SST_IO_ADDRESS(sst)     (SST_IO_OFFSET+SST_BASE_ADDRESS(sst))
 #define SST_CMDAGP_ADDRESS(sst) (SST_CMDAGP_OFFSET+SST_BASE_ADDRESS(sst))
 #define SST_GUI_ADDRESS(sst)    (SST_2D_OFFSET+SST_BASE_ADDRESS(sst))
diff -urN Glide_V3-DRI-3.10/h3/incsrc/h3info.h Glide_V3-DRI-3.10-lia/h3/incsrc/h3info.h
--- Glide_V3-DRI-3.10/h3/incsrc/h3info.h	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/incsrc/h3info.h	Wed Aug  9 14:15:09 2000
@@ -28,7 +28,11 @@
 // basic data types
 #define FxU8  unsigned char
 #define FxU16 unsigned short
-#define FxU32 unsigned long
+# ifdef __LP64__
+#  define FxU32 unsigned int
+# else
+#  define FxU32 unsigned long
+# endif
 #define FxBool int
 // defn of registers not reqd, treat (SstRegs *) as (void *)
 typedef void SstRegs;
diff -urN Glide_V3-DRI-3.10/h3/incsrc/h3regs.h Glide_V3-DRI-3.10-lia/h3/incsrc/h3regs.h
--- Glide_V3-DRI-3.10/h3/incsrc/h3regs.h	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/incsrc/h3regs.h	Wed Aug  9 18:21:11 2000
@@ -45,7 +45,11 @@
 // STB Begin Changes
 // STB-SR 1/13/98 Adding code for bj
 #ifdef _H2INC
+# ifdef __LP64__
+typedef unsigned int   FxU32;
+# else
 typedef unsigned long   FxU32;
+# endif
 #endif
 // STB End Changes
 
@@ -211,8 +215,8 @@
 //----------------- SST chip 3D layout -------------------------
 // registers are in groups of 8 for easy decode
 typedef struct vertex_Rec {
-    unsigned long x;            // 12.4 format
-    unsigned long y;            // 12.4
+    FxU32 x;            // 12.4 format
+    FxU32 y;            // 12.4
 } vtxRec;
 
 typedef volatile struct sstregs {       // THE 3D CHIP
@@ -223,118 +227,118 @@
     vtxRec vB;
     vtxRec vC;
 
-    long r;             // 12.12        Parameters
-    long g;             // 12.12
-    long b;             // 12.12
-    long z;             // 20.12
-    long a;             // 12.12
-    long s;             // 14.18
-    long t;             // 14.18
-    long w;             //  2.30
-
-    long drdx;                  // X Gradients
-    long dgdx;
-    long dbdx;
-    long dzdx;
-    long dadx;
-    long dsdx;
-    long dtdx;
-    long dwdx;
-
-    long drdy;                  // Y Gradients
-    long dgdy;
-    long dbdy;
-    long dzdy;
-    long dady;
-    long dsdy;
-    long dtdy;
-    long dwdy;
+    FxI32 r;             // 12.12        Parameters
+    FxI32 g;             // 12.12
+    FxI32 b;             // 12.12
+    FxI32 z;             // 20.12
+    FxI32 a;             // 12.12
+    FxI32 s;             // 14.18
+    FxI32 t;             // 14.18
+    FxI32 w;             //  2.30
+
+    FxI32 drdx;                  // X Gradients
+    FxI32 dgdx;
+    FxI32 dbdx;
+    FxI32 dzdx;
+    FxI32 dadx;
+    FxI32 dsdx;
+    FxI32 dtdx;
+    FxI32 dwdx;
+
+    FxI32 drdy;                  // Y Gradients
+    FxI32 dgdy;
+    FxI32 dbdy;
+    FxI32 dzdy;
+    FxI32 dady;
+    FxI32 dsdy;
+    FxI32 dtdy;
+    FxI32 dwdy;
 
-    unsigned long triangleCMD;  // execute a triangle command (float)
-    unsigned long reservedA;
+    FxU32 triangleCMD;  // execute a triangle command (float)
+    FxU32 reservedA;
     vtxRec FvA;                 // floating point version
     vtxRec FvB;
     vtxRec FvC;
 
-    long Fr;                    // floating point version
-    long Fg;
-    long Fb;
-    long Fz;
-    long Fa;
-    long Fs;
-    long Ft;
-    long Fw;
-
-    long Fdrdx;
-    long Fdgdx;
-    long Fdbdx;
-    long Fdzdx;
-    long Fdadx;
-    long Fdsdx;
-    long Fdtdx;
-    long Fdwdx;
-
-    long Fdrdy;
-    long Fdgdy;
-    long Fdbdy;
-    long Fdzdy;
-    long Fdady;
-    long Fdsdy;
-    long Fdtdy;
-    long Fdwdy;
-
-    unsigned long FtriangleCMD;         // execute a triangle command
-    unsigned long fbzColorPath;         // color select and combine
-    unsigned long fogMode;              // fog Mode
-    unsigned long alphaMode;            // alpha Mode
-    unsigned long fbzMode;              // framebuffer and Z mode
-    unsigned long lfbMode;              // linear framebuffer Mode
-    unsigned long clipLeftRight;        // (6)10(6)10
-    unsigned long clipBottomTop;        // (6)10(6)10
-
-    unsigned long nopCMD;       // execute a nop command
-    unsigned long fastfillCMD;  // execute a fast fill command
-    unsigned long swapbufferCMD;// execute a swapbuffer command
-    unsigned long fogColor;             // (8)888
-    unsigned long zaColor;              // 8(8)16
-    unsigned long chromaKey;            // (8)888
-    unsigned long chromaRange;
-    unsigned long userIntrCmd;
-
-    unsigned long stipple;              // 32 bits, MSB masks pixels
-    unsigned long c0;                   // 8.8.8.8 (ARGB)
-    unsigned long c1;                   // 8.8.8.8 (ARGB)
+    FxI32 Fr;                    // floating point version
+    FxI32 Fg;
+    FxI32 Fb;
+    FxI32 Fz;
+    FxI32 Fa;
+    FxI32 Fs;
+    FxI32 Ft;
+    FxI32 Fw;
+
+    FxI32 Fdrdx;
+    FxI32 Fdgdx;
+    FxI32 Fdbdx;
+    FxI32 Fdzdx;
+    FxI32 Fdadx;
+    FxI32 Fdsdx;
+    FxI32 Fdtdx;
+    FxI32 Fdwdx;
+
+    FxI32 Fdrdy;
+    FxI32 Fdgdy;
+    FxI32 Fdbdy;
+    FxI32 Fdzdy;
+    FxI32 Fdady;
+    FxI32 Fdsdy;
+    FxI32 Fdtdy;
+    FxI32 Fdwdy;
+
+    FxU32 FtriangleCMD;         // execute a triangle command
+    FxU32 fbzColorPath;         // color select and combine
+    FxU32 fogMode;              // fog Mode
+    FxU32 alphaMode;            // alpha Mode
+    FxU32 fbzMode;              // framebuffer and Z mode
+    FxU32 lfbMode;              // linear framebuffer Mode
+    FxU32 clipLeftRight;        // (6)10(6)10
+    FxU32 clipBottomTop;        // (6)10(6)10
+
+    FxU32 nopCMD;       // execute a nop command
+    FxU32 fastfillCMD;  // execute a fast fill command
+    FxU32 swapbufferCMD;// execute a swapbuffer command
+    FxU32 fogColor;             // (8)888
+    FxU32 zaColor;              // 8(8)16
+    FxU32 chromaKey;            // (8)888
+    FxU32 chromaRange;
+    FxU32 userIntrCmd;
+
+    FxU32 stipple;              // 32 bits, MSB masks pixels
+    FxU32 c0;                   // 8.8.8.8 (ARGB)
+    FxU32 c1;                   // 8.8.8.8 (ARGB)
     struct {                            // statistic gathering variables
-        unsigned long fbiPixelsIn;
-        unsigned long fbiChromaFail;
-        unsigned long fbiZfuncFail;
-        unsigned long fbiAfuncFail;
-        unsigned long fbiPixelsOut;
+        FxU32 fbiPixelsIn;
+        FxU32 fbiChromaFail;
+        FxU32 fbiZfuncFail;
+        FxU32 fbiAfuncFail;
+        FxU32 fbiPixelsOut;
     } stats;
 
-    unsigned long fogTable[32];         // 64 entries, 2 per word, 2 bytes each
+    FxU32 fogTable[32];         // 64 entries, 2 per word, 2 bytes each
 
-    unsigned long reservedB[3];
+    FxU32 reservedB[3];
 
-    unsigned long colBufferAddr;
-    unsigned long colBufferStride;
-    unsigned long auxBufferAddr;
-    unsigned long auxBufferStride;
-    unsigned long reservedC;
-
-    unsigned long clipLeftRight1;
-    unsigned long clipBottomTop1;
-    unsigned long reservedD[6];         // NOTE: used to store TMUprivate ptr
+    FxU32 colBufferAddr;
+    FxU32 colBufferStride;
+    FxU32 auxBufferAddr;
+    FxU32 auxBufferStride;
+    FxU32 reservedC;
+
+    FxU32 clipLeftRight1;
+    FxU32 clipBottomTop1;
+    FxU32 reservedD[6];         // NOTE: used to store TMUprivate ptr
                                         
 
-    unsigned long reservedE[8];
+    FxU32 reservedE[8];
 
-    unsigned long reservedF[3];  
-    unsigned long swapBufferPend;
-    unsigned long leftOverlayBuf;
-    unsigned long rightOverlayBuf;
-    unsigned long fbiSwapHistory;
-    unsigned long fbiTrianglesOut;      // triangles out counter
+    FxU32 reservedF[3];  
+    FxU32 swapBufferPend;
+    FxU32 leftOverlayBuf;
+    FxU32 rightOverlayBuf;
+    FxU32 fbiSwapHistory;
+    FxU32 fbiTrianglesOut;      // triangles out counter
 
     FxU32 sSetupMode;
     FxU32 sVx;
@@ -356,27 +360,27 @@
 
     FxU32 sDrawTriCMD;
     FxU32 sBeginTriCMD;
-    unsigned long reservedG[6];
+    FxU32 reservedG[6];
 
-    unsigned long reservedH[8];
+    FxU32 reservedH[8];
 
-    unsigned long reservedI[8];
+    FxU32 reservedI[8];
 
-    unsigned long textureMode;          // texture Mode
-    unsigned long tLOD;                 // texture LOD settings
-    unsigned long tDetail;              // texture detail settings
-    unsigned long texBaseAddr;          // current texture base address
-    unsigned long texBaseAddr1;
-    unsigned long texBaseAddr2;
-    unsigned long texBaseAddr38;
-    unsigned long trexInit0;            // hardware init bits
-    unsigned long trexInit1;            // hardware init bits
+    FxU32 textureMode;          // texture Mode
+    FxU32 tLOD;                 // texture LOD settings
+    FxU32 tDetail;              // texture detail settings
+    FxU32 texBaseAddr;          // current texture base address
+    FxU32 texBaseAddr1;
+    FxU32 texBaseAddr2;
+    FxU32 texBaseAddr38;
+    FxU32 trexInit0;            // hardware init bits
+    FxU32 trexInit1;            // hardware init bits
    
-    unsigned long nccTable0[12];        // NCC decode tables, bits are packed
-    unsigned long nccTable1[12];        // 4 words Y, 4 words I, 4 words Q
+    FxU32 nccTable0[12];        // NCC decode tables, bits are packed
+    FxU32 nccTable1[12];        // 4 words Y, 4 words I, 4 words Q
 
-    unsigned long tChromaKeyMin;
-    unsigned long tChromaKeyMax;
+    FxU32 tChromaKeyMin;
+    FxU32 tChromaKeyMax;
 } SstRegs;
 
 // STB Begin changes
diff -urN Glide_V3-DRI-3.10/h3/minihwc/hwcext.h Glide_V3-DRI-3.10-lia/h3/minihwc/hwcext.h
--- Glide_V3-DRI-3.10/h3/minihwc/hwcext.h	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/minihwc/hwcext.h	Wed Aug  9 14:36:16 2000
@@ -192,9 +192,8 @@
 
 /* Returned from HWCEXT_GETLINEARADDR */
 typedef struct hwcExtLinearAddrRes_s {
-  FxU32
-    numBaseAddrs,               /* # base addresses */
-    baseAddresses[HWCEXT_MAX_BASEADDR]; /* linear Addresses  */
+  FxU32 numBaseAddrs;               /* # base addresses */
+  long baseAddresses[HWCEXT_MAX_BASEADDR]; /* linear Addresses  */
 } hwcExtLinearAddrRes_t;
 
 /*
diff -urN Glide_V3-DRI-3.10/h3/minihwc/linhwc.c Glide_V3-DRI-3.10-lia/h3/minihwc/linhwc.c
--- Glide_V3-DRI-3.10/h3/minihwc/linhwc.c	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/minihwc/linhwc.c	Thu Aug 10 00:11:46 2000
@@ -67,7 +67,11 @@
 #include "lindri.h"
 
 static FxU32 fenceVar;
-#define P6FENCE asm("xchg %%eax, %0" : : "m" (fenceVar) : "eax");
+#ifdef __ia64__
+# define P6FENCE asm volatile("mf.a" ::: "memory");
+#else
+# define P6FENCE asm("xchg %%eax, %0" : : "m" (fenceVar) : "eax");
+#endif
 
 #define MAXFIFOSIZE     0x40000
 #define FIFOPAD         0x0000
@@ -144,7 +148,7 @@
   char data[128];
   char *env, *val;
   envitem *item;
-  int first=1;
+  int is_first=1;
 
   if (envinit) return;
   envinit=1;
@@ -156,9 +160,9 @@
     if (*data='\n') continue;
     val=strchr(data, '=');
     if (!val) {
-      if (first) {
+      if (is_first) {
 	fprintf(stderr, "In config file /etc/conf.3dfx/voodoo3:\n");
-	first=0;
+	is_first=0;
       }
       fprintf(stderr, "Malformed line: %s\n", data);
       continue;
@@ -231,8 +235,8 @@
   }
 
   bInfo->linearInfo.initialized = FXTRUE;
-  bInfo->linearInfo.linearAddress[0]=(FxU32)driInfo.pRegs;
-  bInfo->linearInfo.linearAddress[1]=(FxU32)driInfo.pFB;
+  bInfo->linearInfo.linearAddress[0]=(long)driInfo.pRegs;
+  bInfo->linearInfo.linearAddress[1]=(long)driInfo.pFB;
   return FXTRUE;
 }
 
@@ -745,6 +749,10 @@
 #undef FN_NAME
 } /* hwcResolutionSupported */
 
+extern void _grImportFifo (int, int);
+extern void _grInvalidateAll (void);
+extern void _grExportFifo (int *, int *);
+
 void grDRIImportFifo(int fifoPtr, int fifoRead)
 {
   _grImportFifo(fifoPtr, fifoRead);
@@ -756,5 +764,5 @@
 
 void grDRIResetSAREA()
 {
-  _grExportFifo(driInfo.fifoPtr, driInfo.fifoRead);
+  _grExportFifo((int *) driInfo.fifoPtr, (int *) driInfo.fifoRead);
 }
diff -urN Glide_V3-DRI-3.10/h3/minihwc/linhwc.c.dri Glide_V3-DRI-3.10-lia/h3/minihwc/linhwc.c.dri
--- Glide_V3-DRI-3.10/h3/minihwc/linhwc.c.dri	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/minihwc/linhwc.c.dri	Thu Aug 10 00:11:46 2000
@@ -67,7 +67,11 @@
 #include "lindri.h"
 
 static FxU32 fenceVar;
-#define P6FENCE asm("xchg %%eax, %0" : : "m" (fenceVar) : "eax");
+#ifdef __ia64__
+# define P6FENCE asm volatile("mf.a" ::: "memory");
+#else
+# define P6FENCE asm("xchg %%eax, %0" : : "m" (fenceVar) : "eax");
+#endif
 
 #define MAXFIFOSIZE     0x40000
 #define FIFOPAD         0x0000
@@ -144,7 +148,7 @@
   char data[128];
   char *env, *val;
   envitem *item;
-  int first=1;
+  int is_first=1;
 
   if (envinit) return;
   envinit=1;
@@ -156,9 +160,9 @@
     if (*data='\n') continue;
     val=strchr(data, '=');
     if (!val) {
-      if (first) {
+      if (is_first) {
 	fprintf(stderr, "In config file /etc/conf.3dfx/voodoo3:\n");
-	first=0;
+	is_first=0;
       }
       fprintf(stderr, "Malformed line: %s\n", data);
       continue;
@@ -231,8 +235,8 @@
   }
 
   bInfo->linearInfo.initialized = FXTRUE;
-  bInfo->linearInfo.linearAddress[0]=(FxU32)driInfo.pRegs;
-  bInfo->linearInfo.linearAddress[1]=(FxU32)driInfo.pFB;
+  bInfo->linearInfo.linearAddress[0]=(long)driInfo.pRegs;
+  bInfo->linearInfo.linearAddress[1]=(long)driInfo.pFB;
   return FXTRUE;
 }
 
@@ -745,6 +749,10 @@
 #undef FN_NAME
 } /* hwcResolutionSupported */
 
+extern void _grImportFifo (int, int);
+extern void _grInvalidateAll (void);
+extern void _grExportFifo (int *, int *);
+
 void grDRIImportFifo(int fifoPtr, int fifoRead)
 {
   _grImportFifo(fifoPtr, fifoRead);
@@ -756,5 +764,5 @@
 
 void grDRIResetSAREA()
 {
-  _grExportFifo(driInfo.fifoPtr, driInfo.fifoRead);
+  _grExportFifo((int *) driInfo.fifoPtr, (int *) driInfo.fifoRead);
 }
diff -urN Glide_V3-DRI-3.10/h3/minihwc/linhwc.c.save Glide_V3-DRI-3.10-lia/h3/minihwc/linhwc.c.save
--- Glide_V3-DRI-3.10/h3/minihwc/linhwc.c.save	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/minihwc/linhwc.c.save	Wed Aug  9 15:19:27 2000
@@ -64,7 +64,11 @@
 #include <X11/extensions/xf86vmode.h>
 
 static FxU32 fenceVar;
-#define P6FENCE asm("xchg %%eax, %0" : : "m" (fenceVar) : "eax");
+#ifdef __ia64__
+# define P6FENCE asm volatile ("mf.a" ::: "memory");
+#else
+# define P6FENCE asm("xchg %%eax, %0" : : "m" (fenceVar) : "eax");
+#endif
 
 #define MAXFIFOSIZE     0x40000
 #define MAXFIFOSIZE_16MB   0xff000
@@ -114,7 +118,7 @@
   char data[128];
   char *env, *val;
   envitem *item;
-  int first=1;
+  int is_first=1;
 
   if (envinit) return;
   envinit=1;
@@ -126,9 +130,9 @@
     if (*data='\n') continue;
     val=strchr(data, '=');
     if (!val) {
-      if (first) {
+      if (is_first) {
 	fprintf(stderr, "In config file /etc/conf.3dfx/voodoo3:\n");
-	first=0;
+	is_first=0;
       }
       fprintf(stderr, "Malformed line: %s\n", data);
       continue;
@@ -269,7 +273,7 @@
 
   for (bAddr = 0; bAddr < HWC_NUM_BASE_ADDR; bAddr++) {
     if ((bAddrMask >> bAddr) & 0x1) {
-      bInfo->linearInfo.linearAddress[bAddr] = (FxU32) 
+      bInfo->linearInfo.linearAddress[bAddr] = (long)
 	pciMapCardMulti(bInfo->pciInfo.vendorID, bInfo->pciInfo.deviceID,
 			0x2000000, &bInfo->deviceNum, bInfo->boardNum, bAddr);
     }
diff -urN Glide_V3-DRI-3.10/h3/minihwc/minihwc.c Glide_V3-DRI-3.10-lia/h3/minihwc/minihwc.c
--- Glide_V3-DRI-3.10/h3/minihwc/minihwc.c	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/minihwc/minihwc.c	Wed Aug  9 14:28:40 2000
@@ -1078,7 +1078,7 @@
     for (bAddr = 0; bAddr < 2; bAddr++) {
       if ((bAddrMask & (0x01UL << bAddr)) != 0x00UL) {
         bInfo->linearInfo.linearAddress[bAddr] = 
-          (FxU32)pciMapCardMulti(bInfo->pciInfo.vendorID, bInfo->pciInfo.deviceID,
+          pciMapCardMulti(bInfo->pciInfo.vendorID, bInfo->pciInfo.deviceID,
                                  0x1000000, &bInfo->deviceNum, bInfo->boardNum, bAddr);
       }
     }
@@ -1087,13 +1087,13 @@
      * unconditionally
      */
     bInfo->linearInfo.linearAddress[2] = 
-      (FxU32)pciMapCardMulti(bInfo->pciInfo.vendorID, bInfo->pciInfo.deviceID,
+      pciMapCardMulti(bInfo->pciInfo.vendorID, bInfo->pciInfo.deviceID,
                              0x1000000, &bInfo->deviceNum, bInfo->boardNum, 2);
 
     /* Does the caller want the rom bios? */
     if ((bAddrMask & 0x08UL) != 0x00UL) {
       bInfo->linearInfo.linearAddress[3] = 
-        (FxU32)pciMapCardMulti(bInfo->pciInfo.vendorID, bInfo->pciInfo.deviceID,
+        pciMapCardMulti(bInfo->pciInfo.vendorID, bInfo->pciInfo.deviceID,
                                0x1000000, &bInfo->deviceNum, bInfo->boardNum, 3);
     }
   }
diff -urN Glide_V3-DRI-3.10/h3/minihwc/minihwc.h Glide_V3-DRI-3.10-lia/h3/minihwc/minihwc.h
--- Glide_V3-DRI-3.10/h3/minihwc/minihwc.h	Thu Mar  2 14:53:43 2000
+++ Glide_V3-DRI-3.10-lia/h3/minihwc/minihwc.h	Wed Aug  9 14:36:53 2000
@@ -238,22 +238,21 @@
 typedef struct hwcLinearInfo_s {
   FxBool
     initialized;
-  FxU32
-    linearAddress[HWC_NUM_BASE_ADDR];
+  long linearAddress[HWC_NUM_BASE_ADDR];
 } hwcLinearInfo;
 
 typedef struct hwcRegInfo_s {
   FxBool
     initialized;
-  volatile FxU32
-    ioMemBase,                  /* mem base for I/O aliases */
-    cmdAGPBase,                 /* CMD/AGP register base */
-    waxBase,                    /* 2D register base */
-    sstBase,                    /* 3D register base */
-    lfbBase,                    /* 3D lfb base */
-    rawLfbBase;                 /* Raw LFB base (base address 1) */
+  volatile long
+    ioMemBase,                 /* mem base for I/O aliases */
+    cmdAGPBase,                /* CMD/AGP register base */
+    waxBase,                   /* 2D register base */
+    sstBase,                   /* 3D register base */
+    lfbBase,                   /* 3D lfb base */
+    rawLfbBase;                /* Raw LFB base (base address 1) */
 #if __POWERPC__
-  ioPortBase;                   /* PPC does I/O via a 32-bit address */
+  FxU32 ioPortBase;             /* PPC does I/O via a 32-bit address */
 #else       
   volatile FxU16
     ioPortBase,                 /* I/O base address */
diff -urN Glide_V3-DRI-3.10/set-for-dri Glide_V3-DRI-3.10-lia/set-for-dri
--- Glide_V3-DRI-3.10/set-for-dri	Wed Dec 31 16:00:00 1969
+++ Glide_V3-DRI-3.10-lia/set-for-dri	Wed Aug  9 20:25:38 2000
@@ -0,0 +1,7 @@
+for n in ./h3/glide3/src/gglide.c ./h3/glide3/src/glfb.c ./h3/glide3/src/gsst.c ./h3/minihwc/linhwc.c
+do
+	rn=$(basename $n).dri
+	echo ln -sf $rn $n
+	ln -sf $rn $n
+done
+
diff -urN Glide_V3-DRI-3.10/set-for-standalone Glide_V3-DRI-3.10-lia/set-for-standalone
--- Glide_V3-DRI-3.10/set-for-standalone	Wed Dec 31 16:00:00 1969
+++ Glide_V3-DRI-3.10-lia/set-for-standalone	Wed Aug  9 20:25:33 2000
@@ -0,0 +1,7 @@
+for n in ./h3/glide3/src/gglide.c ./h3/glide3/src/glfb.c ./h3/glide3/src/gsst.c ./h3/minihwc/linhwc.c
+do
+	rn=$(basename $n).save
+	echo ln -sf $rn $n
+	ln -sf $rn $n
+done
+
diff -urN Glide_V3-DRI-3.10/swlibs/fxmisc/3dfx.h Glide_V3-DRI-3.10-lia/swlibs/fxmisc/3dfx.h
--- Glide_V3-DRI-3.10/swlibs/fxmisc/3dfx.h	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/fxmisc/3dfx.h	Wed Aug  9 14:10:27 2000
@@ -30,8 +30,13 @@
 typedef signed   char   FxI8;
 typedef unsigned short  FxU16;
 typedef signed   short  FxI16;
+#ifdef __LP64__
+typedef signed   int    FxI32;
+typedef unsigned int    FxU32;
+#else
 typedef signed   long   FxI32;
 typedef unsigned long   FxU32;
+#endif
 typedef int             FxBool;
 typedef float           FxFloat;
 typedef double          FxDouble;
diff -urN Glide_V3-DRI-3.10/swlibs/fxmisc/fximg.c Glide_V3-DRI-3.10-lia/swlibs/fxmisc/fximg.c
--- Glide_V3-DRI-3.10/swlibs/fxmisc/fximg.c	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/fxmisc/fximg.c	Wed Aug  9 22:54:08 2000
@@ -197,7 +197,7 @@
       	case 0xDA01:
 			*type = IMG_RGT;
 			break;
-      	case 'EL':
+      	case (('E'<<8) | 'L'):
 	  cookie = 0;
 	  if ( ( c = fgetc( stream ) ) = EOF )
 	    {
@@ -211,7 +211,7 @@
 	      return FXFALSE;
 	    }
 	  cookie = (cookie << 8) | c;
-	  if (cookie = 'RS')
+	  if (cookie = (('R'<<8)|'S'))
 	    *type = IMG_SRLE;
 	  break;
       	default: // Might Be TGA
@@ -1470,7 +1470,7 @@
 {
 	imgErrorString = "Image write error.";
 	if ( 0 > fprintf( stream, "P6\n" ) ) return FXFALSE;
-	if ( 0 > fprintf( stream, "# PPM Comment\n", info->width ) ) return FXFALSE;
+	if ( 0 > fprintf( stream, "# PPM Comment\n" ) ) return FXFALSE;
 	if ( 0 > fprintf( stream, "%d ", info->width ) ) return FXFALSE;
 	if ( 0 > fprintf( stream, "%d\n", info->height ) ) return FXFALSE;
 	if ( 0 > fprintf( stream, "255\n" ) ) return FXFALSE;
@@ -1878,7 +1878,7 @@
 	if (prefix) {					// if there's a path prefix
 	    char buf[1024], *p;
 	    strcpy(buf,prefix);			// copy and replace semicolon
-	    if (p = strchr(buf,';')) *p = '\0';
+	    if ((p = strchr(buf,';')) != NULL) *p = '\0';
 	    fprintf(stderr,buf);
 	    fprintf(stderr,"/");
 	}
diff -urN Glide_V3-DRI-3.10/swlibs/fxmisc/fxos.c Glide_V3-DRI-3.10-lia/swlibs/fxmisc/fxos.c
--- Glide_V3-DRI-3.10/swlibs/fxmisc/fxos.c	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/fxmisc/fxos.c	Wed Aug  9 22:52:44 2000
@@ -97,7 +97,7 @@
 
     // first try and open up the file in the current directory
     if (pprefix) *pprefix = NULL;
-    if (file = fopen(filename,mode))
+    if ((file = fopen(filename,mode)) != NULL)
         return file;
     if (path = NULL)
         return NULL;
@@ -114,7 +114,7 @@
         strcat(nameWithPath,"/");               // add directory separator
         strcat(nameWithPath,filename);          // add filename
         if (pprefix) *pprefix = path;           // save the prefix
-        if (file = fopen(nameWithPath,mode))
+        if ((file = fopen(nameWithPath,mode)) != NULL)
             return file;
         path = psemi;                           // advance to next path element
         if (path)
diff -urN Glide_V3-DRI-3.10/swlibs/fxmisc/linutil.c Glide_V3-DRI-3.10-lia/swlibs/fxmisc/linutil.c
--- Glide_V3-DRI-3.10/swlibs/fxmisc/linutil.c	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/fxmisc/linutil.c	Wed Aug  9 23:53:52 2000
@@ -28,7 +28,7 @@
 #include <string.h>
 #include "linutil.h"
 
-static init_done=0;
+static int init_done=0;
 static struct termios save_termdata;
 
 static void reset_term() {
diff -urN Glide_V3-DRI-3.10/swlibs/include/make/3dfx.mak Glide_V3-DRI-3.10-lia/swlibs/include/make/3dfx.mak
--- Glide_V3-DRI-3.10/swlibs/include/make/3dfx.mak	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/include/make/3dfx.mak	Wed Aug  9 22:48:55 2000
@@ -84,8 +84,12 @@
 # assembly language in grDrawTriangle. Larger optimization removes
 # an extra push in the calling sequence.
 #
+#if 0
 CNODEBUG       = -O6 -m486 -fomit-frame-pointer -funroll-loops \
 	-fexpensive-optimizations -ffast-math -DBIG_OPT
+#else
+CNODEBUG       = -g -O3 -fomit-frame-pointer -fexpensive-optimizations -ffast-math -DBIG_OPT
+#endif
 
 CDEBUG	       = -g -O
 # Profiling
@@ -112,7 +116,7 @@
 
 # if we are not debugging then replace debug flags with nodebug flags
 
-# DEBUG = xx
+#DEBUG = xx
 
 ifdef DEBUG
 CDEBUG   += $(DEBUGDEFS)
diff -urN Glide_V3-DRI-3.10/swlibs/newpci/pcilib/fxlinux.c Glide_V3-DRI-3.10-lia/swlibs/newpci/pcilib/fxlinux.c
--- Glide_V3-DRI-3.10/swlibs/newpci/pcilib/fxlinux.c	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/newpci/pcilib/fxlinux.c	Wed Aug  9 14:48:28 2000
@@ -47,10 +47,10 @@
 static FxBool pciOutputStringLinux(const char *msg);
 static FxBool pciInitializeLinux(void);
 static FxBool pciShutdownLinux(void);
-static FxBool pciMapLinearLinux(FxU32, FxU32 physical_addr, FxU32 *linear_addr,
+static FxBool pciMapLinearLinux(FxU32, FxU32 physical_addr, long *linear_addr,
 				FxU32 *length);
-static FxBool pciUnmapLinearLinux(FxU32 linear_addr, FxU32 length);
-static FxBool pciSetPermissionLinux(const FxU32, const FxU32, const FxBool);
+static FxBool pciUnmapLinearLinux(long linear_addr, FxU32 length);
+static FxBool pciSetPermissionLinux(const long, const FxU32, const FxBool);
 static FxU8 pciPortInByteLinux(unsigned short port);
 static FxU16 pciPortInWordLinux(unsigned short port);
 static FxU32 pciPortInLongLinux(unsigned short port);
@@ -216,7 +216,7 @@
 
 static FxBool 
 pciMapLinearLinux(FxU32 bus, FxU32 physical_addr,
-		  FxU32 *linear_addr, FxU32 *length) 
+		  long *linear_addr, FxU32 *length) 
 {
   int fd;
   if (linuxDevFd!=-1) {
@@ -227,7 +227,7 @@
       return FXFALSE;
     }
   }
-  if (((*linear_addr)=(FxU32)mmap(0, *length, PROT_READ|PROT_WRITE,
+  if (((*linear_addr)=(long)mmap(0, *length, PROT_READ|PROT_WRITE,
 				  MAP_SHARED, fd, physical_addr))<0) {
     if (fd!=linuxDevFd) close(fd);
     return FXFALSE;
@@ -237,14 +237,14 @@
 }
 
 static FxBool
-pciUnmapLinearLinux(FxU32 linear_addr, FxU32 length) 
+pciUnmapLinearLinux(long linear_addr, FxU32 length) 
 {
-  munmap((void*)linear_addr, length);
+  munmap((void *) linear_addr, length);
   return FXTRUE;
 }
 
 static FxBool
-pciSetPermissionLinux(const FxU32 addrBase, const FxU32 addrLen, 
+pciSetPermissionLinux(const long addrBase, const FxU32 addrLen, 
 		      const FxBool writePermP)
 {
   return FXTRUE;
diff -urN Glide_V3-DRI-3.10/swlibs/newpci/pcilib/fxpci.c Glide_V3-DRI-3.10-lia/swlibs/newpci/pcilib/fxpci.c
--- Glide_V3-DRI-3.10/swlibs/newpci/pcilib/fxpci.c	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/newpci/pcilib/fxpci.c	Wed Aug  9 14:43:12 2000
@@ -692,9 +692,8 @@
                 FxU32 *devNum,
                 FxU32 cardNum, FxU32 addressNum)
 {
-  FxU32 
-    physAddress, 
-    virtAddress;
+  FxU32 physAddress;
+  long virtAddress;
   
   /* 1) open the PCI device and scan it for devices
    * 2) scan the existing devices for a match
@@ -704,7 +703,7 @@
 
   /* 3) find the current physcial address of the card */
   pciGetConfigData( baseAddresses[addressNum], *devNum, &physAddress );
-  if (length <= 0) return (FxU32*)length;
+  if (length <= 0) return (FxU32*)(long)length;
 
   /* Mask the memory type information bits off.
    *   [0]: Memory type indicator (0 memory/1 i/o)
@@ -753,7 +752,7 @@
 } /* pciMapCard */
 
 FX_EXPORT FxBool FX_CSTYLE
-pciMapPhysicalToLinear( FxU32 *linear_addr, FxU32 physical_addr,
+pciMapPhysicalToLinear( long *linear_addr, FxU32 physical_addr,
                         FxU32 *length ) 
 { 
   return pciMapPhysicalDeviceToLinear(linear_addr, 
@@ -762,7 +761,7 @@
 } /* pciMapPhysicalToLinear */
 
 FX_ENTRY FxBool FX_CALL 
-pciMapPhysicalDeviceToLinear(FxU32 *linear_addr, 
+pciMapPhysicalDeviceToLinear(long *linear_addr, 
                              FxU32 busNumber, FxU32 physical_addr,
                              FxU32 *length)
 {
@@ -772,7 +771,7 @@
 
 
 FX_EXPORT void FX_CSTYLE
-pciUnmapPhysical( FxU32 linear_addr, FxU32 length ) 
+pciUnmapPhysical( long linear_addr, FxU32 length ) 
 {
   int i,j;
   
@@ -811,7 +810,7 @@
 }
 
 FX_EXPORT FxBool FX_CSTYLE
-pciLinearRangeSetPermission(const FxU32 addrBase, const FxU32 addrLen, const FxBool writeableP)
+pciLinearRangeSetPermission(const long addrBase, const FxU32 addrLen, const FxBool writeableP)
 {
   return pciLinearRangeSetPermissionDD(addrBase, addrLen, writeableP);
 }
diff -urN Glide_V3-DRI-3.10/swlibs/newpci/pcilib/fxpci.h Glide_V3-DRI-3.10-lia/swlibs/newpci/pcilib/fxpci.h
--- Glide_V3-DRI-3.10/swlibs/newpci/pcilib/fxpci.h	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/newpci/pcilib/fxpci.h	Wed Aug  9 14:43:41 2000
@@ -169,15 +169,15 @@
  * on bus0 which would not work across pci bridges or on agp devices.   
  */
 FX_ENTRY FxBool FX_CALL 
-pciMapPhysicalToLinear(FxU32 *linear_addr, FxU32 physical_addr,FxU32 *length);
+pciMapPhysicalToLinear(long *linear_addr, FxU32 physical_addr,FxU32 *length);
 
 FX_ENTRY FxBool FX_CALL 
-pciMapPhysicalDeviceToLinear(FxU32 *linear_addr, 
+pciMapPhysicalDeviceToLinear(long *linear_addr, 
                              FxU32 busNumber, FxU32 physical_addr,
                              FxU32 *length);
 
 FX_ENTRY void   FX_CALL 
-pciUnmapPhysical( FxU32 linear_addr, FxU32 length );
+pciUnmapPhysical( long linear_addr, FxU32 length );
 
 const char *
 pciGetVendorName( FxU16 vendor_id );
@@ -215,7 +215,7 @@
 pciOutputDebugString(const char* debugMsg);
 
 FX_ENTRY FxBool FX_CALL
-pciLinearRangeSetPermission(const FxU32 addrBase, const FxU32 addrLen, const FxBool writeableP);
+pciLinearRangeSetPermission(const long addrBase, const FxU32 addrLen, const FxBool writeableP);
 
 #define PCI_ERR_NOERR           0
 #define PCI_ERR_WINRTINIT       1
diff -urN Glide_V3-DRI-3.10/swlibs/newpci/pcilib/pcilib.h Glide_V3-DRI-3.10-lia/swlibs/newpci/pcilib/pcilib.h
--- Glide_V3-DRI-3.10/swlibs/newpci/pcilib/pcilib.h	Thu Mar  2 14:53:51 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/newpci/pcilib/pcilib.h	Wed Aug  9 14:46:46 2000
@@ -74,13 +74,13 @@
 
   /* Platform device address management */
   FxBool (*addrMap)(FxU32 busNumber, FxU32 physAddr,
-                    FxU32* linearAddr, FxU32* length);
-  FxBool (*addrUnmap)(FxU32 linearAddr, FxU32 length);
+                    long* linearAddr, FxU32* length);
+  FxBool (*addrUnmap)(long linearAddr, FxU32 length);
 
   /* Optional things that a platform may or maynot support and clients
    * should not rely on the call to suceed.  
    */
-  FxBool (*addrSetPermission)(const FxU32 addrBase, const FxU32 addrLen,
+  FxBool (*addrSetPermission)(const long addrBase, const FxU32 addrLen,
                               const FxBool writePermP);
 
   FxBool (*msrGet)(MSRInfo* in, MSRInfo* out);
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/dequant.c Glide_V3-DRI-3.10-lia/swlibs/texus/lib/dequant.c
--- Glide_V3-DRI-3.10/swlibs/texus/lib/dequant.c	Thu Mar  2 14:53:52 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/dequant.c	Wed Aug  9 22:56:24 2000
@@ -160,12 +160,12 @@
 }
 
 static void
-_txImgDequantizeYIQ422(FxU32 *out, FxU8 *in, int w, int h, const long *yabTable)
+_txImgDequantizeYIQ422(FxU32 *out, FxU8 *in, int w, int h, const FxU32 *yabTable)
 {
     int                         n = w * h;
     FxU32                       pal[256];
 
-    txYABtoPal256((long *)pal, (long *)yabTable);
+    txYABtoPal256(pal, yabTable);
     out += n;
     in  += n;
     while (n--) *--out = pal[*--in] | 0xff000000;
@@ -223,10 +223,10 @@
 }
 
 static void
-_txImgDequantizeAYIQ8422(FxU32 *out, FxU16 *in, int w, int h, const long *yab)
+_txImgDequantizeAYIQ8422(FxU32 *out, FxU16 *in, int w, int h, const FxU32 *yab)
 {
     int         n = w * h;
-    long        pal[256];
+    FxU32       pal[256];
 
     txYABtoPal256(pal, yab);
     out += n;
@@ -348,7 +348,7 @@
         case GR_TEXFMT_RGB_332:         _txImgDequantizeRGB332(dst, src, w, h);         
                                                                 break;
         case GR_TEXFMT_YIQ_422:         _txImgDequantizeYIQ422(dst, src, w, h, 
-                                                                        (long *)pxMip->pal); break;
+                                                                        pxMip->pal); break;
         case GR_TEXFMT_A_8:                     _txImgDequantizeA8(dst, src, w, h);             
                                                                 break;
         case GR_TEXFMT_I_8:                     _txImgDequantizeI8(dst, src, w, h);             
@@ -361,7 +361,7 @@
         case GR_TEXFMT_ARGB_8332:       _txImgDequantizeARGB8332(dst, src, w, h);       
                                                                 break;
         case GR_TEXFMT_AYIQ_8422:       _txImgDequantizeAYIQ8422(dst, src, w, h, 
-                                                                        (long *)pxMip->pal); break;
+                                                                        pxMip->pal); break;
         case GR_TEXFMT_RGB_565:         _txImgDequantizeRGB565(dst, src, w, h); 
                                                                 break;
         case GR_TEXFMT_ARGB_1555:       _txImgDequantizeARGB1555(dst, src, w, h);       
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/mipmap.c Glide_V3-DRI-3.10-lia/swlibs/texus/lib/mipmap.c
--- Glide_V3-DRI-3.10/swlibs/texus/lib/mipmap.c	Thu Mar  2 14:53:52 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/mipmap.c	Wed Aug  9 13:58:17 2000
@@ -35,7 +35,7 @@
 #define B3(x)   ((x>>0)&0xFF)
 
 static void
-_txImgHalve(long *outdata, int width, int height, long *indata)
+_txImgHalve(int *outdata, int width, int height, int *indata)
 {
     unsigned int i,j,k;
     unsigned int w,h, *p,sum,*q;
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/ncc.c Glide_V3-DRI-3.10-lia/swlibs/texus/lib/ncc.c
--- Glide_V3-DRI-3.10/swlibs/texus/lib/ncc.c	Thu Mar  2 14:53:52 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/ncc.c	Wed Aug  9 23:02:12 2000
@@ -29,10 +29,10 @@
 #include "texusint.h"
 
 static int 
-dithmat[4][4] = {       0,  8,  2, 10, 
-                           12,  4, 14,  6, 
-                            3, 11,  1,  9, 
-                           15,  7, 13,  5 };
+dithmat[4][4] = {      { 0,  8,  2, 10,    },
+                       {    12,  4, 14,  6 },
+                       {     3, 11,  1,  9 },
+                       {    15,  7, 13,  5 }  };
 
 static struct   {
     int yhist[256], ihist[256], qhist[256];
@@ -124,7 +124,7 @@
 }
 
 static void
-_txImgNcc(char *odata, unsigned long *idata, int w, int h, int format, 
+_txImgNcc(char *odata, unsigned int *idata, int w, int h, int format, 
     int dither)
 {
     int (*quantizer)(unsigned long argb, int x, int y, int w);
@@ -308,7 +308,7 @@
 
 
     if ((dither & TX_DITHER_MASK) = TX_DITHER_ERR) {
-        txYABtoPal256((long *)pxMip->pal, (long *) &ncc.y[0]);
+        txYABtoPal256(pxMip->pal, &ncc.y[0]);
         txDiffuseIndex(pxMip, txMip, pixsize, pxMip->pal, 256);
     }
     else {
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/nccnnet.c Glide_V3-DRI-3.10-lia/swlibs/texus/lib/nccnnet.c
--- Glide_V3-DRI-3.10/swlibs/texus/lib/nccnnet.c	Thu Mar  2 14:53:52 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/nccnnet.c	Wed Aug  9 14:00:08 2000
@@ -88,19 +88,19 @@
 #define MAX_NEURONS             256
 
 typedef struct  _weight {
-    long         r,  g,  b;                             // fixed point, SUBPIXEL precision bits
+    int          r,  g,  b;                             // fixed point, SUBPIXEL precision bits
     int         ir, ig, ib;                             // pure integers, maybe -256 to 255.
 } Weight;
 
 typedef struct  _vector {
     Weight      *py, *pa, *pb;
-    long         r,  g,  b;                             // pure integers, 0 to 255.
+    int         r,  g,  b;                             // pure integers, 0 to 255.
 } Neuron;
 
 static  Weight                  Y[16], A[4], B[4];
 static  Neuron                  N[MAX_NEURONS];
-static  long                    errR, errG, errB, errMax;
-static  long                    totR, totG, totB;
+static  int                     errR, errG, errB, errMax;
+static  int                     totR, totG, totB;
 
 
 #define SUBPIXEL                22
@@ -114,12 +114,12 @@
                                                 x = ((256 << SUBPIXEL) -1)
 
 static int
-_nn_modifyNeurons(long ir, long ig, long ib)
+_nn_modifyNeurons(int ir, int ig, int ib)
 {
     int         i; 
     int         d0, d1;                         // closest & next closest distance to input
     int         p0, p1;                         // index into the 256 color table.
-    long        d, dr, dg, db;
+    int         d, dr, dg, db;
     Weight      *py, *pa, *pb;
     Neuron      *n;
 
@@ -268,10 +268,10 @@
 txMapPal256toYAB(FxU32 *YAB, FxU8 *map, int nsamples, FxU32 *samples)
 {
     int         i;
-    long        bstR, bstG, bstB, bstMax;
+    int         bstR, bstG, bstB, bstMax;
     int         iterations;                     // track how many inputs have been fed to NN
     int         drySpells;                      // how many inputs since last best case.
-    long        yab2pal[256];
+    int         yab2pal[256];
 
     _nn_initTables();
     /* 
@@ -367,7 +367,7 @@
      * Replace MSB of samples with index to be used with YAB table.
      */
 
-    txYABtoPal256((long*)yab2pal, (long*)YAB);
+    txYABtoPal256(yab2pal, YAB);
 
     for (i=0; i<nsamples; i++) {
         int             ir, ig, ib;
@@ -388,7 +388,7 @@
     int         i, w, h;
     int         ncolors;
     int         pixsize = (pxMip->format = GR_TEXFMT_YIQ_422) ? 1 : 2;
-    long        yabTable[16+12+12];
+    int         yabTable[16+12+12];
     FxU8        map[256];
 
 
@@ -425,7 +425,7 @@
          * the 256 color palette generated from the YAB table. This will be 
          * useful for error diffusion dithering.
          */
-        txYABtoPal256((long *)pxMip->pal, (long *)yabTable);
+        txYABtoPal256(pxMip->pal, yabTable);
         txDiffuseIndex(pxMip, txMip, pixsize, pxMip->pal, 256);
     } 
     else {
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/pal256.c Glide_V3-DRI-3.10-lia/swlibs/texus/lib/pal256.c
--- Glide_V3-DRI-3.10/swlibs/texus/lib/pal256.c	Thu Mar  2 14:53:52 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/pal256.c	Wed Aug  9 14:01:18 2000
@@ -80,20 +80,20 @@
 
 typedef struct {
     float               weightedvar;            /* weighted variance */
-    ulong               mean[3];                        /* centroid */
-    ulong               weight;                         /* # of pixels in box */
-    ulong               freq[3][MAXCOLORS];     /* Projected frequencies */
+    uint                mean[3];                        /* centroid */
+    uint                weight;                         /* # of pixels in box */
+    uint                freq[3][MAXCOLORS];     /* Projected frequencies */
     int                 low[3], high[3];        /* Box extent */
 } Box;
 
 #define COLORMAXI ( 1 << NBITS )
 #if 0
-static ulong    *Histogram;             /* image histogram      */
+static uint    *Histogram;             /* image histogram      */
 #else
-static ulong    Histogram[COLORMAXI*COLORMAXI*COLORMAXI * sizeof(long)];
+static uint     Histogram[COLORMAXI*COLORMAXI*COLORMAXI * sizeof(long)];
 #endif
-static ulong    SumPixels;              /* total # of pixels    */
-static ulong    ColormaxI;              /* # of colors, 2^Bits */
+static uint     SumPixels;              /* total # of pixels    */
+static uint     ColormaxI;              /* # of colors, 2^Bits */
 static Box              _Boxes[MAXCOLORS];
 static Box              *Boxes;                 /* Array of color boxes. */
 
@@ -105,7 +105,7 @@
 static void     BoxStats(Box *box);
 static int      GreatestVariance(Box *boxes, int n);
 static int      CutBoxes(Box *boxes, int colors);
-static void     QuantHistogram(ulong *pixels, int npixels, Box *box);
+static void     QuantHistogram(uint *pixels, int npixels, Box *box);
 
 /*
  * Perform variance-based color quantization on a 24-bit image.
@@ -132,16 +132,16 @@
 
     Boxes = _Boxes;     
 #if 0
-    Histogram = (ulong *) txMalloc(ColormaxI*ColormaxI*ColormaxI * sizeof(long));
+    Histogram = (uint *) txMalloc(ColormaxI*ColormaxI*ColormaxI * sizeof(long));
     rgbmap = txMalloc((1<<NBITS)*(1<<NBITS)*(1<<NBITS));
 #endif
 
     /*
      * Zero-out the projected frequency arrays of the largest box.
      */
-    bzero(Boxes->freq[0], ColormaxI * sizeof(ulong));
-    bzero(Boxes->freq[1], ColormaxI * sizeof(ulong));
-    bzero(Boxes->freq[2], ColormaxI * sizeof(ulong));
+    bzero(Boxes->freq[0], ColormaxI * sizeof(uint));
+    bzero(Boxes->freq[1], ColormaxI * sizeof(uint));
+    bzero(Boxes->freq[2], ColormaxI * sizeof(uint));
     bzero(Histogram, ColormaxI * ColormaxI * ColormaxI * sizeof(long));
 
     /* Feed all bitmaps & generate histogram */
@@ -150,7 +150,7 @@
     h = txMip->height;
     for (i=0; i< txMip->depth; i++) {
         SumPixels += w * h;
-        QuantHistogram((ulong *)txMip->data[i], w * h, &Boxes[0]);
+        QuantHistogram((uint *)txMip->data[i], w * h, &Boxes[0]);
         if (w > 1) w >>= 1;
         if (h > 1) h >>= 1;
     }
@@ -163,10 +163,10 @@
      * from their 'prequantized' range to 0-FULLINTENSITY.
      */
     for (i = 0; i < OutColors; i++) {
-        ulong   r, g, b;
-        r = (ulong)(Boxes[i].mean[REDI] * Cfactor + 0.5);
-        g = (ulong)(Boxes[i].mean[GREENI] * Cfactor + 0.5);
-        b = (ulong)(Boxes[i].mean[BLUEI] * Cfactor + 0.5);
+        uint   r, g, b;
+        r = (uint)(Boxes[i].mean[REDI] * Cfactor + 0.5);
+        g = (uint)(Boxes[i].mean[GREENI] * Cfactor + 0.5);
+        b = (uint)(Boxes[i].mean[BLUEI] * Cfactor + 0.5);
 
         /*
         r &= 0xff;
@@ -195,11 +195,11 @@
         h = txMip->height;
 
         for (i=0; i< txMip->depth; i++) {
-                ulong   *src;
+                uint   *src;
                 uchar   *dst;
                 int             n;
 
-                src = (ulong *) txMip->data[i];
+                src = (uint *) txMip->data[i];
                 dst = (uchar *) pxMip->data[i];
                 n   = w * h;
                 while (n--) {
@@ -239,9 +239,9 @@
  * arrays for the first world-encompassing box.
  */
 static void
-QuantHistogram(ulong *pixels, int npixels, Box *box)
+QuantHistogram(uint *pixels, int npixels, Box *box)
 {
-    ulong *rf, *gf, *bf;
+    uint *rf, *gf, *bf;
     uchar rr, gg, bb;
     int         i;
 
@@ -319,7 +319,7 @@
 BoxStats(Box *box)
 {
     int i, color;
-    ulong *freq;
+    uint *freq;
     float mean, var;
 
     if(box->weight = 0) {
@@ -404,7 +404,7 @@
 {
     float u, v, max;
     int i, maxindex, minindex, cutpoint;
-    ulong optweight, curweight;
+    uint optweight, curweight;
 
     if (box->low[color] + 1 = box->high[color])
         return FALSE;   /* Cannot be cut. */
@@ -454,13 +454,13 @@
 static void
 UpdateFrequencies(Box *box1, Box *box2)
 {
-    ulong myfreq, *h;
+    uint myfreq, *h;
     int b, g, r;
     int roff;
 
-    bzero(box1->freq[0], ColormaxI * sizeof(ulong));
-    bzero(box1->freq[1], ColormaxI * sizeof(ulong));
-    bzero(box1->freq[2], ColormaxI * sizeof(ulong)); 
+    bzero(box1->freq[0], ColormaxI * sizeof(uint));
+    bzero(box1->freq[1], ColormaxI * sizeof(uint));
+    bzero(box1->freq[2], ColormaxI * sizeof(uint)); 
 
     for (r = box1->low[0]; r < box1->high[0]; r++) {
         roff = r << NBITS;
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/quantize.c Glide_V3-DRI-3.10-lia/swlibs/texus/lib/quantize.c
--- Glide_V3-DRI-3.10/swlibs/texus/lib/quantize.c	Thu Mar  2 14:53:52 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/quantize.c	Wed Aug  9 23:01:08 2000
@@ -30,16 +30,16 @@
 #include "texusint.h"
 
 static int 
-dithmat[4][4] = {       0,  8,  2, 10, 
-                           12,  4, 14,  6, 
-                            3, 11,  1,  9, 
-                           15,  7, 13,  5 };
+dithmat[4][4] = {      { 0,  8,  2, 10,    },
+                       {    12,  4, 14,  6 },
+                       {     3, 11,  1,  9 },
+                       {    15,  7, 13,  5 } };
 
 // for error diffusion.
 static int      errR[MAX_TEXWIDTH], errG[MAX_TEXWIDTH], errB[MAX_TEXWIDTH];     
 
 static int
-_txPixQuantize_RGB332( unsigned long argb, int x, int y, int w)
+_txPixQuantize_RGB332( unsigned int argb, int x, int y, int w)
 {
     return (
                         (((argb>>16) & 0xE0) |
@@ -48,7 +48,7 @@
 }
 
 static int
-_txPixQuantize_RGB332_D4x4( unsigned long argb, int x, int y, int w)
+_txPixQuantize_RGB332_D4x4( unsigned int argb, int x, int y, int w)
 {
     int d = dithmat[y&3][x&3];
     int n, t;
@@ -63,7 +63,7 @@
 }
 
 static int
-_txPixQuantize_RGB332_DErr( unsigned long argb, int x, int y, int w)
+_txPixQuantize_RGB332_DErr( unsigned int argb, int x, int y, int w)
 {
     static unsigned char a3[] = {0x00,0x24,0x49,0x6d,0x92,0xb6,0xdb,0xff};
     static unsigned char a2[] = {0x00,0x55,0xaa,0xff};
@@ -120,13 +120,13 @@
 /* YIQ422 done elsewhere */
 
 static int
-_txPixQuantize_A8( unsigned long argb, int x, int y, int w)
+_txPixQuantize_A8( unsigned int argb, int x, int y, int w)
 {
     return (argb >> 24);
 }
 
 static int
-_txPixQuantize_I8( unsigned long argb, int x, int y, int w)
+_txPixQuantize_I8( unsigned int argb, int x, int y, int w)
 {
     return (
     ((int) (((argb >>16) & 0xFF) * .30F +
@@ -135,7 +135,7 @@
 }
 
 static int
-_txPixQuantize_AI44( unsigned long argb, int x, int y, int w)
+_txPixQuantize_AI44( unsigned int argb, int x, int y, int w)
 {
     return(
         (int)   ((      ((argb>>16) & 0xFF) * .30F +
@@ -145,7 +145,7 @@
 }
 
 static int
-_txPixQuantize_AI44_D4x4( unsigned long argb, int x, int y, int w)
+_txPixQuantize_AI44_D4x4( unsigned int argb, int x, int y, int w)
 {
     int d = dithmat[y&3][x&3];
     int n, t;
@@ -163,7 +163,7 @@
 }
 
 static int
-_txPixQuantize_AI44_DErr( unsigned long argb, int x, int y, int w)
+_txPixQuantize_AI44_DErr( unsigned int argb, int x, int y, int w)
 {
     int ii, t;
     static      int     qi;
@@ -198,7 +198,7 @@
 
 
 static int
-_txPixQuantize_ARGB8332 ( unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB8332 ( unsigned int argb, int x, int y, int w)
 {
     return (
                          ((argb>>16) & 0xE0) |
@@ -209,7 +209,7 @@
 
 
 static int
-_txPixQuantize_ARGB8332_D4x4( unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB8332_D4x4( unsigned int argb, int x, int y, int w)
 {
     int d = dithmat[y&3][x&3];
     int n, t;
@@ -225,7 +225,7 @@
 }
 
 static int
-_txPixQuantize_ARGB8332_DErr( unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB8332_DErr( unsigned int argb, int x, int y, int w)
 {
     int t;
 
@@ -237,7 +237,7 @@
 /* AYIQ8422 done elsewhere */
 
 static int
-_txPixQuantize_RGB565( unsigned long argb, int x, int y, int w)
+_txPixQuantize_RGB565( unsigned int argb, int x, int y, int w)
 {
     return (
                     ((argb >> 8) & 0xF800) |
@@ -246,7 +246,7 @@
 }
 
 static int
-_txPixQuantize_RGB565_D4x4 ( unsigned long argb, int x, int y, int w)
+_txPixQuantize_RGB565_D4x4 ( unsigned int argb, int x, int y, int w)
 {
     int d = dithmat[y&3][x&3];
     int n, t;
@@ -262,7 +262,7 @@
 
 
 static int
-_txPixQuantize_RGB565_DErr ( unsigned long argb, int x, int y, int w)
+_txPixQuantize_RGB565_DErr ( unsigned int argb, int x, int y, int w)
 {
     static int          qr, qg, qb;             // quantized incoming values.
     int                         ir, ig, ib;             // incoming values.
@@ -318,7 +318,7 @@
 }
 
 static int
-_txPixQuantize_ARGB1555( unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB1555( unsigned int argb, int x, int y, int w)
 {
     return (
                     ((argb >> 9) & 0x7C00) |
@@ -328,7 +328,7 @@
 }
 
 static int
-_txPixQuantize_ARGB1555_D4x4 ( unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB1555_D4x4 ( unsigned int argb, int x, int y, int w)
 {
     int d = dithmat[y&3][x&3];
     int n, t;
@@ -344,7 +344,7 @@
 }
 
 static int
-_txPixQuantize_ARGB1555_DErr ( unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB1555_DErr ( unsigned int argb, int x, int y, int w)
 {
     static int          qr, qg, qb;             // quantized incoming values.
     int                         ir, ig, ib;             // incoming values.
@@ -401,7 +401,7 @@
 }
 
 static int
-_txPixQuantize_ARGB4444 (unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB4444 (unsigned int argb, int x, int y, int w)
 {
     return (
                     ((argb >> 12) & 0x0F00) |
@@ -411,7 +411,7 @@
 }
 
 static int
-_txPixQuantize_ARGB4444_D4x4 (unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB4444_D4x4 (unsigned int argb, int x, int y, int w)
 {
     int d = dithmat[y&3][x&3];
     int n, t;
@@ -427,7 +427,7 @@
 }
 
 static int
-_txPixQuantize_ARGB4444_DErr (unsigned long argb, int x, int y, int w)
+_txPixQuantize_ARGB4444_DErr (unsigned int argb, int x, int y, int w)
 {
     static int          qr, qg, qb;             // quantized incoming values.
     int                         ir, ig, ib;             // incoming values.
@@ -484,7 +484,7 @@
 }
 
 static int
-_txPixQuantize_AI88( unsigned long argb, int x, int y, int w)
+_txPixQuantize_AI88( unsigned int argb, int x, int y, int w)
 {
     return (
     (((int) (((argb >>16) & 0xFF) * .30F +
@@ -498,7 +498,7 @@
 static void
 _txImgQuantize(char *dst, char *src, int w, int h, FxU32 format, FxU32 dither)
 {
-    int (*quantizer)(unsigned long argb, int x, int y, int w);
+    int (*quantizer)(unsigned int argb, int x, int y, int w);
     int         x, y;
 
     dither &= TX_DITHER_MASK;
@@ -589,7 +589,7 @@
         // 8 bit dst
         for (y=0; y<h; y++) {
                 for (x=0; x<w; x++) {
-                        *dst++ = (*quantizer)(*(unsigned long *)src, x, y, w);
+                        *dst++ = (*quantizer)(*(unsigned int *)src, x, y, w);
                         src += 4;
                 }
         }
@@ -599,7 +599,7 @@
 
         for (y=0; y<h; y++) {
                 for (x=0; x<w; x++) {
-                        *dst16++ = (*quantizer)(*(unsigned long *)src, x, y, w);
+                        *dst16++ = (*quantizer)(*(unsigned int *)src, x, y, w);
                         src += 4;
                 }
         }
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/rgt.c Glide_V3-DRI-3.10-lia/swlibs/texus/lib/rgt.c
--- Glide_V3-DRI-3.10/swlibs/texus/lib/rgt.c	Thu Mar  2 14:53:53 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/rgt.c	Wed Aug  9 14:02:59 2000
@@ -52,7 +52,7 @@
 
 
 
-static void swapShorts(unsigned short *array, long length)
+static void swapShorts(unsigned short *array, int length)
 {
     unsigned short s;
     while (length--) {
@@ -61,7 +61,7 @@
     }
 }
 
-static void swapLongs(unsigned int *array, long length)
+static void swapLongs(unsigned int *array, int length)
 {
     unsigned int s;
     while (length--) {
@@ -72,7 +72,7 @@
 }
 
 // just swap RGB into BGR (leave MSB undefined)
-static void swapRGB(unsigned int *array, long length)
+static void swapRGB(unsigned int *array, int length)
 {
     unsigned int s;
     while (length--) {
@@ -164,7 +164,7 @@
 
 #if 1
         if (swap) {
-            swapRGB((unsigned int *)data32, (long)info->width);
+            swapRGB((unsigned int *)data32, (int)info->width);
         }
 #endif
 
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/texus.h Glide_V3-DRI-3.10-lia/swlibs/texus/lib/texus.h
--- Glide_V3-DRI-3.10/swlibs/texus/lib/texus.h	Thu Mar  2 14:53:53 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/texus.h	Wed Aug  9 13:53:28 2000
@@ -38,8 +38,13 @@
 typedef unsigned char   FxU8;
 typedef unsigned short  FxU16;
 typedef short           FxI16;
+#ifdef __LP64__
+typedef unsigned int    FxU32;
+typedef int             FxI32;
+#else
 typedef unsigned long   FxU32;
 typedef long            FxI32;
+#endif
 typedef int             FxBool;
 
 /*
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/texusint.h Glide_V3-DRI-3.10-lia/swlibs/texus/lib/texusint.h
--- Glide_V3-DRI-3.10/swlibs/texus/lib/texusint.h	Thu Mar  2 14:53:53 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/texusint.h	Wed Aug  9 14:03:17 2000
@@ -67,7 +67,7 @@
 int             txAspectRatio(int w, int h);
 void    txPanic(char *);
 void    txError(char *);
-void    txYABtoPal256(long *palette, const long* yabTable);
+void    txYABtoPal256(int *palette, const int* yabTable);
 void    txRectCopy(FxU8 *dst, int dstStride, const FxU8 *src, int srcStride,
                         int width, int height);
 FxBool  txMipAlloc(TxMip *txMip);
@@ -90,7 +90,7 @@
 
 void    txDiffuseIndex(TxMip *pxMip, TxMip *txMip, int pixsize, 
                 const FxU32 *palette, int       ncolors);
-int             txNearestColor(long ir, long ig, long ib, const FxU32 *pal, int npal);
+int             txNearestColor(int ir, int ig, int ib, const FxU32 *pal, int npal);
 
 FxBool _txReadTGAHeader( FILE *stream, FxU32 cookie, TxMip *info);
 FxBool _txReadTGAData( FILE *stream, TxMip *info);
diff -urN Glide_V3-DRI-3.10/swlibs/texus/lib/util.c Glide_V3-DRI-3.10-lia/swlibs/texus/lib/util.c
--- Glide_V3-DRI-3.10/swlibs/texus/lib/util.c	Thu Mar  2 14:53:53 2000
+++ Glide_V3-DRI-3.10-lia/swlibs/texus/lib/util.c	Wed Aug  9 14:04:07 2000
@@ -133,14 +133,14 @@
 }
 
 void
-txYABtoPal256(long *palette, const long* yabTable)
+txYABtoPal256(int *palette, const int* yabTable)
 {
         // Convert YAB table to a 256 color palette 
         // Assume yabTable[] has first 16Y's, 12 A's, 12 B's
 
-        const   long    *Y = yabTable;
-        const   long    *A = yabTable + 16;
-        const   long    *B = yabTable + 16 + 12;
+        const   int    *Y = yabTable;
+        const   int    *A = yabTable + 16;
+        const   int    *B = yabTable + 16 + 12;
         int             i;
 
         for (i=0; i<256; i++) {
@@ -265,7 +265,7 @@
 int  *explode3 = &_explode3[255];
 
 int
-txNearestColor(long ir, long ig, long ib, const FxU32 *pal, int ncolors)
+txNearestColor(int ir, int ig, int ib, const FxU32 *pal, int ncolors)
 {
         int             i, d; 
         int             mindist, minpos;                // closest distance to input

