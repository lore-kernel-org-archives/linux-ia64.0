From: Christoph Hellwig <hch@lst.de>
Date: Sat, 27 Sep 2003 14:25:45 +0000
Subject: [PATCH] kill pciio_provider*
Message-Id: <marc-linux-ia64-106467280726834@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that we go directly to pcibr everywhere we can kill the IRIX
pci midlayer.  Certain helpers in pciio.c stay for now.


diff -Nru a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c
--- a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Sat Sep 27 16:23:18 2003
+++ b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Sat Sep 27 16:23:18 2003
@@ -214,8 +214,6 @@
 extern int              pcibr_dmawr_error(pcibr_soft_t, int, ioerror_mode_t, ioerror_t *);
 extern int              pcibr_error_handler(error_handler_arg_t, int, ioerror_mode_t, ioerror_t *);
 extern int              pcibr_error_handler_wrapper(error_handler_arg_t, int, ioerror_mode_t, ioerror_t *);
-void                    pcibr_provider_startup(vertex_hdl_t);
-void                    pcibr_provider_shutdown(vertex_hdl_t);
 
 int                     pcibr_reset(vertex_hdl_t);
 pciio_endian_t          pcibr_endian_set(vertex_hdl_t, pciio_endian_t, pciio_endian_t);
@@ -957,9 +955,6 @@
     rc = hwgraph_path_add(xconn_vhdl, EDGE_LBL_PCI, &pcibr_vhdl);
     ASSERT(rc = GRAPH_SUCCESS);
 
-    pciio_provider_register(pcibr_vhdl, &pcibr_provider);
-    pciio_provider_startup(pcibr_vhdl);
-
     return pcibr_attach2(xconn_vhdl, bridge, pcibr_vhdl, 0, NULL);
 }
 
@@ -3631,17 +3626,6 @@
 /* ==================================  *    CONFIGURATION MANAGEMENT
  */
-/*ARGSUSED */
-void
-pcibr_provider_startup(vertex_hdl_t pcibr)
-{
-}
-
-/*ARGSUSED */
-void
-pcibr_provider_shutdown(vertex_hdl_t pcibr)
-{
-}
 
 int
 pcibr_reset(vertex_hdl_t conn)
@@ -3933,47 +3917,6 @@
 
     return(percent_allowed);
 }
-
-pciio_provider_t        pcibr_provider -{
-    (pciio_piomap_alloc_f *) pcibr_piomap_alloc,
-    (pciio_piomap_free_f *) pcibr_piomap_free,
-    (pciio_piomap_addr_f *) pcibr_piomap_addr,
-    (pciio_piomap_done_f *) pcibr_piomap_done,
-    (pciio_piotrans_addr_f *) pcibr_piotrans_addr,
-    (pciio_piospace_alloc_f *) pcibr_piospace_alloc,
-    (pciio_piospace_free_f *) pcibr_piospace_free,
-
-    (pciio_dmamap_alloc_f *) pcibr_dmamap_alloc,
-    (pciio_dmamap_free_f *) pcibr_dmamap_free,
-    (pciio_dmamap_addr_f *) pcibr_dmamap_addr,
-    (pciio_dmamap_done_f *) pcibr_dmamap_done,
-    (pciio_dmatrans_addr_f *) pcibr_dmatrans_addr,
-    (pciio_dmamap_drain_f *) pcibr_dmamap_drain,
-    (pciio_dmaaddr_drain_f *) pcibr_dmaaddr_drain,
-    (pciio_dmalist_drain_f *) pcibr_dmalist_drain,
-
-    (pciio_intr_alloc_f *) pcibr_intr_alloc,
-    (pciio_intr_free_f *) pcibr_intr_free,
-    (pciio_intr_connect_f *) pcibr_intr_connect,
-    (pciio_intr_disconnect_f *) pcibr_intr_disconnect,
-    (pciio_intr_cpu_get_f *) pcibr_intr_cpu_get,
-
-    (pciio_provider_startup_f *) pcibr_provider_startup,
-    (pciio_provider_shutdown_f *) pcibr_provider_shutdown,
-    (pciio_reset_f *) pcibr_reset,
-    (pciio_write_gather_flush_f *) pcibr_write_gather_flush,
-    (pciio_endian_set_f *) pcibr_endian_set,
-    (pciio_priority_set_f *) pcibr_priority_set,
-    (pciio_config_get_f *) pcibr_config_get,
-    (pciio_config_set_f *) pcibr_config_set,
-    (pciio_error_devenable_f *) 0,
-    (pciio_error_extract_f *) 0,
-    (pciio_driver_reg_callback_f *) 0,
-    (pciio_driver_unreg_callback_f *) 0,
-    (pciio_device_unregister_f 	*) pcibr_device_unregister,
-    (pciio_dma_enabled_f		*) pcibr_dma_enabled,
-};
 
 int
 pcibr_dma_enabled(vertex_hdl_t pconn_vhdl)
diff -Nru a/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c b/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c
--- a/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c	Sat Sep 27 16:23:18 2003
+++ b/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c	Sat Sep 27 16:23:18 2003
@@ -280,7 +280,6 @@
 #if defined(SUPPORT_PRINTING_V_FORMAT)
     sprintf(funcp->resp_f_master_name, "%v", pcibr_info->f_master);
 #endif
-    funcp->resp_f_pops = pcibr_info->f_pops;
     funcp->resp_f_efunc = pcibr_info->f_efunc;
     funcp->resp_f_einfo = pcibr_info->f_einfo;
 
diff -Nru a/arch/ia64/sn/io/sn2/pciio.c b/arch/ia64/sn/io/sn2/pciio.c
--- a/arch/ia64/sn/io/sn2/pciio.c	Sat Sep 27 16:23:18 2003
+++ b/arch/ia64/sn/io/sn2/pciio.c	Sat Sep 27 16:23:18 2003
@@ -114,66 +114,8 @@
  ******/
 
 
-
-
-/* ==================================- *    PCI Generic Bus Provider
- * Implement PCI provider operations.  The pciio* layer provides a
- * platform-independent interface for PCI devices.  This layer
- * switches among the possible implementations of a PCI adapter.
- */
-
-/* ==================================- *    Provider Function Location SHORTCUT
- *
- * On platforms with only one possible PCI provider, macros can be
- * set up at the top that cause the table lookups and indirections to
- * completely disappear.
- */
-
-
-/* ==================================- *    Function Table of Contents
- */
-
-#if !defined(DEV_FUNC)
-static pciio_provider_t *pciio_to_provider_fns(vertex_hdl_t dev);
-#endif
-
-pciio_piomap_t          pciio_piomap_alloc(vertex_hdl_t, device_desc_t, pciio_space_t, iopaddr_t, size_t, size_t, unsigned);
-void                    pciio_piomap_free(pciio_piomap_t);
-caddr_t                 pciio_piomap_addr(pciio_piomap_t, iopaddr_t, size_t);
-
-void                    pciio_piomap_done(pciio_piomap_t);
-caddr_t                 pciio_piotrans_addr(vertex_hdl_t, device_desc_t, pciio_space_t, iopaddr_t, size_t, unsigned);
-caddr_t			pciio_pio_addr(vertex_hdl_t, device_desc_t, pciio_space_t, iopaddr_t, size_t, pciio_piomap_t *, unsigned);
-
-iopaddr_t               pciio_piospace_alloc(vertex_hdl_t, device_desc_t, pciio_space_t, size_t, size_t);
-void                    pciio_piospace_free(vertex_hdl_t, pciio_space_t, iopaddr_t, size_t);
-
-pciio_dmamap_t          pciio_dmamap_alloc(vertex_hdl_t, device_desc_t, size_t, unsigned);
-void                    pciio_dmamap_free(pciio_dmamap_t);
-iopaddr_t               pciio_dmamap_addr(pciio_dmamap_t, paddr_t, size_t);
-void                    pciio_dmamap_done(pciio_dmamap_t);
-iopaddr_t               pciio_dmatrans_addr(vertex_hdl_t, device_desc_t, paddr_t, size_t, unsigned);
-void			pciio_dmamap_drain(pciio_dmamap_t);
-void			pciio_dmaaddr_drain(vertex_hdl_t, paddr_t, size_t);
-void			pciio_dmalist_drain(vertex_hdl_t, alenlist_t);
-iopaddr_t               pciio_dma_addr(vertex_hdl_t, device_desc_t, paddr_t, size_t, pciio_dmamap_t *, unsigned);
-
-pciio_intr_t            pciio_intr_alloc(vertex_hdl_t, device_desc_t, pciio_intr_line_t, vertex_hdl_t);
-void                    pciio_intr_free(pciio_intr_t);
-int                     pciio_intr_connect(pciio_intr_t, intr_func_t, intr_arg_t);
-void                    pciio_intr_disconnect(pciio_intr_t);
-vertex_hdl_t            pciio_intr_cpu_get(pciio_intr_t);
-
 void			pciio_slot_func_to_name(char *, pciio_slot_t, pciio_function_t);
 
-void                    pciio_provider_startup(vertex_hdl_t);
-void                    pciio_provider_shutdown(vertex_hdl_t);
-
-pciio_endian_t          pciio_endian_set(vertex_hdl_t, pciio_endian_t, pciio_endian_t);
-pciio_priority_t        pciio_priority_set(vertex_hdl_t, pciio_priority_t);
 vertex_hdl_t            pciio_intr_dev_get(pciio_intr_t);
 
 vertex_hdl_t            pciio_pio_dev_get(pciio_piomap_t);
@@ -196,7 +138,6 @@
 pciio_device_id_t       pciio_info_device_id_get(pciio_info_t);
 vertex_hdl_t            pciio_info_master_get(pciio_info_t);
 arbitrary_info_t        pciio_info_mfast_get(pciio_info_t);
-pciio_provider_t       *pciio_info_pops_get(pciio_info_t);
 error_handler_f	       *pciio_info_efunc_get(pciio_info_t);
 error_handler_arg_t    *pciio_info_einfo_get(pciio_info_t);
 pciio_space_t		pciio_info_bar_space_get(pciio_info_t, int);
@@ -207,10 +148,6 @@
 
 int                     pciio_attach(vertex_hdl_t);
 
-void                    pciio_provider_register(vertex_hdl_t, pciio_provider_t *pciio_fns);
-void                    pciio_provider_unregister(vertex_hdl_t);
-pciio_provider_t       *pciio_provider_fns_get(vertex_hdl_t);
-
 int                     pciio_driver_register(pciio_vendor_id_t, pciio_device_id_t, char *driver_prefix, unsigned);
 
 vertex_hdl_t            pciio_device_register(vertex_hdl_t, vertex_hdl_t, pciio_slot_t, pciio_function_t, pciio_vendor_id_t, pciio_device_id_t);
@@ -224,331 +161,6 @@
 int			pciio_device_detach(vertex_hdl_t, int);
 void                    pciio_error_register(vertex_hdl_t, error_handler_f *, error_handler_arg_t);
 
-int                     pciio_reset(vertex_hdl_t);
-int                     pciio_write_gather_flush(vertex_hdl_t);
-int                     pciio_slot_inuse(vertex_hdl_t);
-
-/* ==================================- *    Provider Function Location
- *
- *      If there is more than one possible provider for
- *      this platform, we need to examine the master
- *      vertex of the current vertex for a provider
- *      function structure, and indirect through the
- *      appropriately named member.
- */
-
-#if !defined(DEV_FUNC)
-
-static pciio_provider_t *
-pciio_to_provider_fns(vertex_hdl_t dev)
-{
-    pciio_info_t            card_info;
-    pciio_provider_t       *provider_fns;
-
-    /*
-     * We're called with two types of vertices, one is
-     * the bridge vertex (ends with "pci") and the other is the
-     * pci slot vertex (ends with "pci/[0-8]").  For the first type
-     * we need to get the provider from the PFUNCS label.  For
-     * the second we get it from fastinfo/c_pops.
-     */
-    provider_fns = pciio_provider_fns_get(dev);
-    if (provider_fns = NULL) {
-	card_info = pciio_info_get(dev);
-	if (card_info != NULL) {
-		provider_fns = pciio_info_pops_get(card_info);
-	}
-    }
-
-    if (provider_fns = NULL)
-#if defined(SUPPORT_PRINTING_V_FORMAT)
-	PRINT_PANIC("%v: provider_fns = NULL", dev);
-#else
-	PRINT_PANIC("0x%p: provider_fns = NULL", (void *)dev);
-#endif
-
-    return provider_fns;
-
-}
-
-#define DEV_FUNC(dev,func)	pciio_to_provider_fns(dev)->func
-#define CAST_PIOMAP(x)		((pciio_piomap_t)(x))
-#define CAST_DMAMAP(x)		((pciio_dmamap_t)(x))
-#define CAST_INTR(x)		((pciio_intr_t)(x))
-#endif
-
-/*
- * Many functions are not passed their vertex
- * information directly; rather, they must
- * dive through a resource map. These macros
- * are available to coordinate this detail.
- */
-#define PIOMAP_FUNC(map,func)		DEV_FUNC((map)->pp_dev,func)
-#define DMAMAP_FUNC(map,func)		DEV_FUNC((map)->pd_dev,func)
-#define INTR_FUNC(intr_hdl,func)	DEV_FUNC((intr_hdl)->pi_dev,func)
-
-/* ==================================- *          PIO MANAGEMENT
- *
- *      For mapping system virtual address space to
- *      pciio space on a specified card
- */
-
-pciio_piomap_t
-pciio_piomap_alloc(vertex_hdl_t dev,	/* set up mapping for this device */
-		   device_desc_t dev_desc,	/* device descriptor */
-		   pciio_space_t space,	/* CFG, MEM, IO, or a device-decoded window */
-		   iopaddr_t addr,	/* lowest address (or offset in window) */
-		   size_t byte_count,	/* size of region containing our mappings */
-		   size_t byte_count_max,	/* maximum size of a mapping */
-		   unsigned flags)
-{					/* defined in sys/pio.h */
-    return (pciio_piomap_t) DEV_FUNC(dev, piomap_alloc)
-	(dev, dev_desc, space, addr, byte_count, byte_count_max, flags);
-}
-
-void
-pciio_piomap_free(pciio_piomap_t pciio_piomap)
-{
-    PIOMAP_FUNC(pciio_piomap, piomap_free)
-	(CAST_PIOMAP(pciio_piomap));
-}
-
-caddr_t
-pciio_piomap_addr(pciio_piomap_t pciio_piomap,	/* mapping resources */
-		  iopaddr_t pciio_addr,	/* map for this pciio address */
-		  size_t byte_count)
-{					/* map this many bytes */
-    pciio_piomap->pp_kvaddr = PIOMAP_FUNC(pciio_piomap, piomap_addr)
-	(CAST_PIOMAP(pciio_piomap), pciio_addr, byte_count);
-
-    return pciio_piomap->pp_kvaddr;
-}
-
-void
-pciio_piomap_done(pciio_piomap_t pciio_piomap)
-{
-    PIOMAP_FUNC(pciio_piomap, piomap_done)
-	(CAST_PIOMAP(pciio_piomap));
-}
-
-caddr_t
-pciio_piotrans_addr(vertex_hdl_t dev,	/* translate for this device */
-		    device_desc_t dev_desc,	/* device descriptor */
-		    pciio_space_t space,	/* CFG, MEM, IO, or a device-decoded window */
-		    iopaddr_t addr,	/* starting address (or offset in window) */
-		    size_t byte_count,	/* map this many bytes */
-		    unsigned flags)
-{					/* (currently unused) */
-    return DEV_FUNC(dev, piotrans_addr)
-	(dev, dev_desc, space, addr, byte_count, flags);
-}
-
-
-iopaddr_t
-pciio_piospace_alloc(vertex_hdl_t dev,	/* Device requiring space */
-		     device_desc_t dev_desc,	/* Device descriptor */
-		     pciio_space_t space,	/* MEM32/MEM64/IO */
-		     size_t byte_count,	/* Size of mapping */
-		     size_t align)
-{					/* Alignment needed */
-    if (align < NBPP)
-	align = NBPP;
-    return DEV_FUNC(dev, piospace_alloc)
-	(dev, dev_desc, space, byte_count, align);
-}
-
-void
-pciio_piospace_free(vertex_hdl_t dev,	/* Device freeing space */
-		    pciio_space_t space,	/* Type of space        */
-		    iopaddr_t pciaddr,	/* starting address */
-		    size_t byte_count)
-{					/* Range of address   */
-    DEV_FUNC(dev, piospace_free)
-	(dev, space, pciaddr, byte_count);
-}
-
-/* ==================================- *          DMA MANAGEMENT
- *
- *      For mapping from pci space to system
- *      physical space.
- */
-
-pciio_dmamap_t
-pciio_dmamap_alloc(vertex_hdl_t dev,	/* set up mappings for this device */
-		   device_desc_t dev_desc,	/* device descriptor */
-		   size_t byte_count_max,	/* max size of a mapping */
-		   unsigned flags)
-{					/* defined in dma.h */
-    return (pciio_dmamap_t) DEV_FUNC(dev, dmamap_alloc)
-	(dev, dev_desc, byte_count_max, flags);
-}
-
-void
-pciio_dmamap_free(pciio_dmamap_t pciio_dmamap)
-{
-    DMAMAP_FUNC(pciio_dmamap, dmamap_free)
-	(CAST_DMAMAP(pciio_dmamap));
-}
-
-iopaddr_t
-pciio_dmamap_addr(pciio_dmamap_t pciio_dmamap,	/* use these mapping resources */
-		  paddr_t paddr,	/* map for this address */
-		  size_t byte_count)
-{					/* map this many bytes */
-    return DMAMAP_FUNC(pciio_dmamap, dmamap_addr)
-	(CAST_DMAMAP(pciio_dmamap), paddr, byte_count);
-}
-
-void
-pciio_dmamap_done(pciio_dmamap_t pciio_dmamap)
-{
-    DMAMAP_FUNC(pciio_dmamap, dmamap_done)
-	(CAST_DMAMAP(pciio_dmamap));
-}
-
-iopaddr_t
-pciio_dmatrans_addr(vertex_hdl_t dev,	/* translate for this device */
-		    device_desc_t dev_desc,	/* device descriptor */
-		    paddr_t paddr,	/* system physical address */
-		    size_t byte_count,	/* length */
-		    unsigned flags)
-{					/* defined in dma.h */
-    return DEV_FUNC(dev, dmatrans_addr)
-	(dev, dev_desc, paddr, byte_count, flags);
-}
-
-iopaddr_t
-pciio_dma_addr(vertex_hdl_t dev,	/* translate for this device */
-	       device_desc_t dev_desc,	/* device descriptor */
-	       paddr_t paddr,		/* system physical address */
-	       size_t byte_count,	/* length */
-	       pciio_dmamap_t *mapp,	/* map to use, then map we used */
-	       unsigned flags)
-{					/* PIO flags */
-    pciio_dmamap_t          map = 0;
-    int			    errfree = 0;
-    iopaddr_t               res;
-
-    if (mapp) {
-	map = *mapp;			/* possible pre-allocated map */
-	*mapp = 0;			/* record "no map used" */
-    }
-
-    res = pciio_dmatrans_addr
-	(dev, dev_desc, paddr, byte_count, flags);
-    if (res)
-	return res;			/* pciio_dmatrans worked */
-
-    if (!map) {
-	map = pciio_dmamap_alloc
-	    (dev, dev_desc, byte_count, flags);
-	if (!map)
-	    return res;			/* pciio_dmamap_alloc failed */
-	errfree = 1;
-    }
-
-    res = pciio_dmamap_addr
-	(map, paddr, byte_count);
-    if (!res) {
-	if (errfree)
-	    pciio_dmamap_free(map);
-	return res;			/* pciio_dmamap_addr failed */
-    }
-    if (mapp)
-	*mapp = map;			/* pass back map used */
-
-    return res;				/* pciio_dmamap_addr succeeded */
-}
-
-void
-pciio_dmamap_drain(pciio_dmamap_t map)
-{
-    DMAMAP_FUNC(map, dmamap_drain)
-	(CAST_DMAMAP(map));
-}
-
-void
-pciio_dmaaddr_drain(vertex_hdl_t dev, paddr_t addr, size_t size)
-{
-    DEV_FUNC(dev, dmaaddr_drain)
-	(dev, addr, size);
-}
-
-void
-pciio_dmalist_drain(vertex_hdl_t dev, alenlist_t list)
-{
-    DEV_FUNC(dev, dmalist_drain)
-	(dev, list);
-}
-
-/* ==================================- *          INTERRUPT MANAGEMENT
- *
- *      Allow crosstalk devices to establish interrupts
- */
-
-/*
- * Allocate resources required for an interrupt as specified in intr_desc.
- * Return resource handle in intr_hdl.
- */
-pciio_intr_t
-pciio_intr_alloc(vertex_hdl_t dev,	/* which Crosstalk device */
-		 device_desc_t dev_desc,	/* device descriptor */
-		 pciio_intr_line_t lines,	/* INTR line(s) to attach */
-		 vertex_hdl_t owner_dev)
-{					/* owner of this interrupt */
-    return (pciio_intr_t) DEV_FUNC(dev, intr_alloc)
-	(dev, dev_desc, lines, owner_dev);
-}
-
-/*
- * Free resources consumed by intr_alloc.
- */
-void
-pciio_intr_free(pciio_intr_t intr_hdl)
-{
-    INTR_FUNC(intr_hdl, intr_free)
-	(CAST_INTR(intr_hdl));
-}
-
-/*
- * Associate resources allocated with a previous pciio_intr_alloc call with the
- * described handler, arg, name, etc.
- *
- * Returns 0 on success, returns <0 on failure.
- */
-int
-pciio_intr_connect(pciio_intr_t intr_hdl,
-		intr_func_t intr_func, intr_arg_t intr_arg)	/* pciio intr resource handle */
-{
-    return INTR_FUNC(intr_hdl, intr_connect)
-	(CAST_INTR(intr_hdl), intr_func, intr_arg);
-}
-
-/*
- * Disassociate handler with the specified interrupt.
- */
-void
-pciio_intr_disconnect(pciio_intr_t intr_hdl)
-{
-    INTR_FUNC(intr_hdl, intr_disconnect)
-	(CAST_INTR(intr_hdl));
-}
-
-/*
- * Return a hwgraph vertex that represents the CPU currently
- * targeted by an interrupt.
- */
-vertex_hdl_t
-pciio_intr_cpu_get(pciio_intr_t intr_hdl)
-{
-    return INTR_FUNC(intr_hdl, intr_cpu_get)
-	(CAST_INTR(intr_hdl));
-}
-
 void
 pciio_slot_func_to_name(char		       *name,
 			pciio_slot_t		slot,
@@ -689,88 +301,6 @@
  *          CONFIGURATION MANAGEMENT
  */
 
-/*
- * Startup a crosstalk provider
- */
-void
-pciio_provider_startup(vertex_hdl_t pciio_provider)
-{
-    DEV_FUNC(pciio_provider, provider_startup)
-	(pciio_provider);
-}
-
-/*
- * Shutdown a crosstalk provider
- */
-void
-pciio_provider_shutdown(vertex_hdl_t pciio_provider)
-{
-    DEV_FUNC(pciio_provider, provider_shutdown)
-	(pciio_provider);
-}
-
-/*
- * Specify endianness constraints.  The driver tells us what the device
- * does and how it would like to see things in memory.  We reply with
- * how things will actually appear in memory.
- */
-pciio_endian_t
-pciio_endian_set(vertex_hdl_t dev,
-		 pciio_endian_t device_end,
-		 pciio_endian_t desired_end)
-{
-    ASSERT((device_end = PCIDMA_ENDIAN_BIG) || (device_end = PCIDMA_ENDIAN_LITTLE));
-    ASSERT((desired_end = PCIDMA_ENDIAN_BIG) || (desired_end = PCIDMA_ENDIAN_LITTLE));
-
-#if DEBUG
-#if defined(SUPPORT_PRINTING_V_FORMAT)
-    printk(KERN_ALERT  "%v: pciio_endian_set is going away.\n"
-	    "\tplease use PCIIO_BYTE_STREAM or PCIIO_WORD_VALUES in your\n"
-	    "\tpciio_dmamap_alloc and pciio_dmatrans calls instead.\n",
-	    dev);
-#else
-    printk(KERN_ALERT  "0x%x: pciio_endian_set is going away.\n"
-	    "\tplease use PCIIO_BYTE_STREAM or PCIIO_WORD_VALUES in your\n"
-	    "\tpciio_dmamap_alloc and pciio_dmatrans calls instead.\n",
-	    dev);
-#endif
-#endif
-
-    return DEV_FUNC(dev, endian_set)
-	(dev, device_end, desired_end);
-}
-
-/*
- * Specify PCI arbitration priority.
- */
-pciio_priority_t
-pciio_priority_set(vertex_hdl_t dev,
-		   pciio_priority_t device_prio)
-{
-    ASSERT((device_prio = PCI_PRIO_HIGH) || (device_prio = PCI_PRIO_LOW));
-
-    return DEV_FUNC(dev, priority_set)
-	(dev, device_prio);
-}
-
-/*
- * Issue a hardware reset to a card.
- */
-int
-pciio_reset(vertex_hdl_t dev)
-{
-    return DEV_FUNC(dev, reset) (dev);
-}
-
-/*
- * flush write gather buffers
- */
-int
-pciio_write_gather_flush(vertex_hdl_t dev)
-{
-    return DEV_FUNC(dev, write_gather_flush) (dev);
-}
-
 vertex_hdl_t
 pciio_intr_dev_get(pciio_intr_t pciio_intr)
 {
@@ -912,12 +442,6 @@
     return (pciio_info->c_mfast);
 }
 
-pciio_provider_t       *
-pciio_info_pops_get(pciio_info_t pciio_info)
-{
-    return (pciio_info->c_pops);
-}
-
 error_handler_f	       *
 pciio_info_efunc_get(pciio_info_t pciio_info)
 {
@@ -983,39 +507,6 @@
     return 0;
 }
 
-/*
- * Associate a set of pciio_provider functions with a vertex.
- */
-void
-pciio_provider_register(vertex_hdl_t provider, pciio_provider_t *pciio_fns)
-{
-    hwgraph_info_add_LBL(provider, INFO_LBL_PFUNCS, (arbitrary_info_t) pciio_fns);
-}
-
-/*
- * Disassociate a set of pciio_provider functions with a vertex.
- */
-void
-pciio_provider_unregister(vertex_hdl_t provider)
-{
-    arbitrary_info_t        ainfo;
-
-    hwgraph_info_remove_LBL(provider, INFO_LBL_PFUNCS, (long *) &ainfo);
-}
-
-/*
- * Obtain a pointer to the pciio_provider functions for a specified Crosstalk
- * provider.
- */
-pciio_provider_t       *
-pciio_provider_fns_get(vertex_hdl_t provider)
-{
-    arbitrary_info_t        ainfo = 0;
-
-    (void) hwgraph_info_get_LBL(provider, INFO_LBL_PFUNCS, &ainfo);
-    return (pciio_provider_t *) ainfo;
-}
-
 /*ARGSUSED4 */
 int
 pciio_driver_register(
@@ -1044,7 +535,7 @@
 void
 pciio_device_unregister(vertex_hdl_t pconn)
 {
-    DEV_FUNC(pconn,device_unregister)(pconn);
+    pcibr_device_unregister(pconn);
 }
 
 pciio_info_t
@@ -1066,7 +557,6 @@
     pciio_info->c_device = device_id;
     pciio_info->c_master = master;
     pciio_info->c_mfast = hwgraph_fastinfo_get(master);
-    pciio_info->c_pops = pciio_provider_fns_get(master);
     pciio_info->c_efunc = 0;
     pciio_info->c_einfo = 0;
 
@@ -1286,12 +776,6 @@
 }
 
 int
-pciio_dma_enabled(vertex_hdl_t pconn_vhdl)
-{
-	return DEV_FUNC(pconn_vhdl, dma_enabled)(pconn_vhdl);
-}
-
-int
 pciio_info_type1_get(pciio_info_t pci_info)
 {
 	return(0);
@@ -1307,7 +791,6 @@
 	int *count_vchan1)
 {
 	vertex_hdl_t dev = PCIDEV_VERTEX(pci_dev);
-
 	return pcibr_rrb_alloc(dev, count_vchan0, count_vchan1);
 }
 EXPORT_SYMBOL(snia_pcibr_rrb_alloc);
@@ -1325,8 +808,6 @@
 	pciio_endian_t desired_end)
 {
 	vertex_hdl_t dev = PCIDEV_VERTEX(pci_dev);
-	
-	return DEV_FUNC(dev, endian_set)
-		(dev, device_end, desired_end);
+	return pcibr_endian_set(dev, device_end, desired_end);
 }
 EXPORT_SYMBOL(snia_pciio_endian_set);
diff -Nru a/arch/ia64/sn/io/sn2/pic.c b/arch/ia64/sn/io/sn2/pic.c
--- a/arch/ia64/sn/io/sn2/pic.c	Sat Sep 27 16:23:18 2003
+++ b/arch/ia64/sn/io/sn2/pic.c	Sat Sep 27 16:23:18 2003
@@ -198,13 +198,6 @@
 		    "pic_attach: pcibr_vhdl0=%v, pcibr_vhdl1=%v\n",
 		    pcibr_vhdl0, pcibr_vhdl1));
 
-	/* register pci provider array */
-	pciio_provider_register(pcibr_vhdl0, &pci_pic_provider);
-	pciio_provider_register(pcibr_vhdl1, &pci_pic_provider);
-
-	pciio_provider_startup(pcibr_vhdl0);
-	pciio_provider_startup(pcibr_vhdl1);
-
 	pcibr_attach2(conn_v0, bridge0, pcibr_vhdl0, 0, &bus0_soft);
 	pcibr_attach2(conn_v1, bridge1, pcibr_vhdl1, 1, &bus1_soft);
 
@@ -218,50 +211,3 @@
 
 	return 0;
 }
-
-/*
- * pci provider functions
- *
- * mostly in pcibr.c but if any are needed here then
- * this might be a way to get them here.
- */
-pciio_provider_t        pci_pic_provider -{
-    (pciio_piomap_alloc_f *) pcibr_piomap_alloc,
-    (pciio_piomap_free_f *) pcibr_piomap_free,
-    (pciio_piomap_addr_f *) pcibr_piomap_addr,
-    (pciio_piomap_done_f *) pcibr_piomap_done,
-    (pciio_piotrans_addr_f *) pcibr_piotrans_addr,
-    (pciio_piospace_alloc_f *) pcibr_piospace_alloc,
-    (pciio_piospace_free_f *) pcibr_piospace_free,
-
-    (pciio_dmamap_alloc_f *) pcibr_dmamap_alloc,
-    (pciio_dmamap_free_f *) pcibr_dmamap_free,
-    (pciio_dmamap_addr_f *) pcibr_dmamap_addr,
-    (pciio_dmamap_done_f *) pcibr_dmamap_done,
-    (pciio_dmatrans_addr_f *) pcibr_dmatrans_addr,
-    (pciio_dmamap_drain_f *) pcibr_dmamap_drain,
-    (pciio_dmaaddr_drain_f *) pcibr_dmaaddr_drain,
-    (pciio_dmalist_drain_f *) pcibr_dmalist_drain,
-
-    (pciio_intr_alloc_f *) pcibr_intr_alloc,
-    (pciio_intr_free_f *) pcibr_intr_free,
-    (pciio_intr_connect_f *) pcibr_intr_connect,
-    (pciio_intr_disconnect_f *) pcibr_intr_disconnect,
-    (pciio_intr_cpu_get_f *) pcibr_intr_cpu_get,
-
-    (pciio_provider_startup_f *) pcibr_provider_startup,
-    (pciio_provider_shutdown_f *) pcibr_provider_shutdown,
-    (pciio_reset_f *) pcibr_reset,
-    (pciio_write_gather_flush_f *) pcibr_write_gather_flush,
-    (pciio_endian_set_f *) pcibr_endian_set,
-    (pciio_priority_set_f *) pcibr_priority_set,
-    (pciio_config_get_f *) pcibr_config_get,
-    (pciio_config_set_f *) pcibr_config_set,
-    (pciio_error_devenable_f *) 0,
-    (pciio_error_extract_f *) 0,
-    (pciio_driver_reg_callback_f *) pcibr_driver_reg_callback,
-    (pciio_driver_unreg_callback_f *) pcibr_driver_unreg_callback,
-    (pciio_device_unregister_f 	*) pcibr_device_unregister,
-    (pciio_dma_enabled_f		*) pcibr_dma_enabled,
-};
diff -Nru a/include/asm-ia64/sn/pci/pcibr.h b/include/asm-ia64/sn/pci/pcibr.h
--- a/include/asm-ia64/sn/pci/pcibr.h	Sat Sep 27 16:23:18 2003
+++ b/include/asm-ia64/sn/pci/pcibr.h	Sat Sep 27 16:23:18 2003
@@ -62,21 +62,6 @@
 extern int		pcibr_attach(vertex_hdl_t);
 
 /* ==================================- *    bus provider function table
- *
- *	Normally, this table is only handed off explicitly
- *	during provider initialization, and the PCI generic
- *	layer will stash a pointer to it in the vertex; however,
- *	exporting it explicitly enables a performance hack in
- *	the generic PCI provider where if we know at compile
- *	time that the only possible PCI provider is a
- *	pcibr, we can go directly to this ops table.
- */
-
-extern pciio_provider_t pcibr_provider;
-extern pciio_provider_t pci_pic_provider;
-
-/* ==================================  *    secondary entry points: pcibr PCI bus provider
  *
  *	These functions are normally exported explicitly by
@@ -451,7 +436,6 @@
         char                    resp_f_slot;
         char                    resp_f_func;
         char                    resp_f_master_name[MAXDEVNAME];
-        void                   *resp_f_pops;
         error_handler_f        *resp_f_efunc;
         error_handler_arg_t     resp_f_einfo;
         int                     resp_f_vendor;
diff -Nru a/include/asm-ia64/sn/pci/pcibr_private.h b/include/asm-ia64/sn/pci/pcibr_private.h
--- a/include/asm-ia64/sn/pci/pcibr_private.h	Sat Sep 27 16:23:18 2003
+++ b/include/asm-ia64/sn/pci/pcibr_private.h	Sat Sep 27 16:23:18 2003
@@ -222,7 +222,6 @@
 #define	f_device	f_c.c_device	/* PCI card "device" code */
 #define	f_master	f_c.c_master	/* PCI bus provider */
 #define	f_mfast		f_c.c_mfast	/* cached fastinfo from c_master */
-#define	f_pops		f_c.c_pops	/* cached provider from c_master */
 #define	f_efunc		f_c.c_efunc	/* error handling function */
 #define	f_einfo		f_c.c_einfo	/* first parameter for efunc */
 #define f_window        f_c.c_window    /* state of BASE regs */
diff -Nru a/include/asm-ia64/sn/pci/pciio.h b/include/asm-ia64/sn/pci/pciio.h
--- a/include/asm-ia64/sn/pci/pciio.h	Sat Sep 27 16:23:18 2003
+++ b/include/asm-ia64/sn/pci/pciio.h	Sat Sep 27 16:23:18 2003
@@ -387,38 +387,6 @@
 
 /* CONFIGURATION MANAGEMENT */
 
-typedef void
-pciio_provider_startup_f (vertex_hdl_t pciio_provider);
-
-typedef void
-pciio_provider_shutdown_f (vertex_hdl_t pciio_provider);
-
-typedef int	
-pciio_reset_f		(vertex_hdl_t conn);	/* pci connection point */
-
-typedef int
-pciio_write_gather_flush_f (vertex_hdl_t dev);    /* Device flushing buffers */
-
-typedef pciio_endian_t			/* actual endianness */
-pciio_endian_set_f      (vertex_hdl_t dev,	/* specify endianness for this device */
-			 pciio_endian_t device_end,	/* endianness of device */
-			 pciio_endian_t desired_end);	/* desired endianness */
-
-typedef pciio_priority_t
-pciio_priority_set_f    (vertex_hdl_t pcicard,
-			 pciio_priority_t device_prio);
-
-typedef uint64_t
-pciio_config_get_f	(vertex_hdl_t conn,	/* pci connection point */
-			 unsigned reg,		/* register byte offset */
-			 unsigned size);	/* width in bytes (1..4) */
-
-typedef void
-pciio_config_set_f	(vertex_hdl_t conn,	/* pci connection point */
-			 unsigned reg,		/* register byte offset */
-			 unsigned size,		/* width in bytes (1..4) */
-			 uint64_t value);	/* value to store */
-
 typedef int
 pciio_error_devenable_f (vertex_hdl_t pconn_vhdl, int error_code);
 
@@ -445,90 +413,6 @@
 typedef int
 pciio_dma_enabled_f		(vertex_hdl_t conn);
 
-/*
- * Adapters that provide a PCI interface adhere to this software interface.
- */
-typedef struct pciio_provider_s {
-    /* PIO MANAGEMENT */
-    pciio_piomap_alloc_f   *piomap_alloc;
-    pciio_piomap_free_f    *piomap_free;
-    pciio_piomap_addr_f    *piomap_addr;
-    pciio_piomap_done_f    *piomap_done;
-    pciio_piotrans_addr_f  *piotrans_addr;
-    pciio_piospace_alloc_f *piospace_alloc;
-    pciio_piospace_free_f  *piospace_free;
-
-    /* DMA MANAGEMENT */
-    pciio_dmamap_alloc_f   *dmamap_alloc;
-    pciio_dmamap_free_f    *dmamap_free;
-    pciio_dmamap_addr_f    *dmamap_addr;
-    pciio_dmamap_done_f    *dmamap_done;
-    pciio_dmatrans_addr_f  *dmatrans_addr;
-    pciio_dmamap_drain_f   *dmamap_drain;
-    pciio_dmaaddr_drain_f  *dmaaddr_drain;
-    pciio_dmalist_drain_f  *dmalist_drain;
-
-    /* INTERRUPT MANAGEMENT */
-    pciio_intr_alloc_f     *intr_alloc;
-    pciio_intr_free_f      *intr_free;
-    pciio_intr_connect_f   *intr_connect;
-    pciio_intr_disconnect_f *intr_disconnect;
-    pciio_intr_cpu_get_f   *intr_cpu_get;
-
-    /* CONFIGURATION MANAGEMENT */
-    pciio_provider_startup_f *provider_startup;
-    pciio_provider_shutdown_f *provider_shutdown;
-    pciio_reset_f	   *reset;
-    pciio_write_gather_flush_f *write_gather_flush;
-    pciio_endian_set_f     *endian_set;
-    pciio_priority_set_f   *priority_set;
-    pciio_config_get_f	   *config_get;
-    pciio_config_set_f	   *config_set;
-
-    /* Error handling interface */
-    pciio_error_devenable_f *error_devenable;
-    pciio_error_extract_f *error_extract;
-
-    /* Callback support */
-    pciio_driver_reg_callback_f *driver_reg_callback;
-    pciio_driver_unreg_callback_f *driver_unreg_callback;
-    pciio_device_unregister_f 	*device_unregister;
-    pciio_dma_enabled_f		*dma_enabled;
-} pciio_provider_t;
-
-/* PCI devices use these standard PCI provider interfaces */
-extern pciio_piomap_alloc_f pciio_piomap_alloc;
-extern pciio_piomap_free_f pciio_piomap_free;
-extern pciio_piomap_addr_f pciio_piomap_addr;
-extern pciio_piomap_done_f pciio_piomap_done;
-extern pciio_piotrans_addr_f pciio_piotrans_addr;
-extern pciio_pio_addr_f pciio_pio_addr;
-extern pciio_piospace_alloc_f pciio_piospace_alloc;
-extern pciio_piospace_free_f pciio_piospace_free;
-extern pciio_dmamap_alloc_f pciio_dmamap_alloc;
-extern pciio_dmamap_free_f pciio_dmamap_free;
-extern pciio_dmamap_addr_f pciio_dmamap_addr;
-extern pciio_dmamap_done_f pciio_dmamap_done;
-extern pciio_dmatrans_addr_f pciio_dmatrans_addr;
-extern pciio_dmamap_drain_f pciio_dmamap_drain;
-extern pciio_dmaaddr_drain_f pciio_dmaaddr_drain;
-extern pciio_dmalist_drain_f pciio_dmalist_drain;
-extern pciio_intr_alloc_f pciio_intr_alloc;
-extern pciio_intr_free_f pciio_intr_free;
-extern pciio_intr_connect_f pciio_intr_connect;
-extern pciio_intr_disconnect_f pciio_intr_disconnect;
-extern pciio_intr_cpu_get_f pciio_intr_cpu_get;
-extern pciio_provider_startup_f pciio_provider_startup;
-extern pciio_provider_shutdown_f pciio_provider_shutdown;
-extern pciio_reset_f pciio_reset;
-extern pciio_write_gather_flush_f pciio_write_gather_flush;
-extern pciio_endian_set_f pciio_endian_set;
-extern pciio_priority_set_f pciio_priority_set;
-extern pciio_config_get_f pciio_config_get;
-extern pciio_config_set_f pciio_config_set;
-extern pciio_error_devenable_f pciio_error_devenable;
-extern pciio_error_extract_f pciio_error_extract;
-
 /* Widgetdev in the IOERROR structure is encoded as follows.
  *	+---------------------------+
  *	| slot (7:3) | function(2:0)|
@@ -664,11 +548,6 @@
 /* Generic PCI dma interfaces */
 extern vertex_hdl_t     pciio_dma_dev_get(pciio_dmamap_t pciio_dmamap);
 
-/* Register/unregister PCI providers and get implementation handle */
-extern void             pciio_provider_register(vertex_hdl_t provider, pciio_provider_t *pciio_fns);
-extern void             pciio_provider_unregister(vertex_hdl_t provider);
-extern pciio_provider_t *pciio_provider_fns_get(vertex_hdl_t provider);
-
 /* Generic pci slot information access interface */
 extern pciio_info_t     pciio_info_chk(vertex_hdl_t vhdl);
 extern pciio_info_t     pciio_info_get(vertex_hdl_t vhdl);
@@ -683,7 +562,6 @@
 extern pciio_device_id_t pciio_info_device_id_get(pciio_info_t pciio_info);
 extern vertex_hdl_t     pciio_info_master_get(pciio_info_t pciio_info);
 extern arbitrary_info_t pciio_info_mfast_get(pciio_info_t pciio_info);
-extern pciio_provider_t *pciio_info_pops_get(pciio_info_t pciio_info);
 extern error_handler_f *pciio_info_efunc_get(pciio_info_t);
 extern error_handler_arg_t *pciio_info_einfo_get(pciio_info_t);
 extern pciio_space_t	pciio_info_bar_space_get(pciio_info_t, int);
diff -Nru a/include/asm-ia64/sn/pci/pciio_private.h b/include/asm-ia64/sn/pci/pciio_private.h
--- a/include/asm-ia64/sn/pci/pciio_private.h	Sat Sep 27 16:23:18 2003
+++ b/include/asm-ia64/sn/pci/pciio_private.h	Sat Sep 27 16:23:18 2003
@@ -108,7 +108,6 @@
     pciio_device_id_t       c_device;	/* PCI card "device" code */
     vertex_hdl_t            c_master;	/* PCI bus provider */
     arbitrary_info_t        c_mfast;	/* cached fastinfo from c_master */
-    pciio_provider_t       *c_pops;	/* cached provider from c_master */
     error_handler_f        *c_efunc;	/* error handling function */
     error_handler_arg_t     c_einfo;	/* first parameter for efunc */
 
diff -Nru a/include/asm-ia64/sn/pci/pic.h b/include/asm-ia64/sn/pci/pic.h
--- a/include/asm-ia64/sn/pci/pic.h	Sat Sep 27 16:23:18 2003
+++ b/include/asm-ia64/sn/pci/pic.h	Sat Sep 27 16:23:18 2003
@@ -77,21 +77,6 @@
 
 
 /*********************************************************************
- *    bus provider function table
- *
- *	Normally, this table is only handed off explicitly
- *	during provider initialization, and the PCI generic
- *	layer will stash a pointer to it in the vertex; however,
- *	exporting it explicitly enables a performance hack in
- *	the generic PCI provider where if we know at compile
- *	time that the only possible PCI provider is a
- *	pcibr, we can go directly to this ops table.
- */
-
-extern pciio_provider_t pci_pic_provider;
-
-
-/*********************************************************************
  * misc defines
  *
  */
