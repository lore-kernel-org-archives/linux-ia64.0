From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 04 Feb 2004 20:55:25 +0000
Subject: [PATCH] Altix - Remove alenlist.h
Message-Id: <20040204205525.GM3387@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="3O1VwFp74L81IIeR"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--3O1VwFp74L81IIeR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi Andrew,

This is a patch that removes the unused include/asm-ia64/sn/alenlist.h
header file, along with the dead code that still referenced it.

I ran the patch by Pat Gefre and Colin Ngam.

The patch is against 2.6.1-rc3-mm1.

Thanks
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--3O1VwFp74L81IIeR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="remove-alenlist-2.diff"

diff -X /home/mort/diffex -uNr linux-2.6.2.orig/arch/ia64/sn/io/io.c linux-2.6.2/arch/ia64/sn/io/io.c
--- linux-2.6.2.orig/arch/ia64/sn/io/io.c	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/arch/ia64/sn/io/io.c	2004-02-04 10:16:22.000000000 -0500
@@ -471,38 +471,8 @@
 }
 
 /*
- * Establish a DMA mapping using the resources allocated in a previous dmamap_alloc.
- * Return an appropriate crosstalk address list that maps to the specified physical 
- * address list.
- */
-/* ARGSUSED */
-alenlist_t
-hub_dmamap_list(hub_dmamap_t hub_dmamap,	/* use these mapping resources */
-		alenlist_t palenlist,		/* map this area of memory */
-		unsigned flags)
-{
-	vertex_hdl_t vhdl;
-
-	ASSERT(hub_dmamap->hdma_flags & HUB_DMAMAP_IS_VALID);
-
-	if (hub_dmamap->hdma_flags & HUB_DMAMAP_USED) {
-	    /* If the map is FIXED, re-use is OK. */
-	    if (!(hub_dmamap->hdma_flags & HUB_DMAMAP_IS_FIXED)) {
-		char name[MAXDEVNAME];
-		vhdl = hub_dmamap->hdma_xtalk_info.xd_dev;
-		printk(KERN_WARNING  "%s: hub_dmamap_list re-uses dmamap\n", vertex_to_name(vhdl, name, MAXDEVNAME));
-	    }
-	} else {
-		hub_dmamap->hdma_flags |= HUB_DMAMAP_USED;
-	}
-
-	/* There isn't actually any DMA mapping hardware on the hub.  */
-	return palenlist;
-}
-
-/*
  * Driver indicates that it has completed whatever DMA it may have started
- * after an earlier dmamap_addr or dmamap_list call.
+ * after an earlier dmamap_addr call.
  */
 void
 hub_dmamap_done(hub_dmamap_t hub_dmamap)	/* done with these mapping resources */
@@ -535,23 +505,6 @@
 	return (PHYS_TO_DMA(paddr));
 }
 
-/*
- * Translate a list of IP27 addresses and lengths into a list of crosstalk 
- * addresses and lengths.  No actual hardware mapping takes place; the hub 
- * has no DMA mapping registers -- crosstalk addresses map directly.
- */
-/* ARGSUSED */
-alenlist_t
-hub_dmatrans_list(	vertex_hdl_t dev,	/* translate for this device */
-			device_desc_t dev_desc,	/* device descriptor */
-			alenlist_t palenlist,	/* system address/length list */
-			unsigned flags)		/* defined in dma.h */
-{
-	BUG();
-	/* no translation needed */
-	return palenlist;
-}
-
 /*ARGSUSED*/
 void
 hub_dmamap_drain(	hub_dmamap_t map)
@@ -568,15 +521,6 @@
     /* XXX- flush caches, if cache coherency WAR is needed */
 }
 
-/*ARGSUSED*/
-void
-hub_dmalist_drain(	vertex_hdl_t vhdl,
-			alenlist_t list)
-{
-    /* XXX- flush caches, if cache coherency WAR is needed */
-}
-
-
 
 /* CONFIGURATION MANAGEMENT */
 
@@ -768,28 +712,25 @@
  * crosstalk bus provider.
  */
 xtalk_provider_t hub_provider = {
-	(xtalk_piomap_alloc_f *)	hub_piomap_alloc,
-	(xtalk_piomap_free_f *)		hub_piomap_free,
-	(xtalk_piomap_addr_f *)		hub_piomap_addr,
-	(xtalk_piomap_done_f *)		hub_piomap_done,
-	(xtalk_piotrans_addr_f *)	hub_piotrans_addr,
-
-	(xtalk_dmamap_alloc_f *)	hub_dmamap_alloc,
-	(xtalk_dmamap_free_f *)		hub_dmamap_free,
-	(xtalk_dmamap_addr_f *)		hub_dmamap_addr,
-	(xtalk_dmamap_list_f *)		hub_dmamap_list,
-	(xtalk_dmamap_done_f *)		hub_dmamap_done,
-	(xtalk_dmatrans_addr_f *)	hub_dmatrans_addr,
-	(xtalk_dmatrans_list_f *)	hub_dmatrans_list,
-	(xtalk_dmamap_drain_f *)	hub_dmamap_drain,
-	(xtalk_dmaaddr_drain_f *)	hub_dmaaddr_drain,
-	(xtalk_dmalist_drain_f *)	hub_dmalist_drain,
-
-	(xtalk_intr_alloc_f *)		hub_intr_alloc,
-	(xtalk_intr_alloc_f *)		hub_intr_alloc_nothd,
-	(xtalk_intr_free_f *)		hub_intr_free,
-	(xtalk_intr_connect_f *)	hub_intr_connect,
-	(xtalk_intr_disconnect_f *)	hub_intr_disconnect,
-	(xtalk_provider_startup_f *)	hub_provider_startup,
-	(xtalk_provider_shutdown_f *)	hub_provider_shutdown,
+	.piomap_alloc	= (xtalk_piomap_alloc_f *) hub_piomap_alloc,
+	.piomap_free	= (xtalk_piomap_free_f *) hub_piomap_free,
+	.piomap_addr	= (xtalk_piomap_addr_f *) hub_piomap_addr,
+	.piomap_done	= (xtalk_piomap_done_f *) hub_piomap_done,
+	.piotrans_addr	= (xtalk_piotrans_addr_f *) hub_piotrans_addr,
+
+	.dmamap_alloc	= (xtalk_dmamap_alloc_f *) hub_dmamap_alloc,
+	.dmamap_free	= (xtalk_dmamap_free_f *) hub_dmamap_free,
+	.dmamap_addr	= (xtalk_dmamap_addr_f *) hub_dmamap_addr,
+	.dmamap_done	= (xtalk_dmamap_done_f *) hub_dmamap_done,
+	.dmatrans_addr	= (xtalk_dmatrans_addr_f *) hub_dmatrans_addr,
+	.dmamap_drain	= (xtalk_dmamap_drain_f *) hub_dmamap_drain,
+	.dmaaddr_drain	= (xtalk_dmaaddr_drain_f *) hub_dmaaddr_drain,
+
+	.intr_alloc	= (xtalk_intr_alloc_f *) hub_intr_alloc,
+	.intr_alloc_nothd = (xtalk_intr_alloc_f *) hub_intr_alloc_nothd,
+	.intr_free	= (xtalk_intr_free_f *)	hub_intr_free,
+	.intr_connect	= (xtalk_intr_connect_f *) hub_intr_connect,
+	.intr_disconnect = (xtalk_intr_disconnect_f *) hub_intr_disconnect,
+	.provider_startup = (xtalk_provider_startup_f *) hub_provider_startup,
+	.provider_shutdown = (xtalk_provider_shutdown_f *) hub_provider_shutdown,
 };
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c linux-2.6.2/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c
--- linux-2.6.2.orig/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	2004-02-04 10:12:16.000000000 -0500
@@ -106,7 +106,6 @@
 iopaddr_t               pcibr_dmatrans_addr(vertex_hdl_t, device_desc_t, paddr_t, size_t, unsigned);
 void                    pcibr_dmamap_drain(pcibr_dmamap_t);
 void                    pcibr_dmaaddr_drain(vertex_hdl_t, paddr_t, size_t);
-void                    pcibr_dmalist_drain(vertex_hdl_t, alenlist_t);
 iopaddr_t               pcibr_dmamap_pciaddr_get(pcibr_dmamap_t);
 
 void                    pcibr_provider_startup(vertex_hdl_t);
@@ -2327,17 +2326,6 @@
     xtalk_dmaaddr_drain(xconn_vhdl, paddr, bytes);
 }
 
-void
-pcibr_dmalist_drain(vertex_hdl_t pconn_vhdl,
-		    alenlist_t list)
-{
-    pciio_info_t            pciio_info = pciio_info_get(pconn_vhdl);
-    pcibr_soft_t            pcibr_soft = (pcibr_soft_t) pciio_info_mfast_get(pciio_info);
-    vertex_hdl_t            xconn_vhdl = pcibr_soft->bs_conn;
-
-    xtalk_dmalist_drain(xconn_vhdl, list);
-}
-
 /*
  * Get the starting PCIbus address out of the given DMA map.
  * This function is supposed to be used by a close friend of PCI bridge
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/arch/ia64/sn/io/sn2/pciio.c linux-2.6.2/arch/ia64/sn/io/sn2/pciio.c
--- linux-2.6.2.orig/arch/ia64/sn/io/sn2/pciio.c	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/arch/ia64/sn/io/sn2/pciio.c	2004-02-04 10:12:16.000000000 -0500
@@ -304,13 +304,6 @@
 	(dev, addr, size);
 }
 
-void
-pciio_dmalist_drain(vertex_hdl_t dev, alenlist_t list)
-{
-    DEV_FUNC(dev, dmalist_drain)
-	(dev, list);
-}
-
 /* =====================================================================
  *          INTERRUPT MANAGEMENT
  *
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/arch/ia64/sn/io/sn2/pic.c linux-2.6.2/arch/ia64/sn/io/sn2/pic.c
--- linux-2.6.2.orig/arch/ia64/sn/io/sn2/pic.c	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/arch/ia64/sn/io/sn2/pic.c	2004-02-04 10:12:16.000000000 -0500
@@ -805,7 +805,6 @@
     (pciio_dmatrans_addr_f *) pcibr_dmatrans_addr,
     (pciio_dmamap_drain_f *) pcibr_dmamap_drain,
     (pciio_dmaaddr_drain_f *) pcibr_dmaaddr_drain,
-    (pciio_dmalist_drain_f *) pcibr_dmalist_drain,
 
     (pciio_intr_alloc_f *) pcibr_intr_alloc,
     (pciio_intr_free_f *) pcibr_intr_free,
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/arch/ia64/sn/io/sn2/xtalk.c linux-2.6.2/arch/ia64/sn/io/sn2/xtalk.c
--- linux-2.6.2.orig/arch/ia64/sn/io/sn2/xtalk.c	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/arch/ia64/sn/io/sn2/xtalk.c	2004-02-04 10:12:16.000000000 -0500
@@ -47,13 +47,10 @@
 xtalk_dmamap_t          xtalk_dmamap_alloc(vertex_hdl_t, device_desc_t, size_t, unsigned);
 void                    xtalk_dmamap_free(xtalk_dmamap_t);
 iopaddr_t               xtalk_dmamap_addr(xtalk_dmamap_t, paddr_t, size_t);
-alenlist_t              xtalk_dmamap_list(xtalk_dmamap_t, alenlist_t, unsigned);
 void                    xtalk_dmamap_done(xtalk_dmamap_t);
 iopaddr_t               xtalk_dmatrans_addr(vertex_hdl_t, device_desc_t, paddr_t, size_t, unsigned);
-alenlist_t              xtalk_dmatrans_list(vertex_hdl_t, device_desc_t, alenlist_t, unsigned);
 void			xtalk_dmamap_drain(xtalk_dmamap_t);
 void			xtalk_dmaaddr_drain(vertex_hdl_t, iopaddr_t, size_t);
-void			xtalk_dmalist_drain(vertex_hdl_t, alenlist_t);
 xtalk_intr_t            xtalk_intr_alloc(vertex_hdl_t, device_desc_t, vertex_hdl_t);
 xtalk_intr_t            xtalk_intr_alloc_nothd(vertex_hdl_t, device_desc_t, vertex_hdl_t);
 void                    xtalk_intr_free(xtalk_intr_t);
@@ -352,16 +349,6 @@
 }
 
 
-alenlist_t
-xtalk_dmamap_list(xtalk_dmamap_t xtalk_dmamap,	/* use these mapping resources */
-		  alenlist_t alenlist,	/* map this Address/Length List */
-		  unsigned flags)
-{
-    return DMAMAP_FUNC(xtalk_dmamap, dmamap_list)
-	(CAST_DMAMAP(xtalk_dmamap), alenlist, flags);
-}
-
-
 void
 xtalk_dmamap_done(xtalk_dmamap_t xtalk_dmamap)
 {
@@ -382,16 +369,6 @@
 }
 
 
-alenlist_t
-xtalk_dmatrans_list(vertex_hdl_t dev,	/* translate for this device */
-		    device_desc_t dev_desc,	/* device descriptor */
-		    alenlist_t palenlist,	/* system address/length list */
-		    unsigned flags)
-{				/* defined in dma.h */
-    return DEV_FUNC(dev, dmatrans_list)
-	(dev, dev_desc, palenlist, flags);
-}
-
 void
 xtalk_dmamap_drain(xtalk_dmamap_t map)
 {
@@ -406,13 +383,6 @@
 	(dev, addr, size);
 }
 
-void
-xtalk_dmalist_drain(vertex_hdl_t dev, alenlist_t list)
-{
-    DEV_FUNC(dev, dmalist_drain)
-	(dev, list);
-}
-
 /* =====================================================================
  *                    INTERRUPT MANAGEMENT
  *
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/include/asm-ia64/sn/alenlist.h linux-2.6.2/include/asm-ia64/sn/alenlist.h
--- linux-2.6.2.orig/include/asm-ia64/sn/alenlist.h	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/include/asm-ia64/sn/alenlist.h	1969-12-31 19:00:00.000000000 -0500
@@ -1,204 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992 - 1997, 2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-#ifndef _ASM_IA64_SN_ALENLIST_H
-#define _ASM_IA64_SN_ALENLIST_H
-
-#include <linux/types.h>
-
-/* Definition of Address/Length List */
-
-/*
- * An Address/Length List is used when setting up for an I/O DMA operation.
- * A driver creates an Address/Length List that describes to the the DMA 
- * interface where in memory the DMA should go.  The bus interface sets up 
- * mapping registers, if required, and returns a suitable list of "physical 
- * addresses" or "I/O address" to the driver.  The driver then uses these 
- * to set up an appropriate scatter/gather operation(s).
- */
-
-#ifdef __cplusplus
-extern "C" {
-#endif
-
-/*
- * An Address/Length List Address.  It'll get cast to the appropriate type,
- * and must be big enough to hold the largest possible address in any
- * supported address space.
- */
-typedef u64 alenaddr_t;
-typedef u64 uvaddr_t;
-
-typedef struct alenlist_s *alenlist_t;
-
-/* 
- * For tracking progress as we walk down an address/length list.
- */
-typedef struct alenlist_cursor_s *alenlist_cursor_t;
-
-/*
- * alenlist representation that can be passed via an idl
- */
-struct external_alenlist {
-	alenaddr_t	addr;
-	size_t		len;
-};
-typedef struct external_alenlist *external_alenlist_t;
-
-
-/* Return codes from alenlist routines.  */
-#define ALENLIST_FAILURE (-1)
-#define ALENLIST_SUCCESS 0
-
-
-/* Flags to alenlist routines */
-#define AL_NOSLEEP	0x01		/* Do not sleep, waiting for memory */
-#define AL_NOCOMPACT	0x02		/* Do not try to compact adjacent entries */
-#define AL_LEAVE_CURSOR	0x04		/* Do not update cursor */
-
-
-/* Create an Address/Length List, and clear it of all entries.  */
-extern alenlist_t alenlist_create(unsigned int flags);
-
-/* Grow/shrink an Address/Length List and FIX its size. */
-extern int alenlist_grow(alenlist_t, size_t npairs);
-
-/* Clear an Address/Length List so that it now describes 0 pairs. */
-extern void alenlist_clear(alenlist_t alenlist);
-
-/*
- * Convenience function to create an Address/Length List and then append 
- * the specified Address/Length Pair.  Exactly the same as alenlist_create 
- * followed by alenlist_append.  Can be used when a small list (e.g. 1 pair)
- * is adequate.
- */
-extern alenlist_t
-alenpair_init(	alenaddr_t address, 			/* init to this address */
-		size_t length);				/* init to this length */
-
-/* 
- * Peek at the head of an Address/Length List.  This does *NOT* update
- * the internal cursor.
- */
-extern int
-alenpair_get(	alenlist_t alenlist,		/* in: get from this List */
-		alenaddr_t *address,		/* out: address */
-		size_t *length);		/* out: length */
-
-/* Free the space consumed by an Address/Length List. */
-extern void alenlist_destroy(alenlist_t alenlist);
-
-/*
- * Indicate that we're done using an Address/Length List.
- * If we are the last user, destroy the List.
- */
-extern void
-alenlist_done(alenlist_t alenlist);
-
-/* Append another Pair to a List */
-extern int alenlist_append(alenlist_t alenlist, 	/* append to this list */
-			alenaddr_t address,		/* address to append */
-			size_t length,			/* length to append */
-			unsigned int flags);
-
-/* 
- * Replace a Pair in the middle of a List, and return old values.
- * (not generally useful for drivers; used by bus providers).
- */
-extern int
-alenlist_replace(	alenlist_t alenlist, 		/* in: replace in this list */
-			alenlist_cursor_t cursorp,	/* inout: which item to replace */
-			alenaddr_t *addrp, 		/* inout: address */
-			size_t *lengthp,		/* inout: length */
-			unsigned int flags);
-
-
-/* Get the next Pair from a List */
-extern int alenlist_get(alenlist_t alenlist, 		/* in: get from this list */
-			alenlist_cursor_t cursorp,	/* inout: which item to get */
-			size_t maxlength,		/* in: at most length */
-			alenaddr_t *addr, 		/* out: address */
-			size_t *length,			/* out: length */
-			unsigned int flags);
-
-
-/* Return the number of Pairs stored in this List */
-extern int alenlist_size(alenlist_t alenlist);
-
-/* Concatenate two Lists. */
-extern void alenlist_concat(	alenlist_t from, 	/* copy from this list */
-				alenlist_t to);		/* to this list */
-
-/* Create a copy of an Address/Length List */
-extern alenlist_t alenlist_clone(alenlist_t old,	/* clone this list */
-				 unsigned int flags);
-
-
-/* Allocate and initialize an Address/Length List Cursor */
-extern alenlist_cursor_t alenlist_cursor_create(alenlist_t alenlist, unsigned int flags);
-
-/* Free an Address/Length List Cursor */
-extern void alenlist_cursor_destroy(alenlist_cursor_t cursorp);
-
-/*
- * Initialize an Address/Length List Cursor in order to walk thru an
- * Address/Length List from the beginning.
- */
-extern int alenlist_cursor_init(alenlist_t alenlist, 
-				size_t offset, 
-				alenlist_cursor_t cursorp);
-
-/* Clone an Address/Length List Cursor. */
-extern int alenlist_cursor_clone(alenlist_t alenlist, 
-				alenlist_cursor_t cursorp_in, 
-				alenlist_cursor_t cursorp_out);
-
-/* 
- * Return the number of bytes passed so far according to the specified
- * Address/Length List Cursor.
- */
-extern size_t alenlist_cursor_offset(alenlist_t alenlist, alenlist_cursor_t cursorp);
-
-
-
-
-/* Convert from a Kernel Virtual Address to a Physical Address/Length List */
-extern alenlist_t kvaddr_to_alenlist(	alenlist_t alenlist, 
-					caddr_t kvaddr, 
-					size_t length, 
-					unsigned int flags);
-
-/* Convert from a User Virtual Address to a Physical Address/Length List */
-extern alenlist_t uvaddr_to_alenlist(	alenlist_t alenlist,
-					uvaddr_t vaddr, 
-					size_t length,
-					unsigned int flags);
-
-/* Convert from a buf struct to a Physical Address/Length List */
-struct buf;
-extern alenlist_t buf_to_alenlist(	alenlist_t alenlist, 
-					struct buf *buf, 
-					unsigned int flags);
-
-
-/* 
- * Tracking position as we walk down an Address/Length List.
- * This structure is NOT generally for use by device drivers.
- */
-struct alenlist_cursor_s {
-	struct alenlist_s	*al_alenlist;	/* which list */
-	size_t			al_offset;	/* total bytes passed by cursor */
-	struct alenlist_chunk_s	*al_chunk;	/* which chunk in alenlist */
-	unsigned int		al_index;	/* which pair in chunk */
-	size_t			al_bcount;	/* offset into address/length pair */
-};
-
-#ifdef __cplusplus
-}
-#endif
-
-#endif /* _ASM_IA64_SN_ALENLIST_H */
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/include/asm-ia64/sn/pci/pcibr.h linux-2.6.2/include/asm-ia64/sn/pci/pcibr.h
--- linux-2.6.2.orig/include/asm-ia64/sn/pci/pcibr.h	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/include/asm-ia64/sn/pci/pcibr.h	2004-02-04 10:12:19.000000000 -0500
@@ -119,10 +119,6 @@
 					  paddr_t paddr,
 					  size_t byte_count);
 
-extern alenlist_t	pcibr_dmamap_list(pcibr_dmamap_t dmamap,
-					  alenlist_t palenlist,
-					  unsigned flags);
-
 extern void		pcibr_dmamap_done(pcibr_dmamap_t dmamap);
 
 /*
@@ -139,20 +135,12 @@
 					    size_t byte_count,
 					    unsigned flags);
 
-extern alenlist_t	pcibr_dmatrans_list(vertex_hdl_t dev,
-					    device_desc_t dev_desc,
-					    alenlist_t palenlist,
-					    unsigned flags);
-
 extern void		pcibr_dmamap_drain(pcibr_dmamap_t map);
 
 extern void		pcibr_dmaaddr_drain(vertex_hdl_t vhdl,
 					    paddr_t addr,
 					    size_t bytes);
 
-extern void		pcibr_dmalist_drain(vertex_hdl_t vhdl,
-					    alenlist_t list);
-
 typedef unsigned	pcibr_intr_ibit_f(pciio_info_t info,
 					  pciio_intr_line_t lines);
 
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/include/asm-ia64/sn/pci/pciio.h linux-2.6.2/include/asm-ia64/sn/pci/pciio.h
--- linux-2.6.2.orig/include/asm-ia64/sn/pci/pciio.h	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/include/asm-ia64/sn/pci/pciio.h	2004-02-04 10:12:19.000000000 -0500
@@ -28,10 +28,8 @@
 
 #ifdef __KERNEL__
 #include <asm/sn/dmamap.h>
-#include <asm/sn/alenlist.h>
 #else
 #include <dmamap.h>
-#include <alenlist.h>
 #endif
 
 typedef int pciio_vendor_id_t;
@@ -99,10 +97,6 @@
  *	sleep waiting for resoruces, return an error
  *	instead. (PIOMAP_NOSLEEP and DMAMAP_NOSLEEP are
  *	the same numeric value and are acceptable).
- * PCIIO_INPLACE: when operating on alenlist structures,
- *	reuse the source alenlist rather than creating a
- *	new one. (PIOMAP_INPLACE and DMAMAP_INPLACE are
- *	the same numeric value and are acceptable).
  *
  * PCIIO_DMA_CMD: configure this stream as a
  *	generic "command" stream. Generally this
@@ -162,7 +156,6 @@
 
 #define	PCIIO_FIXED		DMAMAP_FIXED
 #define	PCIIO_NOSLEEP		DMAMAP_NOSLEEP
-#define	PCIIO_INPLACE		DMAMAP_INPLACE
 
 #define PCIIO_DMA_CMD		0x0010
 #define PCIIO_DMA_DATA		0x0020
@@ -398,9 +391,6 @@
 			 paddr_t addr,
 			 size_t bytes);
 
-typedef void
-pciio_dmalist_drain_f	(vertex_hdl_t vhdl,
-			 alenlist_t list);
 
 /* INTERRUPT MANAGEMENT */
 
@@ -494,7 +484,6 @@
     pciio_dmatrans_addr_f  *dmatrans_addr;
     pciio_dmamap_drain_f   *dmamap_drain;
     pciio_dmaaddr_drain_f  *dmaaddr_drain;
-    pciio_dmalist_drain_f  *dmalist_drain;
 
     /* INTERRUPT MANAGEMENT */
     pciio_intr_alloc_f     *intr_alloc;
@@ -536,7 +525,6 @@
 extern pciio_dmatrans_addr_f pciio_dmatrans_addr;
 extern pciio_dmamap_drain_f pciio_dmamap_drain;
 extern pciio_dmaaddr_drain_f pciio_dmaaddr_drain;
-extern pciio_dmalist_drain_f pciio_dmalist_drain;
 extern pciio_intr_alloc_f pciio_intr_alloc;
 extern pciio_intr_free_f pciio_intr_free;
 extern pciio_intr_connect_f pciio_intr_connect;
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/include/asm-ia64/sn/sn2/shubio.h linux-2.6.2/include/asm-ia64/sn/sn2/shubio.h
--- linux-2.6.2.orig/include/asm-ia64/sn/sn2/shubio.h	2004-02-03 22:43:45.000000000 -0500
+++ linux-2.6.2/include/asm-ia64/sn/sn2/shubio.h	2004-02-04 10:12:19.000000000 -0500
@@ -3385,7 +3385,6 @@
 #define IO_PERF_SETS	32
 
 #if __KERNEL__
-#include <asm/sn/alenlist.h>
 #include <asm/sn/dmamap.h>
 #include <asm/sn/driver.h>
 #include <asm/sn/xtalk/xtalk.h>
@@ -3530,11 +3529,6 @@
                         paddr_t paddr,          /* map for this address */
                         size_t byte_count);     /* map this many bytes */
 
-extern alenlist_t
-hub_dmamap_list(        hub_dmamap_t dmamap,    /* use mapping resources */
-                        alenlist_t alenlist,    /* map this Addr/Length List */
-                        unsigned flags);
-
 extern void
 hub_dmamap_done(        hub_dmamap_t dmamap);   /* done w/ mapping resources */
 
@@ -3545,12 +3539,6 @@
                         size_t byte_count,      /* length */
                         unsigned flags);                /* defined in dma.h */
 
-extern alenlist_t
-hub_dmatrans_list(      vertex_hdl_t dev,       /* translate for this device */
-                        device_desc_t dev_desc, /* device descriptor */
-                        alenlist_t palenlist,   /* system addr/length list */
-                        unsigned flags);                /* defined in dma.h */
-
 extern void
 hub_dmamap_drain(       hub_dmamap_t map);
 
@@ -3559,10 +3547,6 @@
                         paddr_t addr,
                         size_t bytes);
 
-extern void
-hub_dmalist_drain(      vertex_hdl_t vhdl,
-                        alenlist_t list);
-
 
 /* INTERRUPT MANAGEMENT */
 typedef struct hub_intr_s *hub_intr_t;
diff -X /home/mort/diffex -uNr linux-2.6.2.orig/include/asm-ia64/sn/xtalk/xtalk.h linux-2.6.2/include/asm-ia64/sn/xtalk/xtalk.h
--- linux-2.6.2.orig/include/asm-ia64/sn/xtalk/xtalk.h	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2/include/asm-ia64/sn/xtalk/xtalk.h	2004-02-04 10:20:23.000000000 -0500
@@ -59,7 +59,6 @@
 
 #include <asm/types.h>
 #include <asm/sn/types.h>
-#include <asm/sn/alenlist.h>
 #include <asm/sn/ioerror.h>
 #include <asm/sn/driver.h>
 #include <asm/sn/dmamap.h>
@@ -78,14 +77,9 @@
  *	sleep waiting for resoruces, return an error
  *	instead. (PIOMAP_NOSLEEP and DMAMAP_NOSLEEP are
  *	the same numeric value and are acceptable).
- * XTALK_INPLACE: when operating on alenlist structures,
- *	reuse the source alenlist rather than creating a
- *	new one. (PIOMAP_INPLACE and DMAMAP_INPLACE are
- *	the same numeric value and are acceptable).
  */
 #define	XTALK_FIXED		DMAMAP_FIXED
 #define	XTALK_NOSLEEP		DMAMAP_NOSLEEP
-#define	XTALK_INPLACE		DMAMAP_INPLACE
 
 /* PIO MANAGEMENT */
 typedef xtalk_piomap_t
@@ -139,11 +133,6 @@
 			 paddr_t paddr,		/* map for this address */
 			 size_t byte_count);	/* map this many bytes */
 
-typedef alenlist_t
-xtalk_dmamap_list_f     (xtalk_dmamap_t dmamap,		/* use these mapping resources */
-			 alenlist_t alenlist,	/* map this address/length list */
-			 unsigned int flags);
-
 typedef void
 xtalk_dmamap_done_f     (xtalk_dmamap_t dmamap);
 
@@ -154,12 +143,6 @@
 			 size_t byte_count,	/* length */
 			 unsigned int flags);
 
-typedef alenlist_t
-xtalk_dmatrans_list_f   (vertex_hdl_t dev,	/* translate for this device */
-			 device_desc_t dev_desc,	/* device descriptor */
-			 alenlist_t palenlist,	/* system address/length list */
-			 unsigned int flags);
-
 typedef void
 xtalk_dmamap_drain_f	(xtalk_dmamap_t map);	/* drain this map's channel */
 
@@ -168,11 +151,6 @@
 			 paddr_t addr,		/* to this physical address */
 			 size_t bytes);		/* for this many bytes */
 
-typedef void
-xtalk_dmalist_drain_f	(vertex_hdl_t vhdl,	/* drain channel from this device */
-			 alenlist_t list);	/* for this set of physical blocks */
-
-
 /* INTERRUPT MANAGEMENT */
 
 /*
@@ -260,13 +238,10 @@
     xtalk_dmamap_alloc_f   *dmamap_alloc;
     xtalk_dmamap_free_f    *dmamap_free;
     xtalk_dmamap_addr_f    *dmamap_addr;
-    xtalk_dmamap_list_f    *dmamap_list;
     xtalk_dmamap_done_f    *dmamap_done;
     xtalk_dmatrans_addr_f  *dmatrans_addr;
-    xtalk_dmatrans_list_f  *dmatrans_list;
     xtalk_dmamap_drain_f   *dmamap_drain;
     xtalk_dmaaddr_drain_f  *dmaaddr_drain;
-    xtalk_dmalist_drain_f  *dmalist_drain;
 
     /* INTERRUPT MANAGEMENT */
     xtalk_intr_alloc_f     *intr_alloc;
@@ -289,13 +264,10 @@
 extern xtalk_dmamap_alloc_f xtalk_dmamap_alloc;
 extern xtalk_dmamap_free_f xtalk_dmamap_free;
 extern xtalk_dmamap_addr_f xtalk_dmamap_addr;
-extern xtalk_dmamap_list_f xtalk_dmamap_list;
 extern xtalk_dmamap_done_f xtalk_dmamap_done;
 extern xtalk_dmatrans_addr_f xtalk_dmatrans_addr;
-extern xtalk_dmatrans_list_f xtalk_dmatrans_list;
 extern xtalk_dmamap_drain_f xtalk_dmamap_drain;
 extern xtalk_dmaaddr_drain_f xtalk_dmaaddr_drain;
-extern xtalk_dmalist_drain_f xtalk_dmalist_drain;
 extern xtalk_intr_alloc_f xtalk_intr_alloc;
 extern xtalk_intr_alloc_f xtalk_intr_alloc_nothd;
 extern xtalk_intr_free_f xtalk_intr_free;

--3O1VwFp74L81IIeR--
