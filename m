From: Russ Anderson <rja@sgi.com>
Date: Fri, 29 Feb 2008 23:14:44 +0000
Subject: [patch] Itanium Spec updates
Message-Id: <20080229231444.GA16281@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

[patch] Itanium Spec updates

Updates based on the "Intel=AE Itanium=AE Architecture Software Developer's=
 Manual
Specification Update October 2007".

http://download.intel.com/design/itanium/specupdt/24869911.pdf

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 include/asm-ia64/pal.h |   72 ++++++++++++++++++++++++++++++++++++++++++--=
-----
 1 file changed, 63 insertions(+), 9 deletions(-)

Index: test/include/asm-ia64/pal.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/include/asm-ia64/pal.h	2008-02-29 17:=
04:02.012887185 -0600
+++ test/include/asm-ia64/pal.h	2008-02-29 17:09:05.431058432 -0600
@@ -13,6 +13,7 @@
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999 Srinivasa Prasad Thirumalachar <sprasad@sprasad.engr=
.sgi.com>
+ * Copyright (C) 2008 Silicon Graphics, Inc. (SGI)
  *
  * 99/10/01	davidm	Make sure we pass zero for reserved parameters.
  * 00/03/07	davidm	Updated pal_cache_flush() to be in sync with PAL v2.6.
@@ -73,6 +74,8 @@
 #define PAL_CACHE_SHARED_INFO	43	/* returns information on caches shared b=
y logical processor */
 #define PAL_GET_HW_POLICY	48	/* Get current hardware resource sharing poli=
cy */
 #define PAL_SET_HW_POLICY	49	/* Set current hardware resource sharing poli=
cy */
+#define PAL_VP_INFO		50	/* Information about virtual processor features */
+#define PAL_MC_HW_TRACKING	51	/* Hardware tracking status */
=20
 #define PAL_COPY_PAL		256	/* relocate PAL procedures and PAL PMI */
 #define PAL_HALT_INFO		257	/* return the low power capabilities of process=
or */
@@ -504,7 +507,8 @@ typedef struct pal_cache_check_info_s {
 			wiv		: 1,	/* Way field valid */
 			reserved2	: 1,
 			dp		: 1,	/* Data poisoned on MBE */
-			reserved3	: 8,
+			reserved3	: 6,
+			hlth		: 2,	/* Health indicator */
=20
 			index		: 20,	/* Cache line index */
 			reserved4	: 2,
@@ -542,7 +546,9 @@ typedef struct pal_tlb_check_info_s {
 			dtc		: 1,	/* Fail in data TC */
 			itc		: 1,	/* Fail in inst. TC */
 			op		: 4,	/* Cache operation */
-			reserved3	: 30,
+			reserved3	: 6,
+			hlth		: 2,	/* Health indicator */
+			reserved4	: 22,
=20
 			is		: 1,	/* instruction set (1 =3D ia32) */
 			iv		: 1,	/* instruction set field valid */
@@ -633,7 +639,8 @@ typedef struct pal_uarch_check_info_s {
 			way		: 6,	/* Way of structure */
 			wv		: 1,	/* way valid */
 			xv		: 1,	/* index valid */
-			reserved1	: 8,
+			reserved1	: 6,
+			hlth		: 2,	/* Health indicator */
 			index		: 8,	/* Index or set of the uarch
 						 * structure that failed.
 						 */
@@ -1213,14 +1220,12 @@ ia64_pal_mc_drain (void)
=20
 /* Return the machine check dynamic processor state */
 static inline s64
-ia64_pal_mc_dynamic_state (u64 offset, u64 *size, u64 *pds)
+ia64_pal_mc_dynamic_state (u64 info_type, u64 dy_buffer, u64 *size)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_MC_DYNAMIC_STATE, offset, 0, 0);
+	PAL_CALL(iprv, PAL_MC_DYNAMIC_STATE, info_type, dy_buffer, 0);
 	if (size)
 		*size =3D iprv.v0;
-	if (pds)
-		*pds =3D iprv.v1;
 	return iprv.status;
 }
=20
@@ -1281,15 +1286,41 @@ ia64_pal_mc_expected (u64 expected, u64=20
 	return iprv.status;
 }
=20
+typedef union pal_hw_tracking_u {
+	u64			pht_data;
+	struct {
+		u64		itc	:4,	/* Instruction cache tracking */
+				dct	:4,	/* Date cache tracking */
+				itt	:4,	/* Instruction TLB tracking */
+				ddt	:4,	/* Data TLB tracking */
+				reserved:48;
+	} pal_hw_tracking_s;
+} pal_hw_tracking_u_t;
+
+/*
+ * Hardware tracking status.
+ */
+static inline s64
+ia64_pal_mc_hw_tracking (u64 *status)
+{
+	struct ia64_pal_retval iprv;
+	PAL_CALL(iprv, PAL_MC_HW_TRACKING, 0, 0, 0);
+	if (status)
+		*status =3D iprv.v0;
+	return iprv.status;
+}
+
 /* Register a platform dependent location with PAL to which it can save
  * minimal processor state in the event of a machine check or initializati=
on
  * event.
  */
 static inline s64
-ia64_pal_mc_register_mem (u64 physical_addr)
+ia64_pal_mc_register_mem (u64 physical_addr, u64 size, u64 *req_size)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_MC_REGISTER_MEM, physical_addr, 0, 0);
+	PAL_CALL(iprv, PAL_MC_REGISTER_MEM, physical_addr, size, 0);
+	if (req_size)
+		*req_size =3D iprv.v0;
 	return iprv.status;
 }
=20
@@ -1628,6 +1659,29 @@ ia64_pal_vm_summary (pal_vm_info_1_u_t *
 		vm_info_1->pvi1_val =3D iprv.v0;
 	if (vm_info_2)
 		vm_info_2->pvi2_val =3D iprv.v1;
+	return iprv.status;
+}
+
+typedef union pal_vp_info_u {
+	u64			pvi_val;
+	struct {
+		u64		index:		48,	/* virtual feature set info */
+				vmm_id:		16;	/* feature set id */
+	} pal_vp_info_s;
+} pal_vp_info_u_t;
+
+/*
+ * Returns infomation about virtual processor features
+ */
+static inline s64
+ia64_pal_vp_info (u64 feature_set, u64 vp_buffer, u64 *vp_info, u64 *vmm_i=
d)
+{
+	struct ia64_pal_retval iprv;
+	PAL_CALL(iprv, PAL_VP_INFO, feature_set, vp_buffer, 0);
+	if (vp_info)
+		*vp_info =3D iprv.v0;
+	if (vmm_id)
+		*vmm_id =3D iprv.v1;
 	return iprv.status;
 }
=20
--=20
Russ Anderson, OS RAS/Partitioning Project Lead =20
SGI - Silicon Graphics Inc          rja@sgi.com
