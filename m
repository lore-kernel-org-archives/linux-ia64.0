From: "McCaffity, Ray" <ray.mccaffity@wcg.com>
Date: Wed, 25 Apr 2001 16:42:13 +0000
Subject: RE: [Linux-ia64] patch: qla1280 cleanup
Message-Id: <marc-linux-ia64-105590693005461@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005456@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005456@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Probably a dumb question, but...
How can I tell if I'm running "big sur".

Ray

-----Original Message-----
From: Jes Sorensen [mailto:jes@linuxcare.com]
Sent: Tuesday, April 24, 2001 3:44 PM
To: linux-ia64@linuxia64.org
Cc: arjanv@redhat.com
Subject: [Linux-ia64] patch: qla1280 cleanup


Hi

Here is my first iteration of a cleanup patch for the qla1280
driver. It looks like a giant patch but it really is just cleaing up
the code by removing pre 2.2 support, getting rid of unused code and
broken stuff that dumped data on a serial port in a DOS environment!
On top of that there is some pointer size cleanups.

I have only tested this on the ia64 since I only have one of these
cards, but if someone feels like trying it out on the ia32 or other
architectures it would be appreciated. Same goes for 2.2 testing.

No guarantees that this will work, I did run some heavy dbench testing
on it (ever seen a dual CPU bigsur with a load of 130? ;-).

This patch goes on top of David's 010405 ia64 patch.

Jes

PS: The qla1280 firmware image included with the 010405 patch is under
a license that is conflicting with the GPL. Anyone have a contact at
QLogic so we can get this resolved?

--- ../linux-2.4.3-zc-010405-backup/drivers/scsi/qla1280.c	Fri Apr 13
17:52:25 2001
+++ drivers/scsi/qla1280.c	Tue Apr 24 15:36:43 2001
@@ -1,4 +1,4 @@
-/**************************************************************************
******
+/**************************************************************************
****
 *                  QLOGIC LINUX SOFTWARE
 *
 * QLogic  QLA1280 (Ultra2)  and  QLA12160 (Ultra3) SCSI driver
@@ -16,9 +16,18 @@
 * General Public License for more details.
 **
 
****************************************************************************
**/
-#define QLA1280_VERSION      "3.23 Beta"
-/**************************************************************************
**
+#define QLA1280_VERSION      "3.24 Beta"
+/**************************************************************************
****
     Revision History:
+    Rev  3.24 Beta April 24, Jes Sorensen
+        - Remove pre 2.2 kernel support
+        - clean up 64 bit DMA setting to use 2.4 API (provide backwards
compat)
+        - Fix MMIO access to use readl/writel instead of directly
+          dereferencing pointers
+        - Nuke MSDOS debugging code
+        - Change true/false data types to int from uint8_t
+        - Use int for counters instead of uint8_t etc.
+        - Clean up size & byte order conversion macro usage
     Rev  3.23 Beta January 11, 2001 BN Qlogic
         - Added check of device_id when handling non 
           QLA12160s during detect().
@@ -136,11 +145,6 @@
 #include <linux/module.h>
 #endif
 
-#include <stdarg.h>
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/segment.h>
-#include <asm/byteorder.h>
 #include <linux/version.h>
 #include <linux/types.h>
 #include <linux/string.h>
@@ -154,18 +158,22 @@
 #include <linux/proc_fs.h>
 #include <linux/blk.h>
 #include <linux/tqueue.h>
+#include <linux/stat.h>
+#include <linux/slab.h> 
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/segment.h>
+#include <asm/byteorder.h>
+
 #ifndef KERNEL_VERSION
 #  define KERNEL_VERSION(x,y,z) (((x)<<16)+((y)<<8)+(z))
 #endif
- 
+
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
 #include <linux/pci_ids.h>
 #endif
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-#include <linux/tasks.h>
-# include <linux/bios32.h>
-#endif
 #include "sd.h"
 #include "scsi.h"
 #include "hosts.h"
@@ -174,14 +182,13 @@
 #include "ql12160_fw.h"   /* ISP RISC codes */
 #include "ql1280_fw.h"
 
-#include <linux/stat.h>
-#include <linux/slab.h> 
 
 /*
  * Compile time Options: 
  *            0 - Disable and 1 - Enable 
  */
 #define  QL1280_TARGET_MODE_SUPPORT    0   /* Target mode support */
+#define  QL1280_LUN_SUPPORT            0
 #define  WATCHDOGTIMER                 0
 #define  MEMORY_MAPPED_IO              0
 #define  DEBUG_QLA1280_INTR            0
@@ -196,125 +203,138 @@
 #define  QLA1280_PROFILE               1   /* 3.20 */ 
 #define  DEBUG_QLA1280                 0
 
-#define	BZERO(ptr, amt)		memset(ptr, 0, amt)
-#define	BCOPY(src, dst, amt)	memcpy(dst, src, amt)
-#define	KMALLOC(siz)	kmalloc((siz), GFP_ATOMIC)
-#define	KMFREE(ip,siz)	kfree((ip))
 #define	SYS_DELAY(x)		udelay(x);barrier()
-#define QLA1280_DELAY(sec)  mdelay(sec * 1000)
+#define QLA1280_DELAY(sec)	mdelay(sec * 1000)
+
+#if (BITS_PER_LONG = 64) || defined CONFIG_HIGHMEM
+#define QLA_64BIT_PTR	1
+#endif
 
 /* 3.16 */
-#if  BITS_PER_LONG > 32
-#define pci_dma_lo32(a) (a & 0xffffffff)
-#define pci_dma_hi32(a) ((a >> 32) & 0xffffffff)
+#ifdef QLA_64BIT_PTR
+#define pci_dma_lo32(a)		(a & 0xffffffff)
+#define pci_dma_hi32(a)		(a >> 32)
 #else
-#define pci_dma_lo32(a) (a & 0xffffffff)
-#define pci_dma_hi32(a) 0
+#define pci_dma_lo32(a)		(a & 0xffffffff)
+#define pci_dma_hi32(a)		0
 #endif
 
-#define  VIRT_TO_BUS(a)  virt_to_bus(((void *)a))
 
-#if  BITS_PER_LONG <= 32
-#define  VIRT_TO_BUS_LOW(a) (uint32_t)virt_to_bus(((void *)a))
-#define  VIRT_TO_BUS_HIGH(a) (uint32_t)(0x0)
+#define NVRAM_DELAY()		udelay(500) /* 2 microsecond delay */
+
+#define CACHE_FLUSH(a)		RD_REG_WORD(a)
+#define INVALID_HANDLE		(MAX_OUTSTANDING_COMMANDS + 1)
+
+#ifdef QLA_64BIT_PTR
+#define MS_64BITS(x)		0
 #else
-#define  VIRT_TO_BUS_LOW(a) (uint32_t)(0xffffffff & virt_to_bus((void
*)(a)))
-#define  VIRT_TO_BUS_HIGH(a) (uint32_t)(0xffffffff & (virt_to_bus((void
*)(a))>>32))
+#define MS_64BITS(x)		(x >> 32)
 #endif
 
 
-#define STATIC     
-#define NVRAM_DELAY() udelay(500) /* 2 microsecond delay */
-void qla1280_device_queue_depth(scsi_qla_host_t *, Scsi_Device *);
+/*
+ * Compat macros
+ */
+#ifndef pci_set_dma_mask
+#define pci_set_dma_mask(dev, mask)		dev->dma_mask = mask;
+#endif
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+typedef unsigned long dma_addr_t;
 
-#define  CACHE_FLUSH(a) (RD_REG_WORD(a))
-#define  INVALID_HANDLE    (MAX_OUTSTANDING_COMMANDS+1)
+static inline void *pci_alloc_consistent(struct pci_dev *hwdev, size_t
size,
+					 dma_addr_t *dma_handle)
+{
+	void *virt_ptr;
 
-#define  MSW(x)          (uint16_t)((uint32_t)(x) >> 16)
-#define  LSW(x)          (uint16_t)(x)
-#define  MSB(x)          (uint8_t)((uint16_t)(x) >> 8)
-#define  LSB(x)          (uint8_t)(x)
+	virt_ptr = kmalloc(size, GFP_KERNEL);
+	if (!virt_ptr)
+		return NULL;
+	*dma_handle = virt_to_bus(virt_ptr);
+	return virt_ptr;
+}
+#define pci_free_consistent(cookie, size, ptr, dma_ptr)	kfree(ptr)
+#define pci_map_single(cookie, address, size, dir)	virt_to_bus(address)
+#define pci_map_sg(cookie, scatter, ents, dir)		ents
+#define pci_unmap_single(cookie, address, size, dir)
+#define pci_unmap_sg(cookie, scatter, ents, dir)
 
-#if  BITS_PER_LONG <= 32
-#define  LS_64BITS(x) (uint32_t)((unsigned long) x)
-#define  MS_64BITS(x) (uint32_t)((unsigned long) 0x0)
-#else
-#define  LS_64BITS(x) (uint32_t)(0xffffffff & ((unsigned long)x))
-#define  MS_64BITS(x) (uint32_t)(0xffffffff & (((unsigned long)x)>>32) )
+#define pci_resource_start(dev, i)			dev->base_address[i]
 #endif
 
+
 /*
  *  QLogic Driver Support Function Prototypes.
  */
-STATIC void   qla1280_done(scsi_qla_host_t *, srb_t **, srb_t **);
-STATIC void   qla1280_next(scsi_qla_host_t *, scsi_lu_t *, uint8_t);
-STATIC void   qla1280_putq_t(scsi_lu_t *, srb_t *);
-STATIC void   qla1280_done_q_put(srb_t *, srb_t **, srb_t **);
-STATIC void qla1280_select_queue_depth(struct Scsi_Host *, Scsi_Device *);
+static void qla1280_done(scsi_qla_host_t *, srb_t **, srb_t **);
+static void qla1280_next(scsi_qla_host_t *, scsi_lu_t *, uint8_t);
+static void qla1280_putq_t(scsi_lu_t *, srb_t *);
+static void qla1280_done_q_put(srb_t *, srb_t **, srb_t **);
+static void qla1280_device_queue_depth(scsi_qla_host_t *, Scsi_Device *);
+static void qla1280_select_queue_depth(struct Scsi_Host *, Scsi_Device *);
 #if  STOP_ON_ERROR 
 static void qla1280_panic(char *, struct Scsi_Host *host);
 #endif
-void qla1280_print_scsi_cmd(Scsi_Cmnd *cmd);
-STATIC void qla1280_abort_queue_single(scsi_qla_host_t
*,uint32_t,uint32_t,uint32_t,uint32_t);
+static void qla1280_abort_queue_single(scsi_qla_host_t
*,uint32_t,uint32_t,uint32_t,uint32_t);
 
-STATIC int qla1280_return_status( sts_entry_t *sts, Scsi_Cmnd       *cp);
-STATIC void qla1280_removeq(scsi_lu_t *q, srb_t *sp);
-STATIC void qla1280_mem_free(scsi_qla_host_t *ha);
+static int qla1280_return_status( sts_entry_t *sts, Scsi_Cmnd       *cp);
+static void qla1280_removeq(scsi_lu_t *q, srb_t *sp);
+static void qla1280_mem_free(scsi_qla_host_t *ha);
 void qla1280_do_dpc(void *p);
-static char	*qla1280_get_token(char *, char *);
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,0)
-STATIC inline void mdelay(int);
-#endif
+static char *qla1280_get_token(char *, char *);
 static inline void qla1280_enable_intrs(scsi_qla_host_t *);
 static inline void qla1280_disable_intrs(scsi_qla_host_t *);
 
 /*
  *  QLogic ISP1280 Hardware Support Function Prototypes.
  */
-STATIC uint8_t   qla1280_initialize_adapter(struct scsi_qla_host   *ha);
-STATIC uint8_t   qla1280_enable_tgt(scsi_qla_host_t *, uint8_t);
-STATIC uint8_t   qla1280_isp_firmware(scsi_qla_host_t *);
-STATIC uint8_t   qla1280_pci_config(scsi_qla_host_t *);
-STATIC uint8_t   qla1280_chip_diag(scsi_qla_host_t *);
-STATIC uint8_t   qla1280_setup_chip(scsi_qla_host_t *);
-STATIC uint8_t   qla1280_init_rings(scsi_qla_host_t *);
-STATIC uint8_t   qla1280_nvram_config(scsi_qla_host_t *);
-STATIC uint8_t   qla1280_mailbox_command(scsi_qla_host_t *, uint8_t,
uint16_t *);
-STATIC uint8_t   qla1280_bus_reset(scsi_qla_host_t *, uint8_t);
-STATIC uint8_t   qla1280_device_reset(scsi_qla_host_t *, uint8_t,
uint32_t);
-STATIC uint8_t   qla1280_abort_device(scsi_qla_host_t *, uint8_t, uint32_t,
uint32_t);
-STATIC uint8_t   qla1280_abort_command(scsi_qla_host_t *, srb_t *),
-                 qla1280_64bit_start_scsi(scsi_qla_host_t *, srb_t *),
-                 qla1280_32bit_start_scsi(scsi_qla_host_t *, srb_t *),
-                 qla1280_abort_isp(scsi_qla_host_t *);
-STATIC void      qla1280_nv_write(scsi_qla_host_t *, uint16_t),
-                 qla1280_nv_delay(scsi_qla_host_t *),
-                 qla1280_poll(scsi_qla_host_t *),
-                 qla1280_reset_adapter(scsi_qla_host_t *),
-                 qla1280_marker(scsi_qla_host_t *, uint8_t, uint32_t,
uint32_t, uint8_t),
-                 qla1280_isp_cmd(scsi_qla_host_t *),
-                 qla1280_isr(scsi_qla_host_t *, srb_t **, srb_t **),
-                 qla1280_rst_aen(scsi_qla_host_t *),
-                 qla1280_status_entry(scsi_qla_host_t *, sts_entry_t *,
srb_t **,
-                                      srb_t **),
-                 qla1280_error_entry(scsi_qla_host_t *, response_t *, srb_t
**,
-                                     srb_t **),
+static int qla1280_initialize_adapter(struct scsi_qla_host   *ha);
+static int qla1280_enable_tgt(scsi_qla_host_t *, uint8_t);
+static int qla1280_isp_firmware(scsi_qla_host_t *);
+static int qla1280_pci_config(scsi_qla_host_t *);
+static int qla1280_chip_diag(scsi_qla_host_t *);
+static int qla1280_setup_chip(scsi_qla_host_t *);
+static int qla1280_init_rings(scsi_qla_host_t *);
+static int qla1280_nvram_config(scsi_qla_host_t *);
+static int qla1280_mailbox_command(scsi_qla_host_t *, uint8_t, uint16_t *);
+static int qla1280_bus_reset(scsi_qla_host_t *, u8);
+static int qla1280_device_reset(scsi_qla_host_t *, uint8_t, uint32_t);
+static int qla1280_abort_device(scsi_qla_host_t *, u8, u32, u32);
+static int qla1280_abort_command(scsi_qla_host_t *, srb_t *);
+static int qla1280_abort_isp(scsi_qla_host_t *);
+static int qla1280_64bit_start_scsi(scsi_qla_host_t *, srb_t *);
+static int qla1280_32bit_start_scsi(scsi_qla_host_t *, srb_t *);
+static void qla1280_nv_write(scsi_qla_host_t *, uint16_t);
+static void qla1280_poll(scsi_qla_host_t *);
+static void qla1280_reset_adapter(scsi_qla_host_t *);
+static void qla1280_marker(scsi_qla_host_t *, u8, u32, u32, u8);
+static void qla1280_isp_cmd(scsi_qla_host_t *);
+static void qla1280_isr(scsi_qla_host_t *, srb_t **, srb_t **);
+static void qla1280_rst_aen(scsi_qla_host_t *);
+static void qla1280_status_entry(scsi_qla_host_t *, sts_entry_t *,
+                                 srb_t **, srb_t **);
+static void qla1280_error_entry(scsi_qla_host_t *, response_t *,
+                                srb_t **, srb_t **),
                  qla1280_restart_queues(scsi_qla_host_t *),
                  qla1280_abort_queues(scsi_qla_host_t *);
-STATIC uint16_t  qla1280_get_nvram_word(scsi_qla_host_t *, uint32_t),
+static uint16_t  qla1280_get_nvram_word(scsi_qla_host_t *, uint32_t),
                  qla1280_nvram_request(scsi_qla_host_t *, uint32_t),
                  qla1280_debounce_register(volatile uint16_t *);
-STATIC request_t *qla1280_req_pkt(scsi_qla_host_t *);
+static request_t *qla1280_req_pkt(scsi_qla_host_t *);
 int  qla1280_check_for_dead_scsi_bus(scsi_qla_host_t *ha, srb_t *sp);
-STATIC uint8_t qla1280_mem_alloc(scsi_qla_host_t *ha);
-STATIC uint8_t  qla1280_register_with_Linux(scsi_qla_host_t *ha, uint8_t
maxchannels);
+static int	 qla1280_mem_alloc(scsi_qla_host_t *ha);
+static int	 qla1280_register_with_Linux(scsi_qla_host_t *ha,
+                                             unsigned int maxchannels);
+
+static int	 qla12160_set_target_parameters(scsi_qla_host_t *, uint32_t,
uint32_t, uint32_t, nvram160_t *);
+static void	 qla12160_get_target_parameters(scsi_qla_host_t *, uint32_t,
uint32_t, uint32_t);
 
-STATIC uint8_t qla12160_set_target_parameters(scsi_qla_host_t *, uint32_t,
uint32_t, uint32_t, nvram160_t *);
-STATIC void qla12160_get_target_parameters(scsi_qla_host_t *, uint32_t,
uint32_t, uint32_t);
+#if QL1280_LUN_SUPPORT
+static void      qla1280_enable_lun(scsi_qla_host_t *, uint8_t, uint32_t);
+#endif
 
 #if QL1280_TARGET_MODE_SUPPORT
-STATIC void      qla1280_enable_lun(scsi_qla_host_t *, uint8_t, uint32_t),
-                 qla1280_notify_ack(scsi_qla_host_t *, notify_entry_t *),
+static void      qla1280_notify_ack(scsi_qla_host_t *, notify_entry_t *),
                  qla1280_immed_notify(scsi_qla_host_t *, notify_entry_t *),
                  qla1280_accept_io(scsi_qla_host_t *, ctio_ret_entry_t *),
                  qla1280_64bit_continue_io(scsi_qla_host_t *, 
@@ -327,27 +347,24 @@
                  qla1280_notify_entry(scsi_qla_host_t *, notify_entry_t *);
 #endif  /* QLA1280_TARGET_MODE_SUPPORT */
 
+#if DEBUG_QLA1280
+static void	qla1280_print(char *);
+static void	qla1280_output_number(uint32_t, int);
+static int ql_debug_print = 1;
+#endif
+
 #ifdef QL_DEBUG_ROUTINES
 /*
  *  Driver Debug Function Prototypes.
  */
-STATIC uint8_t  qla1280_getbyte(uint8_t *);
-STATIC uint16_t qla1280_getword(uint16_t *);
-STATIC uint32_t qla1280_getdword(uint32_t *);
-STATIC void     qla1280_putbyte(uint8_t *, uint8_t),
-                qla1280_putword(uint16_t *, uint16_t),
-                qla1280_putdword(uint32_t *, uint32_t),
-                qla1280_print(caddr_t),
-                qla1280_output_number(uint32_t, uint8_t),
-                qla1280_putc(uint8_t),
-                qla1280_dump_buffer(caddr_t, uint32_t);
-
-char          debug_buff[80];
-#if  DEBUG_QLA1280 
-STATIC uint8_t ql_debug_print = 1;
-#else
-STATIC uint8_t ql_debug_print = 0;
-#endif
+static u8 qla1280_getbyte(u8 *);
+static u16 qla1280_getword(u16 *);
+static u32 qla1280_getdword(u32 *);
+static void qla1280_putbyte(u8 *, u8);
+static void qla1280_putword(u16 *, u8);
+static void qla1280_putdword(u32 *, u32);
+static void qla1280_dump_buffer(char *, u32);
+static void qla1280_print_scsi_cmd(Scsi_Cmnd *cmd);
 #endif
 
 /*
@@ -355,18 +372,15 @@
  */
 #ifdef MODULE
 static char *options = NULL;
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,18)
 
 /* insmod qla1280 options=verbose" */
 MODULE_PARM(options, "s");  
-#endif
 /*
  * Just in case someone uses commas to separate items on the insmod
  * command line, we define a dummy buffer here to avoid having insmod
  * write wild stuff into our code segment
  */
 static char dummy_buffer[60] = "Please don't add commas in your insmod
command!!\n";
-
 #endif
 
 
@@ -446,13 +460,23 @@
   {"        ",                 0,           0}
 };
 
-static unsigned long qla1280_verbose = 1L;
+static int qla1280_verbose = 1;
 static scsi_qla_host_t *qla1280_hostlist = NULL;
 #if QLA1280_PROFILE
 static int qla1280_buffer_size = 0;
 static char *qla1280_buffer = NULL;
 #endif
 
+#if  DEBUG_QLA1280  
+char          debug_buff[80];
+#define COMTRACE(x)	do{}while(0)
+/* #define COMTRACE(x)     qla1280_print(x) */
+#define DEBUG(x)	x
+#else
+#define DEBUG(x)
+#define COMTRACE(x)	do{}while(0)
+#endif
+
 #ifdef QL_DEBUG_LEVEL_3 
 #define ENTER(x)	sprintf(debug_buff,"qla1280 : Entering %s()\n\r",
x); \
                         qla1280_print(debug_buff);
@@ -471,15 +495,6 @@
 #define DEBUG3(x)
 #endif
 
-#if  DEBUG_QLA1280  
-#define COMTRACE(x)
-/* #define COMTRACE(x)     qla1280_putc(x); */
-#define DEBUG(x)	x
-#else
-#define DEBUG(x)
-#define COMTRACE(x)
-#endif
-
 #ifdef QL_DEBUG_LEVEL_2 
 #define DEBUG2(x)	x
 #else
@@ -487,11 +502,7 @@
 #endif
 #define DEBUG5(x)
 
-#if (BITS_PER_LONG=64)
-#   define OFFSET(w)   (((uint64_t) &w) & 0xFF)   /* 256 byte offsets */
-#else
-#   define OFFSET(w)   (((uint32_t) &w) & 0xFF)   /* 256 byte offsets */
-#endif
+#define OFFSET(w)	(((unsigned long) &w) & 0xFF)   /* 256 byte offsets
*/
 
 #define SCSI_BUS_32(scp)   ((scp)->channel)
 #define SCSI_TCN_32(scp)    ((scp)->target)
@@ -557,7 +568,7 @@
 
   host = ha->host;
 
-    if( inout = TRUE ) /* Has data been written to the file? */
+  if( inout = TRUE ) /* Has data been written to the file? */
   {
         printk("qla1280_proc: has data been written to the file. \n");
         return (qla1280_set_info(buffer, length, host));
@@ -598,9 +609,9 @@
 
     size = sprintf(PROC_BUF, "SCSI Host Adapter Information: %s\n",
bdp->bdName);
     len += size;
-    size = sprintf(PROC_BUF, "Request Queue = 0x%x, Response Queue 0x%x\n",
-                        ha->request_dma,
-                        ha->response_dma);
+    size = sprintf(PROC_BUF, "Request Queue = 0x%p, Response Queue 0x%p\n",
+                        (void *)ha->request_dma,
+                        (void *)ha->response_dma);
     len += size;
     size = sprintf(PROC_BUF, "Request Queue count= 0x%x, Response Queue
count= 0x%x\n",
                         REQUEST_ENTRY_CNT,
@@ -698,18 +709,10 @@
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
     unsigned short subsys;
 #endif
-#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,1,95)
-    unsigned int piobase;
-    unsigned char pci_bus, pci_devfn, pci_irq;
-    config_reg_t   *cfgp = 0;
-#endif
     device_reg_t   *reg;
     char   *cp;
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
     struct pci_dev *pdev = NULL;
-#else
-    int index;
-#endif
+
 #ifndef PCI_VENDOR_ID_AMI
 #define PCI_VENDOR_ID_AMI               0x101e
 #endif
@@ -859,21 +862,16 @@
         pdev = NULL;
 	/* Try and find each different type of adapter we support */
 	for(i=0;bdp->device_id != 0 && i < NUM_OF_ISP_DEVICES;i++,bdp++) {
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
                 /* PCI_SUBSYSTEM_IDS supported */ 
 		while ((pdev = pci_find_subsys(QLA1280_VENDOR_ID,
 			bdp->device_id, PCI_ANY_ID, PCI_ANY_ID, pdev) )) {
- 			if (pci_enable_device(pdev)) continue;
+ 			if (pci_enable_device(pdev))
+                          continue;
 #else
 		while ((pdev = pci_find_device(QLA1280_VENDOR_ID,
 			bdp->device_id, pdev ) ))  {
 #endif /* 2,3,18 */
-#else  /* less than 2,1,95 */  
-		while (!(pcibios_find_device(QLA1280_VENDOR_ID,
-			bdp->device_id,
-			index++, &pci_bus, &pci_devfn)) )  {
-#endif /* 2,1,95 */ 
                 /* found a adapter */
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
 		  /* If it's an AMI SubSys Vendor ID adapter, skip it. */
@@ -888,14 +886,14 @@
                   /* since we already initialized and presented it */
                   if ((bdp->device_id        = QLA12160_DEVICE_ID) &&
                       (pdev->bus->number     = 1)   &&
-                      (PCI_SLOT(pdev->devfn) = 2))  continue;
+                      (PCI_SLOT(pdev->devfn) = 2))
+                    continue;
 
  		  printk("qla1x160: Supported Device Found VID=%x DID=%x
SSVID=%x SSDID=%x\n",
 			pdev->vendor, pdev->device,
 			pdev->subsystem_vendor, pdev->subsystem_device); 
 
 #else
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
                   printk("qla1x160: Supported Device Found\n");
 		  pci_read_config_word(pdev, PCI_SUBSYSTEM_VENDOR_ID,
                                        &subsys);
@@ -905,7 +903,6 @@
                       printk("qla1x160: Skip AMI SubSys Vendor ID
Chip\n");
                       continue;
                     }
-#endif /* 2,1,95 */
 #endif /* 2,3,18 */
 		host = scsi_register(template, sizeof(scsi_qla_host_t));
 		ha = (scsi_qla_host_t *) host->hostdata;
@@ -913,25 +910,11 @@
 		for( j =0, cp = (char *)ha;  j < sizeof(scsi_qla_host_t);
j++)
 			*cp++ = 0;
 		/* Sanitize the information from PCI BIOS.  */
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
 		host->irq = pdev->irq;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-                host->io_port = (unsigned int) pdev->base_address[0];
-#else
 		host->io_port = pci_resource_start(pdev, 0);
-#endif
 		ha->pci_bus = pdev->bus->number;
 		ha->pci_device_fn = pdev->devfn;
 		ha->pdev = pdev;
-#else
-		pcibios_read_config_byte(pci_bus, pci_devfn,
OFFSET(cfgp->interrupt_line), &pci_irq);
-		pcibios_read_config_dword(pci_bus, pci_devfn,
OFFSET(cfgp->base_port), &piobase);
-		host->irq = pci_irq;
-		host->io_port = (unsigned int) piobase;
-		host->io_port &= PCI_BASE_ADDRESS_IO_MASK;
-		ha->pci_bus = pci_bus;
-		ha->pci_device_fn = pci_devfn;
-#endif
 		ha->device_id = bdp->device_id;
                 ha->devnum = i; // specifies microcode load address
 
@@ -1013,50 +996,50 @@
 *  0 - Sucessfully reserved resources.
 *  1 - Failed to reserved a resource.
 **************************************************************************/
-STATIC uint8_t  qla1280_register_with_Linux(scsi_qla_host_t *ha, uint8_t
maxchannels)
+static int qla1280_register_with_Linux(scsi_qla_host_t *ha,
+                                       unsigned int maxchannels)
 {
+    struct Scsi_Host *host = ha->host;
 
-	struct Scsi_Host *host = ha->host;
-
-	host->can_queue = 0xfffff;  /* unlimited  */
-	host->cmd_per_lun = 1;
-       host->select_queue_depths = qla1280_select_queue_depth;
+    host->can_queue = 0xfffff;  /* unlimited  */
+    host->cmd_per_lun = 1;
+    host->select_queue_depths = qla1280_select_queue_depth;
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-        host->base = (unsigned char *) ha->mmpbase;
+    host->base = (unsigned char *) ha->mmpbase;
 #else
-        host->base = (u_long) ha->mmpbase;
+    host->base = (unsigned long) ha->mmpbase;
 #endif
-	host->max_channel = maxchannels; 
-       host->max_lun = MAX_LUNS-1; 
-	host->unique_id = ha->instance;
-       host->max_id = MAX_TARGETS; 
-       host->unique_id = ha->instance;
-
-	/* set our host ID  (need to do something about our two IDs) */
-       host->this_id = ha->bus_settings[0].id;
-       /* Register the IRQ with Linux (sharable) */
-       if ( request_irq(host->irq, qla1280_intr_handler, SA_INTERRUPT|
SA_SHIRQ, "qla1280", ha))
-       {
-          printk("qla1280 : Failed to reserved interrupt %d already in
use\n", host->irq);
-          qla1280_mem_free(ha);
-          scsi_unregister(host);
-	     return 1;
-       }
+    host->max_channel = maxchannels; 
+    host->max_lun = MAX_LUNS-1; 
+    host->unique_id = ha->instance;
+    host->max_id = MAX_TARGETS; 
+    host->unique_id = ha->instance;
 
-       /* Register the I/O space with Linux */
-       if (check_region(host->io_port, 0xff))
-       {
-           printk("qla1280 : Failed to reserved i/o region 0x%04lx-0x%04lx
already in use\n",
-              host->io_port, host->io_port + 0xff);
-           free_irq(host->irq, NULL);
-           qla1280_mem_free(ha);
-           scsi_unregister(host);
-	     return 1;
-       }
+    /* set our host ID  (need to do something about our two IDs) */
+    host->this_id = ha->bus_settings[0].id;
+    /* Register the IRQ with Linux (sharable) */
+    if ( request_irq(host->irq, qla1280_intr_handler, SA_INTERRUPT|
SA_SHIRQ, "qla1280", ha))
+    {
+      printk("qla1280 : Failed to reserved interrupt %d already in use\n",
host->irq);
+      qla1280_mem_free(ha);
+      scsi_unregister(host);
+      return 1;
+    }
 
-       request_region(host->io_port, 0xff, "qla1280");
+    /* Register the I/O space with Linux */
+    if (check_region(host->io_port, 0xff))
+    {
+      printk("qla1280 : Failed to reserved i/o region 0x%04lx-0x%04lx
already"
+             " in use\n", host->io_port, host->io_port + 0xff);
+      free_irq(host->irq, NULL);
+      qla1280_mem_free(ha);
+      scsi_unregister(host);
+      return 1;
+    }
 
-	return 0;
+    request_region(host->io_port, 0xff, "qla1280");
+
+    return 0;
 }
 
 
@@ -1088,13 +1071,7 @@
 
 #if MEMORY_MAPPED_IO
     if(ha->mmpbase)
-    {
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,0)
-        vfree((void *) (((unsigned long) ha->mmpbase) & PAGE_MASK));
-#else
         iounmap((void *) (((unsigned long) ha->mmpbase) & PAGE_MASK));
-#endif
-    }
 #endif /* MEMORY_MAPPED_IO */
     qla1280_mem_free(ha);
 
@@ -1143,23 +1120,20 @@
 {
     scsi_qla_host_t *ha;
     srb_t  *sp;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
     struct Scsi_Host *host;
     uint32_t        b, t, l;
     scsi_lu_t       *q;
     u_long          handle;
 
     /*ENTER("qla1280_queuecommand");
-      COMTRACE('C')*/ 
+      COMTRACE('C');*/
 
     host = cmd->host;
     ha = (scsi_qla_host_t *) host->hostdata;
 
     /* send command to adapter */
     sp = (srb_t *) CMD_SP(cmd);
-    sp->cmd =  cmd;
+    sp->cmd = cmd;
     cmd->scsi_done = fn;
     if (cmd->flags = 0)  /* new command */
     {
@@ -1174,14 +1148,12 @@
     l = SCSI_LUN_32(cmd);
     if((q = LU_Q(ha, b, t, l)) = NULL )
     {
-        DRIVER_LOCK
-        if( (q = (scsi_lu_t *)KMALLOC(sizeof(struct scsi_lu))) )
+        if( (q = (scsi_lu_t *)kmalloc(sizeof(struct scsi_lu), GFP_ATOMIC)))
         {
            LU_Q(ha, b, t, l) = q;
-           BZERO(q,sizeof(struct scsi_lu));
-           DEBUG(sprintf(debug_buff,"Allocate new device queue
0x%x\n\r",q));
+           memset(q, 0, sizeof(struct scsi_lu));
+           DEBUG(sprintf(debug_buff,"Allocate new device queue
0x%p\n\r",(void *)q));
            DEBUG(qla1280_print(debug_buff));
-           DRIVER_UNLOCK
         }
         else
         {
@@ -1194,7 +1166,6 @@
             schedule_task(&ha->run_qla_bh); /* 3.22 */
 #endif /* 3.22 */
             ha->flags.dpc_sched = TRUE;
-            DRIVER_UNLOCK
             return(0);
         }
     }
@@ -1206,19 +1177,16 @@
     /* add the command to our queue */
     ha->qthreads++;
     qla1280_putq_t(q,sp);
-    
+
     DEBUG(sprintf(debug_buff,
-     "qla1280_QC: t=%x CDB=%x I/OSize=0x%x haQueueCount=0x%x\n\r",
+     "qla1280_QC: t=%x CDB=%x I/OSize=0x%x haQueueCount=0x%lx\n\r",
      t,cmd->cmnd[0],CMD_XFRLEN(cmd),ha->qthreads));
     DEBUG(qla1280_print(debug_buff));
 
     /* send command to adapter */
-    DRIVER_LOCK
-        if (q->q_outcnt = 0)
-            qla1280_restart_queues(ha);
-    DRIVER_UNLOCK
-    
-    
+    if (q->q_outcnt = 0)
+      qla1280_restart_queues(ha);
+
     /*LEAVE("qla1280_queuecommand");*/
     return (0);
 }
@@ -1232,38 +1200,34 @@
 {
     scsi_qla_host_t *ha;
     srb_t  *sp;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
     struct Scsi_Host *host;
     uint32_t        b, t, l;
     scsi_lu_t       *q;
     int return_status = SCSI_ABORT_SUCCESS;
     int found = 0;
     int i;
-    u_long     handle;
-    u_short    data;
+    unsigned char *handle;
+    u16 data;
 
     ENTER("qla1280_abort");
-    COMTRACE('A')
+    COMTRACE('A');
     ha = (scsi_qla_host_t *) cmd->host->hostdata;
     host = cmd->host;
-    DRIVER_LOCK
 
     /* Get the SCSI request ptr */
     sp = (srb_t *) CMD_SP(cmd);
-    handle = (u_long) CMD_HANDLE(cmd);
+    handle = CMD_HANDLE(cmd);
     if (qla1280_verbose)
-        printk("scsi(%d): ABORT Command=0x%lx,
handle=0x%lx\n",(int)ha->host_no,(long)cmd,handle);
+        printk("scsi(%li): ABORT Command=0x%p, handle=0x%p\n",
+               ha->host_no, (void *)cmd, (void *)handle);
 
     /* Check for pending interrupts. */
-    if( handle = 0L )
+    if( handle = NULL )
     {
-    COMTRACE('a')
-        /* we never got this command */
-        printk(KERN_INFO "qla1280: Aborting a NULL handle\n");
-        DRIVER_UNLOCK
-                return(SCSI_ABORT_NOT_RUNNING);  /* no action - we don't
have command */
+      COMTRACE('a');
+      /* we never got this command */
+      printk(KERN_INFO "qla1280: Aborting a NULL handle\n");
+      return(SCSI_ABORT_NOT_RUNNING);  /* no action - we don't have command
*/
     }
     data = qla1280_debounce_register(&ha->iobase->istatus);
     if( !(ha->flags.in_isr) && (data & RISC_INT) )
@@ -1272,7 +1236,12 @@
         qla1280_isr(ha, (srb_t **)&ha->done_q_first, (srb_t
**)&ha->done_q_last);
     }
 
-    handle = (u_long) CMD_HANDLE(cmd);
+    /*
+     * This seems unnecessary, it's not used below! / Jes
+     */
+#ifdef UNUSED
+    handle = CMD_HANDLE(cmd);
+#endif
 
     /* Generate LU queue on bus, target, LUN */
     b = SCSI_BUS_32(cmd);
@@ -1280,17 +1249,15 @@
     l = SCSI_LUN_32(cmd);
     if((q = LU_Q(ha, b, t, l)) = NULL )
     {
-    COMTRACE('a')
-        /* No lun queue -- command must not be active */
-        DRIVER_UNLOCK
-        printk(KERN_WARNING "qla1280 (%d:%d:%d): No LUN queue for the
specified device\n",(int)b,(int)t,(int)l);
-        return(SCSI_ABORT_NOT_RUNNING);  /* no action - we don't have
command */
+      COMTRACE('a');
+      /* No lun queue -- command must not be active */
+      printk(KERN_WARNING "qla1280 (%d:%d:%d): No LUN queue for the
specified device\n",(int)b,(int)t,(int)l);
+      return(SCSI_ABORT_NOT_RUNNING);  /* no action - we don't have command
*/
     }
 
 #if AUTO_ESCALATE_ABORT
     if ( (sp->flags & SRB_ABORTED) )
     {
-        DRIVER_UNLOCK
         DEBUG(qla1280_print("qla1280_abort: Abort escalayted - returning
SCSI_ABORT_SNOOZE.\n\r"));
         return(SCSI_ABORT_SNOOZE);
     }
@@ -1298,10 +1265,9 @@
 
     if ( (sp->flags & SRB_ABORT_PENDING) )
     {
-    COMTRACE('a')
-        DRIVER_UNLOCK
-        if( qla1280_verbose  )
-            printk("scsi(): Command has a pending abort message -
ABORT_PENDING.\n");
+      COMTRACE('a');
+      if( qla1280_verbose  )
+        printk("scsi(): Command has a pending abort message -
ABORT_PENDING.\n");
         DEBUG(qla1280_print("qla1280: Command has a pending abort message -
ABORT_PENDING.\n\r"));
         return(SCSI_ABORT_PENDING);
     }
@@ -1317,7 +1283,7 @@
     * but; since our sp contains the cmd ptr, we can just remove it from
our
     * LUN queue.
     */
-    if( !(sp->flags&SRB_SENT) )
+    if(!(sp->flags & SRB_SENT))
     { 
         found++;
         if( qla1280_verbose  )
@@ -1361,10 +1327,9 @@
         qla1280_restart_queues(ha);
     }
     ha->flags.in_abort = FALSE;
-    DRIVER_UNLOCK
 
     LEAVE("qla1280_abort");
-    COMTRACE('a')
+    COMTRACE('a');
     return(return_status);
 }
 
@@ -1391,9 +1356,6 @@
 qla1280_reset(Scsi_Cmnd *cmd, unsigned int flags)
 {
     scsi_qla_host_t *ha;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
     uint32_t        b, t, l;
     srb_t  *sp;
     typedef enum
@@ -1412,7 +1374,7 @@
 
 
     ENTER("qla1280_reset");
-    COMTRACE('R')
+    COMTRACE('R');
     if (qla1280_verbose)
         printk("scsi(): Resetting Cmnd=0x%lx, Handle=0x%lx,
flags=0x%x\n",(long)cmd,(long)CMD_HANDLE(cmd),flags);
     if ( cmd = NULL )
@@ -1428,20 +1390,16 @@
     qla1280_panic("qla1280_reset",ha->host);
 #endif 
 
-    DRIVER_LOCK
     /* Check for pending interrupts. */
     data = qla1280_debounce_register(&ha->iobase->istatus);
     if( !(ha->flags.in_isr) && (data & RISC_INT) )
-    {
-        qla1280_isr(ha, (srb_t **)&ha->done_q_first, (srb_t
**)&ha->done_q_last);
-    }
-    DRIVER_UNLOCK
+      qla1280_isr(ha, (srb_t **)&ha->done_q_first, (srb_t
**)&ha->done_q_last);
 
     /*
     * Determine the suggested action that the mid-level driver wants
     * us to perform.
     */
-    if( CMD_HANDLE(cmd) = (unsigned char *) 0  )
+    if( CMD_HANDLE(cmd) = NULL )
     {
         /* 
         * if mid-level driver called reset with a orphan SCSI_Cmnd 
@@ -1489,7 +1447,6 @@
     *  By this point, we want to already know what we are going to do,
     *  so we only need to perform the course of action.
     */
-    DRIVER_LOCK
     result = SCSI_RESET_ERROR;
     switch (action)
     {
@@ -1568,10 +1525,9 @@
     qla1280_restart_queues(ha);
     ha->flags.in_reset = FALSE;
     
-DRIVER_UNLOCK
     DEBUG(printk("RESET returning %d\n", result)); 
 
-    COMTRACE('r')
+    COMTRACE('r');
     LEAVE("qla1280_reset");
     return( result );
 }
@@ -1609,29 +1565,26 @@
 
**************************************************************************/
 void qla1280_intr_handler(int irq, void *dev_id, struct pt_regs *regs)
 {
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
     scsi_qla_host_t *ha;
-    u_short    data;
     device_reg_t *reg;
+    unsigned long cpu_flags;
+    u_short    data;
 
     ENTER_INTR("qla1280_intr_handler");
-    COMTRACE('I')
+    COMTRACE('I');
     ha = (scsi_qla_host_t *) dev_id;
     if(!ha)
     {
         printk(KERN_INFO "scsi(): Interrupt with NULL host ptr\n");
-        COMTRACE('X')
+        COMTRACE('X');
         return;
     }
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,1,95)
     spin_lock_irqsave(&io_request_lock, cpu_flags);
     if(test_and_set_bit(QLA1280_IN_ISR_BIT, &ha->flags))
     {
-        COMTRACE('X')
-        spin_unlock_irqrestore(&io_request_lock, cpu_flags);
-        return;
+      COMTRACE('X');
+      spin_unlock_irqrestore(&io_request_lock, cpu_flags);
+      return;
     }
     ha->isr_count++;
     reg = ha->iobase;
@@ -1643,7 +1596,7 @@
     {
         /* spurious interrupts can happen legally */
         DEBUG(printk("scsi(%d): Spurious interrupt -
ignoring\n",(int)ha->host_no));
-        COMTRACE('X')
+        COMTRACE('X');
     }
     else
       qla1280_isr(ha, (srb_t **)&ha->done_q_first, (srb_t
**)&ha->done_q_last);
@@ -1652,54 +1605,12 @@
 
     clear_bit(QLA1280_IN_ISR_BIT, &ha->flags);
     spin_unlock_irqrestore(&io_request_lock, cpu_flags);
-#else  /* LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95) */
-
-    if( test_bit(QLA1280_IN_ISR_BIT, (int *)&ha->flags) )
-    {
-          COMTRACE('X')
-          printk(KERN_INFO "scsi(%d): Already in interrupt - returning \n",
(int)ha->host_no);
-          spin_unlock_irqrestore(&io_request_lock, cpu_flags);
-          return;
-    }
-    set_bit(QLA1280_IN_ISR_BIT, (int *)&ha->flags);
-    ha->isr_count++;
-    reg = ha->iobase;
-     /* disable our interrupt. */
-    WRT_REG_WORD(&reg->ictrl, 0); 
-
-    data = qla1280_debounce_register(&reg->istatus);
-    /* Check for pending interrupts. */
-    if ( !(data & RISC_INT) )
-    {
-        /* spurious interrupts can happen legally */
-        DEBUG(printk("scsi(%d): Spurious interrupt -
ignoring\n",(int)ha->host_no));
-        COMTRACE('X')
-    }
-    else
-     qla1280_isr(ha, (srb_t **)&ha->done_q_first, (srb_t
**)&ha->done_q_last);
-
-    /* if no work to do then call the SCSI mid-level right away */
-    if( ha->done_q_first )
-        qla1280_done(ha, (srb_t **)&ha->done_q_first, (srb_t
**)&ha->done_q_last);
-
-    /* Schedule the DPC routine */
-    if (ha->flags.isp_abort_needed || ha->flags.reset_marker ||
-            ha->done_q_first        )
-        {
-            ha->run_qla_bh.data = (void *) ha;
-            ha->run_qla_bh.routine = qla1280_do_dpc; 
 
-             COMTRACE('P') 
-            queue_task_irq(&ha->run_qla_bh,&tq_scheduler); 
-            ha->flags.dpc_sched = TRUE;
-        }
-        clear_bit(QLA1280_IN_ISR_BIT, (int *)&ha->flags);
-#endif
      /* enable our interrupt. */
-        WRT_REG_WORD(&reg->ictrl, ISP_EN_INT + ISP_EN_RISC);
+    WRT_REG_WORD(&reg->ictrl, (ISP_EN_INT | ISP_EN_RISC));
 
-        COMTRACE('i')  
-        LEAVE_INTR("qla1280_intr_handler");
+    COMTRACE('i');
+    LEAVE_INTR("qla1280_intr_handler");
 }
 
 /**************************************************************************
@@ -1717,14 +1628,11 @@
 void qla1280_do_dpc(void *p)
 {
     scsi_qla_host_t *ha = (scsi_qla_host_t *) p;
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
+    unsigned long cpu_flags;
 
-    COMTRACE('p')  
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
+    COMTRACE('p');
     spin_lock_irqsave(&io_request_lock, cpu_flags);
-#endif
+
     if (ha->flags.isp_abort_needed)
         qla1280_abort_isp(ha);
 
@@ -1734,9 +1642,8 @@
     if (ha->done_q_first)
         qla1280_done(ha, (srb_t **)&ha->done_q_first, (srb_t
**)&ha->done_q_last);
     ha->flags.dpc_sched = FALSE;
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
+
     spin_unlock_irqrestore(&io_request_lock, cpu_flags);
-#endif
 }
 
 /**************************************************************************
@@ -1750,7 +1657,7 @@
  *   as the default queue depth.  Otherwise, we use either 4 or 8 as the
  *   default queue depth (dependent on the number of hardware SCBs).
 
**************************************************************************/
-STATIC void qla1280_device_queue_depth(scsi_qla_host_t *p, Scsi_Device
*device)
+static void qla1280_device_queue_depth(scsi_qla_host_t *p, Scsi_Device
*device)
 {
     int default_depth = 3;
     int bus = device->channel;
@@ -1780,7 +1687,7 @@
  *   host adapter.  We use a queue depth of 2 for devices that do not
  *   support tagged queueing.
 
**************************************************************************/
-STATIC void
+static void
 qla1280_select_queue_depth(struct Scsi_Host *host, Scsi_Device *scsi_devs)
 {
     Scsi_Device *device;
@@ -1799,22 +1706,6 @@
 ** Driver Support Routines  **
 **--------------------------*/
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,0)
-/*
- * mdelay
- *      Delay in milliseconds 
- *
- * Input:
- *      milliseconds  = delay 
- */
-STATIC inline void mdelay(int milliseconds)
-{
-    int i;
-
-    for(i=0; i<milliseconds; i++)
-        udelay(1000);
-}
-#endif
 
 /*
  * qla1280_done
@@ -1825,7 +1716,7 @@
  *      done_q_first = done queue first pointer.
  *      done_q_last  = done queue last pointer.
  */
-STATIC void
+static void
 qla1280_done(scsi_qla_host_t *ha, srb_t **done_q_first, srb_t
**done_q_last)
 {
     srb_t           *sp;
@@ -1833,14 +1724,9 @@
     uint32_t        b, t, l;
     Scsi_Cmnd  *cmd;
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
-
     ENTER("qla1280_done");
-    COMTRACE('D') 
+    COMTRACE('D');
 
-    DRIVER_LOCK 
     while (*done_q_first !=  NULL)
     {
         /* remove command from done list */
@@ -1886,12 +1772,12 @@
             default:
                 break;
         }
+
         /* 3.13   64 and 32 bit */
         /* Release memory used for this I/O */
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
         if (cmd->use_sg) {
             DEBUG(sprintf(debug_buff,
-            "S/G unmap_sg cmd=%x\n\r",cmd);)
+            "S/G unmap_sg cmd=%p\n\r",(void *)cmd);)
             DEBUG(qla1280_print(debug_buff));
             pci_unmap_sg(ha->pdev, cmd->request_buffer,
                          cmd->use_sg,
@@ -1907,32 +1793,27 @@
                                   cmd->request_bufflen,
 
scsi_to_pci_dma_dir(cmd->sc_data_direction));
        }
-#endif 
+
         /* Call the mid-level driver interrupt handler */
-        CMD_HANDLE(sp->cmd) = (unsigned char *) 0;
+        CMD_HANDLE(sp->cmd) = NULL;
         ha->actthreads--;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-        sti(); 
-        (*(cmd)->scsi_done)(cmd);
-        cli(); 
-#else
+
         (*(cmd)->scsi_done)(cmd);
-#endif
+
         qla1280_next(ha, q, b);
     }
-    DRIVER_UNLOCK 
-    COMTRACE('d') 
+    COMTRACE('d');
     LEAVE("qla1280_done");
 }
 
 /*
  * Translates a ISP error to a Linux SCSI error
  */
-STATIC int qla1280_return_status( sts_entry_t *sts, Scsi_Cmnd       *cp)
+static int qla1280_return_status( sts_entry_t *sts, Scsi_Cmnd       *cp)
 {
     int host_status = DID_ERROR;
 #if DEBUG_QLA1280_INTR
-    STATIC char *reason[] +    static char *reason[]      {
         "DID_OK",
                 "DID_NO_CONNECT",
@@ -1987,8 +1868,7 @@
             printk("Data overrun 0x%x\n",(int)sts->residual_length);
             qla1280_print(
                         "\n\rqla1280_isr: response packet data\n\r");
-                        qla1280_dump_buffer((caddr_t)sts,
-                        RESPONSE_ENTRY_SIZE); 
+                        qla1280_dump_buffer((char *)sts,
RESPONSE_ENTRY_SIZE); 
 #endif
             host_status = DID_ERROR;
             break;
@@ -2025,18 +1905,14 @@
  *      done_q_first = done queue first pointer.
  *      done_q_last  = done queue last pointer.
  */
-STATIC void
+static void
 qla1280_done_q_put(srb_t *sp, srb_t **done_q_first, srb_t **done_q_last)
 {
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_put_done_q");
 #endif
     /* Place block on done queue */
-    DRIVER_LOCK
-            sp->s_next = NULL;
+    sp->s_next = NULL;
     sp->s_prev = *done_q_last;
     if (!*done_q_first)
         *done_q_first = sp;
@@ -2044,7 +1920,6 @@
         (*done_q_last)->s_next = sp;
     *done_q_last = sp;
 
-    DRIVER_UNLOCK
 #ifdef QL_DEBUG_LEVEL_3
             LEAVE("qla1280_put_done_q");
 #endif
@@ -2063,19 +1938,14 @@
  * Output:
  *      Releases SCSI_LU_Q upon exit.
  */
-STATIC void
+static void
 qla1280_next(scsi_qla_host_t *ha, scsi_lu_t *q, uint8_t b)
 {
     srb_t   *sp;
-    uint32_t cnt;
-    uint8_t status;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
+    int cnt, status;
 
     ENTER("qla1280_next");
 
-    DRIVER_LOCK
     while ( ((sp = q->q_first) != NULL) &&     /* we have a queue pending
*/
         !(q->q_flag &  QLA1280_QBUSY) &&      /* device not busy */
         !ha->flags.abort_isp_active &&      /* not resetting the adapter */
@@ -2084,7 +1954,8 @@
         /* Remove srb from SCSI LU queue. */
         qla1280_removeq(q, sp);
 
-        DEBUG(sprintf(debug_buff,"starting request
0x%p<-(0x%p)\n\r",q,sp));
+        DEBUG(sprintf(debug_buff,"starting request 0x%p<-(0x%p)\n\r",
+                      (void *)q, (void *)sp));
         DEBUG(qla1280_print(debug_buff));
         {
             /* Set busy flag if reached high water mark. */
@@ -2136,17 +2007,11 @@
                         if (sp->flags & SRB_WATCHDOG)
                             qla1280_timeout_remove(ha, sp);
 #endif
-                        COMTRACE('M') 
-                        CMD_HANDLE(sp->cmd) = (unsigned char *) 0;
+                        COMTRACE('M');
+                        CMD_HANDLE(sp->cmd) = NULL;
 
                         /* Call the mid-level driver interrupt handler */
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-                        sti(); 
                         (*(sp->cmd)->scsi_done)(sp->cmd);
-                        cli(); 
-#else
-                        (*(sp->cmd)->scsi_done)(sp->cmd);
-#endif
 
                         /* Acquire LU queue specific lock */
                         QLA1280_SCSILU_LOCK(q);
@@ -2171,7 +2036,6 @@
             }
         }
     }
-   DRIVER_UNLOCK
 
     /* Release SCSI LU queue specific lock */
     QLA1280_SCSILU_UNLOCK(q);
@@ -2188,19 +2052,16 @@
  *      sp = srb pointer.
  *      SCSI_LU_Q lock must be already obtained.
  */
-STATIC void
+static void
 qla1280_putq_t(scsi_lu_t *q, srb_t *sp)
 {
     srb_t *srb_p;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_putq_t");
 #endif
-    DRIVER_LOCK
-    DEBUG(sprintf(debug_buff,"Adding to device
q=0x%p<-(0x%p)sp\n\r",q,sp));
+    DEBUG(sprintf(debug_buff,"Adding to device q=0x%p<-(0x%p)sp\n\r",
+                  (void *)q, (void *)sp));
     DEBUG(qla1280_print(debug_buff));
     sp->s_next = NULL;
     if (!q->q_first)                  /* If queue empty */
@@ -2233,9 +2094,8 @@
         }
     }
 
-    DRIVER_UNLOCK
 #ifdef QL_DEBUG_LEVEL_3
-            LEAVE("qla1280_putq_t");
+    LEAVE("qla1280_putq_t");
 #endif
 }
 
@@ -2249,15 +2109,12 @@
  *      sp = srb pointer.
  *      SCSI_LU_Q lock must be already obtained.
  */
-STATIC void
+static void
 qla1280_removeq(scsi_lu_t *q, srb_t *sp)
 {
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
-    DEBUG(sprintf(debug_buff,"Removing from device_q
(0x%p)->(0x%p)\n\r",q,sp));
+    DEBUG(sprintf(debug_buff,"Removing from device_q (0x%p)->(0x%p)\n\r",
+                  (void *)q, (void *)sp));
     DEBUG(qla1280_print(debug_buff));
-    DRIVER_LOCK
             if (sp->s_prev)
     {
         if ((sp->s_prev->s_next = sp->s_next) != NULL)
@@ -2269,7 +2126,6 @@
         q->q_last = NULL;
     else
         q->q_first->s_prev = NULL;
-    DRIVER_UNLOCK
 }
 
 /*
@@ -2280,7 +2136,7 @@
 *      0  = success.
 *      1  = failure.
 */
-STATIC uint8_t
+static int
 qla1280_mem_alloc(scsi_qla_host_t *ha)
 {
 
@@ -2295,13 +2151,6 @@
 
         /* 3.13 */
         /* get consistent memory allocated for request and response rings
*/
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-	ha->request_ring = &ha->req[0];
-	ha->request_dma = VIRT_TO_BUS(&ha->req[0]);
-	ha->response_ring = &ha->res[0];
-	ha->response_dma = VIRT_TO_BUS(&ha->res[0]);
-	status = 0;
-#else
         ha->request_ring  = pci_alloc_consistent(ha->pdev,
                                ((REQUEST_ENTRY_CNT+1)*(sizeof(request_t))),
                                &dma_handle);
@@ -2311,7 +2160,6 @@
                                &dma_handle);
         ha->response_dma   = dma_handle;
         status = 0; 
-#endif 
 
 	if(status) {
 #if defined(QL_DEBUG_LEVEL_2) || defined(QL_DEBUG_LEVEL_3)
@@ -2332,7 +2180,7 @@
  * Input:
  *      ha = adapter block pointer.
  */
-STATIC void
+static void
 qla1280_mem_free(scsi_qla_host_t *ha)
 {
     scsi_lu_t *q;
@@ -2348,8 +2196,8 @@
             for (t = 0; t < MAX_TARGETS; t++)
                 for (l = 0; l < MAX_LUNS; l++)
                     if (LU_Q(ha, b, t, l) != NULL && LU_Q(ha, b, t, l) !q)
-                        KMFREE(LU_Q(ha, b, t, l),sizeof(struct scsi_lu));
-                    KMFREE(q, sizeof(struct scsi_lu));
+                        kfree(LU_Q(ha, b, t, l));
+                    kfree(q);
         }
         for( b =0; b < MAX_EQ; b++ )
             ha->dev[b] =  (scsi_lu_t  *)NULL;
@@ -2357,13 +2205,11 @@
 
     /* 3.13 */
     /* free consistent memory allocated for request and response rings */
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
     pci_free_consistent(ha->pdev,
((REQUEST_ENTRY_CNT+1)*(sizeof(request_t))),
                         ha->request_ring, ha->request_dma);
 
 
pci_free_consistent(ha->pdev,((RESPONSE_ENTRY_CNT+1)*(sizeof(response_t))),
     ha->response_ring, ha->response_dma); 
-#endif 
 
     LEAVE("qlc1280_mem_free");
 }
@@ -2385,23 +2231,23 @@
  * Returns:
  *      None      
  */
-    static inline void qla1280_enable_intrs(scsi_qla_host_t *ha) {
-        device_reg_t *reg;
+static inline void qla1280_enable_intrs(scsi_qla_host_t *ha) {
+  device_reg_t *reg;
 
-        reg = ha->iobase;
-        ha->flags.interrupts_on = 1;
-        /* enable risc and host interrupts */
-        WRT_REG_WORD(&reg->ictrl, (ISP_EN_INT+ ISP_EN_RISC));
-    }
-
-    static inline void qla1280_disable_intrs(scsi_qla_host_t *ha) {
-        device_reg_t *reg;
-
-        reg = ha->iobase;
-        ha->flags.interrupts_on = 0;
-        /* disable risc and host interrupts */
-        WRT_REG_WORD(&reg->ictrl, 0);
-    }
+  reg = ha->iobase;
+  ha->flags.interrupts_on = 1;
+  /* enable risc and host interrupts */
+  WRT_REG_WORD(&reg->ictrl, (ISP_EN_INT | ISP_EN_RISC));
+}
+
+static inline void qla1280_disable_intrs(scsi_qla_host_t *ha) {
+  device_reg_t *reg;
+
+  reg = ha->iobase;
+  ha->flags.interrupts_on = 0;
+  /* disable risc and host interrupts */
+  WRT_REG_WORD(&reg->ictrl, 0);
+}
 
 /*
  * qla1280_initialize_adapter
@@ -2413,12 +2259,12 @@
  * Returns:
  *      0 = success
  */
-STATIC uint8_t
+static int
 qla1280_initialize_adapter(scsi_qla_host_t *ha)
 {
     device_reg_t *reg;
-    uint8_t      status;
-    /* uint8_t      cnt; */
+    int	status;
+    /* int      cnt; */
     uint8_t      b;
 
 #ifdef QL_DEBUG_LEVEL_3
@@ -2460,6 +2306,8 @@
                 status = qla1280_setup_chip(ha); 
             }
         }
+        else
+          printk("initialize: isp_firmware() failed!\n");
 
         if (!status)
         {
@@ -2515,6 +2363,8 @@
                 status = 1;
         }
     }
+    else
+      printk("initialize: pci probe failed!\n");
 
 #if defined(QL_DEBUG_LEVEL_2) || defined(QL_DEBUG_LEVEL_3)
     if (status)
@@ -2538,10 +2388,10 @@
  * Returns:
  *      0 = success.
  */
-STATIC uint8_t
+static int
 qla1280_enable_tgt(scsi_qla_host_t *ha, uint8_t b)
 {
-    uint8_t     status = 0;
+    int status = 0;
     /*  uint16_t    mb[MAILBOX_REGISTER_COUNT]; */
 
 #ifdef QL_DEBUG_LEVEL_3
@@ -2577,14 +2427,14 @@
  * Returns:
  *      0 = firmware does not need to be loaded.
  */
-STATIC uint8_t
+static int
 qla1280_isp_firmware(scsi_qla_host_t *ha)
 {
     nvram_t     *nv    = (nvram_t *)ha->response_ring; 
     uint16_t    *wptr;
+    int		status = 0;    /* dg 2/27 always loads RISC */
+    int		cnt;
     uint8_t     chksum;
-    uint8_t     cnt;
-    uint8_t     status = 0;    /* dg 2/27 always loads RISC */
     uint16_t    mb[MAILBOX_REGISTER_COUNT];
 
     ENTER("qla1280_isp_firmware");
@@ -2666,10 +2516,9 @@
  * Returns:
  *      0 = success.
  */
-STATIC uint8_t
+static int
 qla1280_pci_config(scsi_qla_host_t *ha)
 {
-    uint8_t      status = 1;
 #if MEMORY_MAPPED_IO
     uint32_t  page_offset, base;
     uint32_t   mmapbase;
@@ -2679,6 +2528,7 @@
     uint32_t     command;
     config_reg_t *creg = 0;
 #endif
+    int status = 1;
 
 
     ENTER("qla1280_pci_config");
@@ -2765,12 +2615,9 @@
                 /* Find proper memory chunk for memory map I/O reg. */
                 base = mmapbase & PAGE_MASK;
                 page_offset = mmapbase - base;
+
                 /* Get virtual address for I/O registers. */
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,1,0)
                 ha->mmpbase = ioremap_nocache(base, page_offset + 256);
-#else
-                ha->mmpbase = vremap(base,page_offset + 256);
-#endif
                 if( ha->mmpbase )
                 {
                     ha->mmpbase += page_offset;
@@ -2799,14 +2646,14 @@
  * Returns:
  *      0 = success.
  */
-STATIC uint8_t
+static int
 qla1280_chip_diag(scsi_qla_host_t *ha)
 {
+    uint16_t     mb[MAILBOX_REGISTER_COUNT];
     device_reg_t *reg   = ha->iobase;
-    uint8_t      status = 0;
+    int		 status = 0;
+    int		 cnt;
     uint16_t     data;
-    uint32_t     cnt;
-    uint16_t     mb[MAILBOX_REGISTER_COUNT];
 
 #ifdef QL_DEBUG_LEVEL_3
     sprintf(debug_buff, "qla1280_chip_diag: testing device at 0x%p
\n\r",&reg->id_l);
@@ -2915,21 +2762,21 @@
  *      0 = success.
  */
 #define DUMP_IT_BACK 0   /* for debug of RISC loading */
-STATIC uint8_t
+static int
 qla1280_setup_chip(scsi_qla_host_t *ha)
 {
-    uint8_t      status = 0;
+    int		 status = 0;
     uint16_t     risc_address;
     uint16_t     *risc_code_address;
     long         risc_code_size;
     uint16_t     mb[MAILBOX_REGISTER_COUNT];
-    uint16_t     cnt;
+    uint16_t	 cnt;
     int          num;
 #if DUMP_IT_BACK
     int     i;
     uint8_t *sp;
     uint8_t    *tbuf;
-#if BITS_PER_LONG > 32
+#ifdef QLA_64BIT_PTR
     dma_addr_t     p_tbuf;
 #else
     uint32_t   p_tbuf;
@@ -2942,18 +2789,9 @@
 
     /* 3.13 */
 #if DUMP_IT_BACK
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-    if( (tbuf = (uint8_t *)KMALLOC(8000) ) = NULL )
-    {
-        printk("setup_chip: couldn't alloacte memory\n");
-        return(1);
-    }
-    p_tbuf =  VIRT_TO_BUS(tbuf);
-#else
     /* get consistent memory allocated for setup_chip */
     tbuf   = pci_alloc_consistent(ha->pdev, 8000, &p_tbuf);
 #endif
-#endif
 
     /* Load RISC code. */
     /* 
@@ -2968,7 +2806,7 @@
     DEBUG(printk("qla1280_setup_chip: DMA RISC code (%d) words\n",
          (int)risc_code_size));
     DEBUG(sprintf(debug_buff,
-       "qla1280_setup_chip: DMA RISC code (%d) words\n\r",risc_code_size);)
+       "qla1280_setup_chip: DMA RISC code (%li)
words\n\r",risc_code_size);)
     DEBUG(qla1280_print(debug_buff));
     num =0;
     while (risc_code_size > 0 && !status)
@@ -2980,21 +2818,20 @@
 
         DEBUG(sprintf(debug_buff,
          "qla1280_setup_chip:  loading risc @ =(0x%p),%d,%d(0x%x).\n\r",
-          risc_code_address,cnt,num,risc_address);)
+          (void *)risc_code_address, cnt, num, risc_address);)
         DEBUG(qla1280_print(debug_buff));
-        BCOPY((caddr_t) risc_code_address,(caddr_t) ha->request_ring,
-              (cnt <<1));
+        memcpy(ha->request_ring, risc_code_address, (cnt <<1));
 
-        flush_cache_all(); 
+        flush_cache_all();
 
         mb[0] = MBC_LOAD_RAM; 
         mb[1] = risc_address;
         mb[4] = cnt;
-        mb[3] = (uint16_t)  ha->request_dma & 0xffff;
-        mb[2] = (uint16_t) (ha->request_dma >> 16) & 0xffff;
-        mb[7] = (uint16_t) (MS_64BITS(ha->request_dma) & 0xffff);
-        mb[6] = (uint16_t) (MS_64BITS(ha->request_dma) >> 16) & 0xffff;
-        DEBUG(printk("qla1280_setup_chip: op=%d  0x%p 0x%4x,0x%4x,0x%4x,0x%4x\n",mb[0],ha->request_dma,mb[6],mb[7],mb[2],mb[3]));
+        mb[3] = ha->request_dma & 0xffff;
+        mb[2] = (ha->request_dma >> 16) & 0xffff;
+        mb[7] = MS_64BITS(ha->request_dma) & 0xffff;
+        mb[6] = MS_64BITS(ha->request_dma) >> 16;
+        DEBUG(printk("qla1280_setup_chip: op=%d  0x%p 0x%4x,0x%4x,0x%4x,0x%4x\n",mb[0],(void
*)ha->request_dma,mb[6],mb[7],mb[2],mb[3]));
         if( (status = qla1280_mailbox_command(ha,
BIT_4|BIT_3|BIT_2|BIT_1|BIT_0,
             &mb[0]))  )
         {
@@ -3061,13 +2898,9 @@
 
     /* 3.13 */
 #if DUMP_IT_BACK
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-    KMFREE(tbuf,8000);
-#else
     /* free consistent memory allocated for setup_chip */
     pci_free_consistent(ha->pdev, 8000, tbuf, p_tbuf);
 #endif
-#endif
 
 #if defined(QL_DEBUG_LEVEL_2) || defined(QL_DEBUG_LEVEL_3)
     if (status)
@@ -3093,12 +2926,12 @@
  * Returns:
  *      0 = success.
  */
-STATIC uint8_t
+static int
 qla1280_init_rings(scsi_qla_host_t *ha)
 {
-    uint8_t     status = 0;
-    uint16_t    cnt;
     uint16_t    mb[MAILBOX_REGISTER_COUNT];
+    int		status = 0;
+    int		cnt;
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_init_rings");
@@ -3114,11 +2947,11 @@
     /* mb[0] = MBC_INIT_REQUEST_QUEUE; */
     mb[0] = MBC_INIT_REQUEST_QUEUE_A64;
     mb[1] = REQUEST_ENTRY_CNT;
-    mb[3] = (uint16_t)LS_64BITS(ha->request_dma);
-    mb[2] = (uint16_t)( LS_64BITS(ha->request_dma) >> 16);
+    mb[3] = ha->request_dma & 0xffff;
+    mb[2] = (ha->request_dma >> 16) & 0xffff;
     mb[4] = 0;
-    mb[7] = (uint16_t)MS_64BITS(ha->request_dma);
-    mb[6] = (uint16_t)( MS_64BITS(ha->request_dma) >> 16);
+    mb[7] = MS_64BITS(ha->request_dma) & 0xffff;
+    mb[6] = MS_64BITS(ha->request_dma) >> 16;
     if (!(status = qla1280_mailbox_command(ha,
         BIT_7|BIT_6|BIT_4|BIT_3|BIT_2|BIT_1|BIT_0,
         &mb[0])))
@@ -3129,11 +2962,11 @@
         /* mb[0] = MBC_INIT_RESPONSE_QUEUE; */
         mb[0] = MBC_INIT_RESPONSE_QUEUE_A64;
         mb[1] = RESPONSE_ENTRY_CNT;
-        mb[3] = (uint16_t)LS_64BITS(ha->response_dma);
-        mb[2] = (uint16_t)(LS_64BITS(ha->response_dma) >> 16);
+        mb[3] = ha->response_dma & 0xffff;
+        mb[2] = (ha->response_dma >> 16) & 0xffff;
         mb[5] = 0;
-        mb[7] = (uint16_t)MS_64BITS(ha->response_dma);
-        mb[6] = (uint16_t)(MS_64BITS(ha->response_dma) >> 16);
+        mb[7] = MS_64BITS(ha->response_dma) & 0xffff;
+        mb[6] = MS_64BITS(ha->response_dma) >> 16;
         status = qla1280_mailbox_command(ha,
                 BIT_7|BIT_6|BIT_5|BIT_3|BIT_2|BIT_1|BIT_0,
                 &mb[0]);
@@ -3163,21 +2996,21 @@
  * Returns:
  *      0 = success.
  */
-STATIC uint8_t
+static int
 qla1280_nvram_config(scsi_qla_host_t *ha)
 {
     device_reg_t *reg   = ha->iobase;
     nvram_t      *nv    = (nvram_t *)ha->response_ring; 
-    uint8_t      status = 0;
+    int		 status = 0;
+    int		 cnt;
     uint32_t     b, t, l;
     uint16_t     *wptr;
     uint16_t     mb[MAILBOX_REGISTER_COUNT];
-    uint8_t      cnt;
     uint8_t      chksum;
     uint32_t     nvsize;
 
 #if defined(QL_DEBUG_ROUTINES) && !defined(QL_DEBUG_LEVEL_4)
-    uint8_t      saved_print_status = ql_debug_print;
+    int		 saved_print_status = ql_debug_print;
 #endif
     ENTER("qla1280_nvram_config");
 #if defined(QL_DEBUG_ROUTINES) && !defined(QL_DEBUG_LEVEL_4)
@@ -3216,7 +3049,7 @@
         DEBUG(printk("checksum=0x%x, Id=%c,
version=0x%x\n",chksum,nv->id[0],nv->version));
 #if defined(QL_DEBUG_LEVEL_3)
         /* ql_debug_print = 1;
-        qla1280_dump_buffer((caddr_t)ha->response_ring,
REQUEST_ENTRY_SIZE);
+        qla1280_dump_buffer((char *)ha->response_ring, REQUEST_ENTRY_SIZE);
         ql_debug_print = 0; */
 #endif
                 wptr = (uint16_t *)ha->response_ring;
@@ -3345,7 +3178,7 @@
     ha->flags.disable_risc_code_load              nv->cntr_flags_1.disable_loading_risc_code;
 
-#if BITS_PER_LONG > 32
+#ifdef QLA_64BIT_PTR
     /* Enable 64bit addressing for OS/System combination supporting it   */
     /* actual NVRAM bit is: nv->cntr_flags_1.enable_64bit_addressing     */

     /* but we will ignore it and use BITS_PER_LONG macro to setup for    */
@@ -3359,12 +3192,7 @@
     if (ha->flags.enable_64bit_addressing) {
       printk("[[[ qla1x160: 64 Bit PCI Addressing Enabled ]]]\n");
 
-#if BITS_PER_LONG > 32
-           /* Update our PCI device dma_mask for full 64 bit mask */
-           //ha->pdev->dma_mask = (pci_dma_t) 0xffffffffffffffffull;
-           ha->pdev->dma_mask =  0xffffffffffffffff;
-
-#endif
+      pci_set_dma_mask(ha->pdev, (dma_addr_t)~0ULL);
     }
 #endif
 
@@ -3513,7 +3341,7 @@
  * Returns:
  *      data word.
  */
-STATIC uint16_t
+static uint16_t
 qla1280_get_nvram_word(scsi_qla_host_t *ha, uint32_t address)
 {
     uint32_t nv_cmd;
@@ -3559,11 +3387,11 @@
  * Returns:
  *      data word.
  */
-STATIC uint16_t
+static uint16_t
 qla1280_nvram_request(scsi_qla_host_t *ha, uint32_t nv_cmd)
 {
-    uint8_t      cnt;
     device_reg_t *reg = ha->iobase;
+    int		 cnt;
     uint16_t     data = 0;
     uint16_t     reg_data;
 
@@ -3584,52 +3412,36 @@
     for (cnt = 0; cnt < 16; cnt++)
     {
         WRT_REG_WORD(&reg->nvram, NV_SELECT+NV_CLOCK);
-        /* qla1280_nv_delay(ha); */
         NVRAM_DELAY();
         data <<= 1;
         reg_data = RD_REG_WORD(&reg->nvram);
         if (reg_data & NV_DATA_IN)
             data |= BIT_0;
         WRT_REG_WORD(&reg->nvram, NV_SELECT);
-        /* qla1280_nv_delay(ha); */
         NVRAM_DELAY();
     }
 
     /* Deselect chip. */
 
     WRT_REG_WORD(&reg->nvram, NV_DESELECT);
-    /* qla1280_nv_delay(ha); */
     NVRAM_DELAY();
 
     return(data);
 }
 
-STATIC void
+static void
 qla1280_nv_write(scsi_qla_host_t *ha, uint16_t data)
 {
     device_reg_t *reg = ha->iobase;
 
     WRT_REG_WORD(&reg->nvram, data | NV_SELECT);
     NVRAM_DELAY();
-    /* qla1280_nv_delay(ha); */
     WRT_REG_WORD(&reg->nvram, data | NV_SELECT | NV_CLOCK);
-    /* qla1280_nv_delay(ha); */
     NVRAM_DELAY();
     WRT_REG_WORD(&reg->nvram, data | NV_SELECT);
-    /* qla1280_nv_delay(ha); */
     NVRAM_DELAY();
 }
 
-STATIC void
-qla1280_nv_delay(scsi_qla_host_t *ha)
-{
-    device_reg_t *reg = ha->iobase;
-    int          cnt  = NV_DELAY_COUNT;
-    uint16_t     data = 0;
-
-    while (cnt--)
-        data |= RD_REG_WORD(&reg->nvram);
-}
 
 /*
  * Mailbox Command
@@ -3646,19 +3458,16 @@
  * Returns:
  *      0 = success
  */
-STATIC uint8_t
+static int
 qla1280_mailbox_command(scsi_qla_host_t *ha, uint8_t mr, uint16_t *mb)
 {
     device_reg_t *reg   = ha->iobase;
-    uint8_t      status = 0;
-    uint32_t     cnt;
-    uint16_t     *optr, *iptr;
-    uint16_t     data;
     srb_t        *done_q_first = 0;
     srb_t        *done_q_last = 0;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
+    int		 status = 0;
+    int		 cnt;
+    uint16_t     *optr, *iptr;
+    uint16_t     data;
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_mailbox_command");
@@ -3666,8 +3475,7 @@
 
     /* Acquire interrupt specific lock */
     QLA1280_INTR_LOCK(ha);
-    DRIVER_LOCK
-            ha->flags.mbox_busy = TRUE;
+    ha->flags.mbox_busy = TRUE;
 
     /* Load mailbox registers. */
     optr = (uint16_t *)&reg->mailbox0;
@@ -3728,9 +3536,8 @@
 
     /* Release interrupt specific lock */
     QLA1280_INTR_UNLOCK(ha);
-    DRIVER_UNLOCK
 
-            if (ha->flags.isp_abort_needed)
+    if (ha->flags.isp_abort_needed)
         qla1280_abort_isp(ha);
 
     if (ha->flags.reset_marker)
@@ -3761,7 +3568,7 @@
  * Input:
  *      ha = adapter block pointer.
  */
-STATIC void
+static void
 qla1280_poll(scsi_qla_host_t *ha)
 {
     device_reg_t    *reg   = ha->iobase;
@@ -3811,19 +3618,19 @@
  * Returns:
  *      0 = success
  */
-STATIC uint8_t
-qla1280_bus_reset(scsi_qla_host_t *ha, uint8_t b)
+static int
+qla1280_bus_reset(scsi_qla_host_t *ha, u8 b)
 {
-    uint8_t     status;
     uint16_t    mb[MAILBOX_REGISTER_COUNT];
+    int status;
 
 #ifdef QL_DEBUG_LEVEL_3
     qla1280_print("qla1280_bus_reset: entered\n\r");
 #endif
-   if( qla1280_verbose )
-   {
-    printk("scsi(%d): Resetting SCSI BUS (%d)\n",(int)ha->host_no,b);
-   }
+    if( qla1280_verbose )
+    {
+      printk("scsi(%li): Resetting SCSI BUS (%i)\n", ha->host_no, b);
+    }
 
     mb[0] = MBC_BUS_RESET;
     mb[1] = ha->bus_settings[b].bus_reset_delay;
@@ -3867,11 +3674,11 @@
  * Returns:
  *      0 = success
  */
-STATIC uint8_t
+static int
 qla1280_device_reset(scsi_qla_host_t *ha, uint8_t b, uint32_t t)
 {
-    uint8_t     status;
     uint16_t    mb[MAILBOX_REGISTER_COUNT];
+    int status;
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_device_reset");
@@ -3909,11 +3716,11 @@
  * Returns:
  *      0 = success
  */
-STATIC uint8_t
-qla1280_abort_device(scsi_qla_host_t *ha, uint8_t b, uint32_t t, uint32_t
l)
+static int
+qla1280_abort_device(scsi_qla_host_t *ha, u8 b, u32 t, u32 l)
 {
-    uint8_t     status;
     uint16_t    mb[MAILBOX_REGISTER_COUNT];
+    int status;
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_abort_device");
@@ -3948,13 +3755,13 @@
  * Returns:
  *      0 = success
  */
-STATIC uint8_t
+static int
 qla1280_abort_command(scsi_qla_host_t *ha, srb_t *sp)
 {
-    uint8_t         status;
-    uint16_t        mb[MAILBOX_REGISTER_COUNT];
-    uint32_t        b, t, l;
-    uint32_t        handle;
+    uint16_t	mb[MAILBOX_REGISTER_COUNT];
+    uint32_t	b, t, l;
+    uint32_t	handle;
+    int		status;
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_abort_command");
@@ -3972,7 +3779,7 @@
         mb[0] = MBC_ABORT_COMMAND;
         mb[1] = (b ? t | BIT_7 : t) << 8 | l;
         mb[2] = handle >> 16;
-        mb[3] = (uint16_t)handle;
+        mb[3] = handle & 0xffff;
         status = qla1280_mailbox_command(ha, BIT_3|BIT_2|BIT_1|BIT_0,
&mb[0]);
 
 #if defined(QL_DEBUG_LEVEL_2) || defined(QL_DEBUG_LEVEL_3)
@@ -3992,7 +3799,7 @@
  * Input:
  *      ha = adapter block pointer.
  */
-STATIC void
+static void
 qla1280_reset_adapter(scsi_qla_host_t *ha)
 {
     device_reg_t *reg = ha->iobase;
@@ -4019,15 +3826,15 @@
  *
  * Input:
  *      ha   = adapter block pointer.
- *      b    = SCSI BUS number
- *      t    = SCSI ID
- *      l    = SCSI LUN
+ *      bus  = SCSI BUS number
+ *      id   = SCSI ID
+ *      lun  = SCSI LUN
  *      type = marker modifier
  */
-STATIC void
-qla1280_marker(scsi_qla_host_t *ha, uint8_t b, uint32_t t, uint32_t l,
uint8_t type)
+static void
+qla1280_marker(scsi_qla_host_t *ha, u8 bus, u32 id, u32 lun, u8 type)
 {
-    mrk_entry_t     *pkt;
+    mrk_entry_t *pkt;
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_marker");
@@ -4037,8 +3844,8 @@
     if ( (pkt = (mrk_entry_t *)qla1280_req_pkt(ha)) )
     {
         pkt->entry_type = MARKER_TYPE;
-        pkt->lun = (uint8_t)l;
-        pkt->target = (uint8_t)(b ? (t | BIT_7) : t);
+        pkt->lun = (uint8_t)lun;
+        pkt->target = (uint8_t)(bus ? (id | BIT_7) : id);
         pkt->modifier = type;
 
         /* Issue command to ISP */
@@ -4063,24 +3870,25 @@
  * Returns:
  *      0 = success, was able to issue command.
  */
-STATIC uint8_t
+static int
 qla1280_64bit_start_scsi(scsi_qla_host_t *ha, srb_t *sp)
 {
-    device_reg_t    *reg   = ha->iobase;
-    uint8_t         status = 0;
-    Scsi_Cmnd       *cmd = sp->cmd;
-    uint32_t        cnt;
-    cmd_a64_entry_t     *pkt;
-    uint16_t        req_cnt;
-    uint16_t        seg_cnt;
-    struct scatterlist    *sg = (struct scatterlist *) NULL;
-    uint32_t        *dword_ptr;
-    dma_addr_t       dma_handle;
+    device_reg_t *reg = ha->iobase;
+    Scsi_Cmnd *cmd = sp->cmd;
+    cmd_a64_entry_t *pkt;
+    struct scatterlist *sg = (struct scatterlist *) NULL;
+    u32	*dword_ptr;
+    dma_addr_t	    dma_handle;
+    int	status = 0;
+    int cnt;
+    u16 req_cnt;
+    u16	seg_cnt;
 
     ENTER("qla1280_64bit_start_scsi:");
 
     DEBUG(sprintf(debug_buff,
-          "64bit_start: cmd=%x sp=%x CDB=%x\n\r",cmd,sp,cmd->cmnd[0]);)
+                  "64bit_start: cmd=%p sp=%p CDB=%x\n\r",
+                  (void *)cmd, (void *)sp, cmd->cmnd[0]);)
     DEBUG(qla1280_print(debug_buff));
 
     if( qla1280_check_for_dead_scsi_bus(ha, sp) )
@@ -4099,8 +3907,8 @@
             
         if (seg_cnt > 2)
         {
-           req_cnt += (uint16_t)(seg_cnt - 2) / 5;
-           if ((uint16_t)(seg_cnt - 2) % 5)
+           req_cnt += (seg_cnt - 2) / 5;
+           if ((seg_cnt - 2) % 5)
                req_cnt++;
         }
     }
@@ -4113,7 +3921,7 @@
     /* Acquire ring specific lock */
     QLA1280_RING_LOCK(ha);
 
-    if ((uint16_t)(req_cnt + 2) >= ha->req_q_cnt)
+    if ((req_cnt + 2) >= ha->req_q_cnt)
     {
         /* Calculate number of free request entries. */
         cnt = RD_REG_WORD(&reg->mailbox4);
@@ -4124,7 +3932,7 @@
     }
 
     /* If room for request in request ring. */
-    if ((uint16_t)(req_cnt + 2) < ha->req_q_cnt)
+    if ((req_cnt + 2) < ha->req_q_cnt)
     {
         /* Check for room in outstanding command list. */
         for (cnt = 1; cnt < MAX_OUTSTANDING_COMMANDS &&
@@ -4166,7 +3974,7 @@
 
             /* Load SCSI command packet. */
             pkt->cdb_len = (uint16_t)CMD_CDBLEN(cmd);
-            BCOPY(&(CMD_CDBP(cmd)), pkt->scsi_cdb, pkt->cdb_len);
+            memcpy(pkt->scsi_cdb, &(CMD_CDBP(cmd)), pkt->cdb_len);
             //DEBUG(printk("Build packet for
command[0]=0x%x\n",pkt->scsi_cdb[0]));
 
             /*
@@ -4215,7 +4023,7 @@
                     qla1280_print(" d ");
                     qla1280_output_number((uint32_t)SCSI_LUN_32(cmd), 10);
                     qla1280_print("\n\r");
-                    qla1280_dump_buffer((caddr_t)pkt, REQUEST_ENTRY_SIZE);
+                    qla1280_dump_buffer((char *)pkt, REQUEST_ENTRY_SIZE);
 #endif
                     /*
                     * Build continuation packets.
@@ -4280,7 +4088,7 @@
                         qla1280_print(" d ");
                         qla1280_output_number((uint32_t)SCSI_LUN_32(cmd),
10);
                         qla1280_print("\n\r");
-                        qla1280_dump_buffer((caddr_t)pkt,
REQUEST_ENTRY_SIZE);
+                        qla1280_dump_buffer((char *)pkt,
REQUEST_ENTRY_SIZE);
 #endif
                     }
                 }
@@ -4309,7 +4117,7 @@
                     qla1280_print(" d ");
                     qla1280_output_number((uint32_t)SCSI_LUN_32(cmd), 10);
                     qla1280_print("\n\r");
-                    qla1280_dump_buffer((caddr_t)pkt, REQUEST_ENTRY_SIZE);
+                    qla1280_dump_buffer((char *)pkt, REQUEST_ENTRY_SIZE);
 #endif
                 }
             }
@@ -4328,7 +4136,7 @@
                 qla1280_print(" d ");
                 qla1280_output_number((uint32_t)SCSI_LUN_32(cmd), 10);
                 qla1280_print("\n\r");
-                qla1280_dump_buffer((caddr_t)pkt, REQUEST_ENTRY_SIZE);
+                qla1280_dump_buffer((char *)pkt, REQUEST_ENTRY_SIZE);
 #endif
             }
             /* Adjust ring index. */
@@ -4355,7 +4163,7 @@
             qla1280_print(
                     "qla1280_64bit_start_scsi: NO ROOM IN OUTSTANDING
ARRAY\n\r");
             qla1280_print(" req_q_cnt=");
-            qla1280_output_number((uint32_t)ha->req_q_cnt, 16);
+            qla1280_output_number((u32)ha->req_q_cnt, 16);
 #endif
         }
     }
@@ -4366,9 +4174,9 @@
         qla1280_print("qla1280_64bit_start_scsi: in-ptr=");
         qla1280_output_number((uint32_t)ha->req_ring_index, 16);
         qla1280_print(" req_q_cnt=");
-        qla1280_output_number((uint32_t)ha->req_q_cnt, 16);
+        qla1280_output_number((u32)ha->req_q_cnt, 16);
         qla1280_print(" req_cnt=");
-        qla1280_output_number((uint32_t)req_cnt, 16);
+        qla1280_output_number(req_cnt, 16);
         qla1280_print("\n\r");
 #endif
     }
@@ -4407,19 +4215,19 @@
  * Returns:
  *      0 = success, was able to issue command.
  */
-STATIC uint8_t
+static int
 qla1280_32bit_start_scsi(scsi_qla_host_t *ha, srb_t *sp)
 {
     device_reg_t    *reg   = ha->iobase;
-    uint8_t         status = 0;
     Scsi_Cmnd       *cmd = sp->cmd;
-    uint32_t        cnt;
     cmd_entry_t     *pkt;
-    uint16_t        req_cnt;
-    uint16_t        seg_cnt;
     struct scatterlist    *sg = (struct scatterlist *) NULL;
     uint8_t        *data_ptr;
     uint32_t        *dword_ptr;
+    int status = 0;
+    int cnt;
+    int req_cnt;
+    uint16_t        seg_cnt;
 
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
     dma_addr_t       dma_handle;
@@ -4428,7 +4236,8 @@
     ENTER("qla1280_32bit_start_scsi");
 
     DEBUG(sprintf(debug_buff,
-          "32bit_start: cmd=%x sp=%x CDB=%x\n\r",cmd,sp,cmd->cmnd[0]);)
+                  "32bit_start: cmd=%p sp=%p CDB=%x\n\r",
+                  (void *)cmd, (void *)sp, cmd->cmnd[0]));
     DEBUG(qla1280_print(debug_buff));
 
     if( qla1280_check_for_dead_scsi_bus(ha, sp) )
@@ -4441,24 +4250,20 @@
     if (cmd->use_sg)
     {
         /*
-        * We must build an SG list in adapter format, as the kernel's SG
list
-        * cannot be used directly because of data field size (__alpha__)
-        * differences and the kernel SG list uses virtual addresses where
-        * we need physical addresses.
-        */
+         * We must build an SG list in adapter format, as the kernel's SG
list
+         * cannot be used directly because of data field size (__alpha__)
+         * differences and the kernel SG list uses virtual addresses where
+         * we need physical addresses.
+         */
         sg = (struct scatterlist *) cmd->request_buffer;
         /* 3.13 32 bit */
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-        seg_cnt =  cmd->use_sg;
-#else
-        seg_cnt = pci_map_sg(ha->pdev,sg,cmd->use_sg, 
-                    scsi_to_pci_dma_dir(cmd->sc_data_direction));
-#endif
+        seg_cnt = pci_map_sg(ha->pdev, sg, cmd->use_sg, 
+                             scsi_to_pci_dma_dir(cmd->sc_data_direction));
 
         /* 
-        * if greater than four sg entries then we need to allocate
-        * continuation entries
-        */
+         * if greater than four sg entries then we need to allocate
+         * continuation entries
+         */
         if (seg_cnt > 4)
         {
             req_cnt += (uint16_t)(seg_cnt - 4) / 7;
@@ -4466,15 +4271,15 @@
                 req_cnt++;
         }
         DEBUG(sprintf(debug_buff,
-         "S/G Transfer cmd=%x seg_cnt=0x%x, req_cnt=%x\n\r",
-          cmd,seg_cnt,req_cnt));
+         "S/G Transfer cmd=%p seg_cnt=0x%x, req_cnt=%x\n\r",
+          (void *)cmd,seg_cnt,req_cnt));
         DEBUG(qla1280_print(debug_buff));
     }
     else if (cmd->request_bufflen)  /* If data transfer. */
     {
         DEBUG(sprintf(debug_buff,
-         "No S/G transfer t=%x cmd=%x len=%x CDB=%x\n\r",
-         SCSI_TCN_32(cmd),cmd,cmd->request_bufflen,cmd->cmnd[0]));
+         "No S/G transfer t=%x cmd=%p len=%x CDB=%x\n\r",
+         SCSI_TCN_32(cmd), (void *)cmd,cmd->request_bufflen,cmd->cmnd[0]));
         DEBUG(qla1280_print(debug_buff));
         seg_cnt = 1;
     }
@@ -4487,7 +4292,7 @@
     /* Acquire ring specific lock */
     QLA1280_RING_LOCK(ha);
 
-    if ((uint16_t)(req_cnt + 2) >= ha->req_q_cnt)
+    if ((req_cnt + 2) >= ha->req_q_cnt)
     {
         /* Calculate number of free request entries. */
         cnt = RD_REG_WORD(&reg->mailbox4);
@@ -4501,7 +4306,7 @@
           ha->req_q_cnt,seg_cnt));
     DEBUG(qla1280_print(debug_buff));
     /* If room for request in request ring. */
-    if ((uint16_t)(req_cnt + 2) < ha->req_q_cnt)
+    if ((req_cnt + 2) < ha->req_q_cnt)
     {
         /* Check for empty slot in outstanding command list. */
         for (cnt = 1; cnt < MAX_OUTSTANDING_COMMANDS &&
@@ -4575,18 +4380,20 @@
 
                 if (cmd->use_sg)     /* If scatter gather */
                 {
+#if QL_DEBUG_ROUTINES
                     DEBUG(qla1280_print("Building S/G data
segments..\n\r"));
-                    DEBUG(qla1280_dump_buffer((caddr_t)sg, 4*16 ));
+                    DEBUG(qla1280_dump_buffer((char *)sg, 4*16 ));
+#endif
                     /* Load command entry data segments. */
                     for (cnt = 0; cnt < 4 && seg_cnt; cnt++, seg_cnt--)
                     {
                         /* 3.13 32 bit */
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-                        *dword_ptr++ = (uint32_t)
cpu_to_le32(VIRT_TO_BUS(sg->address));
+                        *dword_ptr++ cpu_to_le32(virt_to_bus(sg->address));
                         *dword_ptr++ = sg->length;
                         DEBUG(sprintf(debug_buff,
                          "S/G Segment phys_addr=0x%x, len=0x%x\n\r",
-
cpu_to_le32(VIRT_TO_BUS(sg->address)),sg->length));
+
cpu_to_le32(virt_to_bus(sg->address)),sg->length));
                         DEBUG(qla1280_print(debug_buff));
 #else
                         *dword_ptr++ cpu_to_le32(pci_dma_lo32(sg_dma_address(sg)));
@@ -4642,11 +4449,11 @@
                         {
                            /* 3.13 32 bit */
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-                           *dword_ptr++ = (u_int)
cpu_to_le32(VIRT_TO_BUS(sg->address));
+                           *dword_ptr++ cpu_to_le32(virt_to_bus(sg->address));
                            *dword_ptr++ = sg->length;
                            DEBUG(sprintf(debug_buff,
                            "S/G Segment Cont. phys_addr=0x%x,
len=0x%x\n\r",
-
cpu_to_le32(pci_dma_lo32(VIRT_TO_BUS(sg->address))),
+
cpu_to_le32(pci_dma_lo32(virt_to_bus(sg->address))),
                            sg->length);)
                            DEBUG(qla1280_print(debug_buff));
 #else
@@ -4669,7 +4476,7 @@
                         qla1280_print(":");
                         qla1280_output_number((uint32_t)SCSI_LUN_32(cmd),
10);
                         qla1280_print(")\n\r");
-                        qla1280_dump_buffer((caddr_t)pkt,
REQUEST_ENTRY_SIZE);
+                        qla1280_dump_buffer((char *)pkt,
REQUEST_ENTRY_SIZE);
 #endif
                     }
                 }
@@ -4677,7 +4484,7 @@
                 {
                     /* 3.13 32 bit */
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-                    *dword_ptr++ = (uint32_t)
cpu_to_le32(VIRT_TO_BUS(cmd->request_buffer));
+                    *dword_ptr++ cpu_to_le32(virt_to_bus(cmd->request_buffer));
                     *dword_ptr = (uint32_t) cmd->request_bufflen;
 #else
                     dma_handle = pci_map_single(ha->pdev, 
@@ -4702,12 +4509,12 @@
                 qla1280_print(
                         "qla1280_32bit_start_scsi: No data, command packet
data - ");
                 qla1280_print("\n\r");
-                qla1280_dump_buffer((caddr_t)pkt, REQUEST_ENTRY_SIZE);
+                qla1280_dump_buffer((char *)pkt, REQUEST_ENTRY_SIZE);
 #endif
             }
 #ifdef QL_DEBUG_LEVEL_5
             qla1280_print("qla1280_32bit_start_scsi: First IOCB
block:\n\r");
-            qla1280_dump_buffer((caddr_t)ha->request_ring_ptr,
REQUEST_ENTRY_SIZE);
+            qla1280_dump_buffer((char *)ha->request_ring_ptr,
REQUEST_ENTRY_SIZE);
 #endif
             /* Adjust ring index. */
             ha->req_ring_index++;
@@ -4733,7 +4540,7 @@
             qla1280_print(
             "qla1280_32bit_start_scsi: NO ROOM IN OUTSTANDING ARRAY\n\r");
             qla1280_print(" req_q_cnt=");
-            qla1280_output_number((uint32_t)ha->req_q_cnt, 16);
+            qla1280_output_number((u32)ha->req_q_cnt, 16);
             qla1280_print("\n\r");
 #endif
         }
@@ -4745,9 +4552,9 @@
         /*  qla1280_print("qla1280_32bit_start_scsi: in-ptr=");
         qla1280_output_number((uint32_t)ha->req_ring_index, 16);
         qla1280_print(" req_q_cnt=");
-        qla1280_output_number((uint32_t)ha->req_q_cnt, 16);
+        qla1280_output_number((u32)ha->req_q_cnt, 16);
         qla1280_print(" req_cnt=");
-        qla1280_output_number((uint32_t)req_cnt, 16);
+        qla1280_output_number(req_cnt, 16);
         qla1280_print("\n\r"); */
 #endif
     }
@@ -4777,12 +4584,12 @@
  * Returns:
  *      0 = failed to get slot.
  */
-STATIC request_t *
+static request_t *
 qla1280_req_pkt(scsi_qla_host_t *ha)
 {
     device_reg_t    *reg = ha->iobase;
     request_t       *pkt = 0;
-    uint16_t        cnt;
+    int		    cnt;
     uint32_t        *dword_ptr;
     uint32_t        timer;
 
@@ -4854,7 +4661,7 @@
  * Input:
  *      ha  = adapter block pointer.
  */
-STATIC void
+static void
 qla1280_isp_cmd(scsi_qla_host_t *ha)
 {
     device_reg_t    *reg = ha->iobase;
@@ -4865,7 +4672,7 @@
 
 #ifdef QL_DEBUG_LEVEL_5
     qla1280_print("qla1280_isp_cmd: IOCB data:\n\r");
-    qla1280_dump_buffer((caddr_t)ha->request_ring_ptr, REQUEST_ENTRY_SIZE);

+    qla1280_dump_buffer((char *)ha->request_ring_ptr, REQUEST_ENTRY_SIZE); 
 #endif
 
     /* Adjust ring index. */
@@ -4889,6 +4696,7 @@
 #endif
 }
 
+#if QL1280_LUN_SUPPORT
 /*
  * qla1280_enable_lun
  *      Issue enable LUN entry IOCB.
@@ -4898,7 +4706,7 @@
  *      b  = SCSI BUS number.
  *      l  = LUN number.
  */
-STATIC void
+static void
 qla1280_enable_lun(scsi_qla_host_t *ha, uint8_t b, uint32_t l)
 {
     elun_entry_t    *pkt;
@@ -4933,6 +4741,7 @@
         qla1280_print("qla1280_enable_lun: exiting normally\n\r");
 #endif
 }
+#endif
 
 #if QL1280_TARGET_MODE_SUPPORT
 
/***************************************************************************
*/
@@ -4949,7 +4758,7 @@
  *      ha      = adapter block pointer.
  *      inotify = immediate notify entry pointer.
  */
-STATIC void
+static void
 qla1280_notify_ack(scsi_qla_host_t *ha, notify_entry_t *inotify)
 {
     nack_entry_t    *pkt;
@@ -4992,7 +4801,7 @@
  *      ha      = adapter block pointer.
  *      inotify = immediate notify entry pointer.
  */
-STATIC void
+static void
 qla1280_immed_notify(scsi_qla_host_t *ha, notify_entry_t *inotify)
 {
     notify_entry_t    *pkt;
@@ -5032,7 +4841,7 @@
  *      ha = adapter block pointer.
  *      ctio = ctio returned entry pointer.
  */
-STATIC void
+static void
 qla1280_accept_io(scsi_qla_host_t *ha, ctio_ret_entry_t *ctio)
 {
     atio_entry_t    *pkt;
@@ -5075,7 +4884,7 @@
  *      len  = total bytecount.
  *      addr = physical address pointer.
  */
-STATIC void
+static void
 qla1280_64bit_continue_io(scsi_qla_host_t *ha, atio_entry_t *atio, uint32_t
len,
                     paddr32_t *addr)
 {
@@ -5131,7 +4940,7 @@
  *      len  = total bytecount.
  *      addr = physical address pointer.
  */
-STATIC void
+static void
 qla1280_32bit_continue_io(scsi_qla_host_t *ha, atio_entry_t *atio, uint32_t
len,
                     paddr32_t *addr)
 {
@@ -5191,7 +5000,7 @@
  *      done_q_last  = done queue last pointer.
  *      INTR_LOCK must be already obtained.
 
****************************************************************************
/
-STATIC void
+static void
 qla1280_isr(scsi_qla_host_t *ha, srb_t **done_q_first, srb_t **done_q_last)
 {
     device_reg_t    *reg = ha->iobase;
@@ -5389,7 +5198,7 @@
                 qla1280_print(" mailbox[5] = ");
                 qla1280_output_number((uint32_t)mailbox[5], 16);
                 qla1280_print("\n\rqla1280_isr: response packet data\n\r");
-                qla1280_dump_buffer((caddr_t)pkt, RESPONSE_ENTRY_SIZE);
+                qla1280_dump_buffer((char *)pkt, RESPONSE_ENTRY_SIZE);
 #endif
 
 #if defined(QL_DEBUG_LEVEL_2) && !defined(QL_DEBUG_LEVEL_5)
@@ -5411,7 +5220,7 @@
                         DEBUG(qla1280_print( "\n\r");)
                         /* qla1280_print(
                         "\n\rqla1280_isr: response packet data\n\r");
-                        qla1280_dump_buffer((caddr_t)pkt,
+                        qla1280_dump_buffer((char *)pkt,
                         RESPONSE_ENTRY_SIZE); */
                     }
                 }
@@ -5423,7 +5232,7 @@
                     qla1280_output_number((uint32_t)mailbox[5], 16);
                     qla1280_print(
                             "\n\rqla1280_isr: response packet data\n\r");
-                    qla1280_dump_buffer((caddr_t)pkt, RESPONSE_ENTRY_SIZE);
+                    qla1280_dump_buffer((char *)pkt, RESPONSE_ENTRY_SIZE);
                 }
 #endif
                 if (pkt->entry_type = STATUS_TYPE || pkt->entry_status)
@@ -5512,7 +5321,7 @@
  * Input:
  *      ha  = adapter block pointer.
  */
-STATIC void
+static void
 qla1280_rst_aen(scsi_qla_host_t *ha)
 {
 #if QL1280_TARGET_MODE_SUPPORT
@@ -5543,7 +5352,7 @@
                     {
 #if QL1280_TARGET_MODE_SUPPORT
                         /* Issue notify acknowledgement command. */
-                        bzero((caddr_t)&nentry, sizeof(notify_entry_t));
+                        memset(&nentry, 0, sizeof(notify_entry_t));
 
                         nentry.initiator_id = nentry.target_id = b ?
                                 ha->bus_settings[b].id | BIT_7 :
@@ -5572,7 +5381,7 @@
  *      ha  = adapter block pointer.
  *      pkt = entry pointer.
  */
-STATIC void
+static void
 qla1280_atio_entry(scsi_qla_host_t *ha, atio_entry_t *pkt)
 {
     uint64_t    *a64;
@@ -5607,11 +5416,11 @@
 #endif
             if (pkt->status & BIT_7)
             {
-                BCOPY((caddr_t)&pkt->sense_data,
sense_ptr,TARGET_SENSE_SIZE);
+                memcpy(sense_ptr, &pkt->sense_data, TARGET_SENSE_SIZE);
             }
             else
             {
-                    bzero(sense_ptr, TARGET_SENSE_SIZE);
+                    memset(sense_ptr, 0, TARGET_SENSE_SIZE);
                     *sense_ptr = 0x70;
                     *(sense_ptr+2) = SD_HARDERR;
                     *(sense_ptr+7) = TARGET_SENSE_SIZE-8;
@@ -5652,7 +5461,7 @@
 #ifdef QL_DEBUG_LEVEL_3
                     qla1280_print("qla1280_atio_entry: SS_TEST\n\r");
 #endif
-                    bzero(sense_ptr, TARGET_SENSE_SIZE);
+                    memset(sense_ptr, 0, TARGET_SENSE_SIZE);
                     len = 0;
                     if (pkt->lun = 0)
                         pkt->scsi_status = S_GOOD;
@@ -5687,7 +5496,7 @@
 #ifdef QL_DEBUG_LEVEL_3
                     qla1280_print("qla1280_atio_entry: SS_INQUIR\n\r");
 #endif
-                    bzero(sense_ptr, TARGET_SENSE_SIZE);
+                    memset(sense_ptr, 0, TARGET_SENSE_SIZE);
                     phy_addr[0] = ha->tbuf_dma;
                     phy_addr[1] = 0;
                     *a64 += TARGET_INQ_OFFSET;
@@ -5712,7 +5521,7 @@
                             (uint32_t)OF_DATA_IN;
                     break;
                 case SM_WRDB:
-                    bzero(sense_ptr, TARGET_SENSE_SIZE);
+                    memset(sense_ptr, 0, TARGET_SENSE_SIZE);
                     offset = pkt->cdb[5];
                     offset |= pkt->cdb[4] << 8;
                     offset |= pkt->cdb[3] << 16;
@@ -5828,7 +5637,7 @@
                     }
                     break;
                 case SM_RDDB:
-                    bzero(sense_ptr, TARGET_SENSE_SIZE);
+                    memset(sense_ptr, 0, TARGET_SENSE_SIZE);
                     offset = pkt->cdb[5];
                     offset |= pkt->cdb[4] << 8;
                     offset |= pkt->cdb[3] << 16;
@@ -5970,9 +5779,9 @@
                 default:
 #ifdef QL_DEBUG_LEVEL_2
                     qla1280_print("qla1280_atio_entry: Unknown SCSI
command\n\r");
-                    qla1280_dump_buffer((caddr_t)&pkt->cdb[0],
pkt->cdb_len);
+                    qla1280_dump_buffer(&pkt->cdb[0], pkt->cdb_len);
 #endif
-                    bzero(sense_ptr, TARGET_SENSE_SIZE);
+                    memset(sense_ptr, 0, TARGET_SENSE_SIZE);
                     *sense_ptr = 0x70;
                     *(sense_ptr+2) = SD_ILLREQ;
                     *(sense_ptr+7) = TARGET_SENSE_SIZE-8;
@@ -6007,7 +5816,7 @@
  *      ha  = adapter block pointer.
  *      pkt = entry pointer.
  */
-STATIC void
+static void
 qla1280_notify_entry(scsi_qla_host_t *ha, notify_entry_t *pkt)
 {
 #ifdef QL_DEBUG_LEVEL_3
@@ -6036,7 +5845,7 @@
  *      done_q_first = done queue first pointer.
  *      done_q_last  = done queue last pointer.
  */
-STATIC void
+static void
 qla1280_status_entry(scsi_qla_host_t *ha, sts_entry_t *pkt, srb_t
**done_q_first,
                      srb_t **done_q_last)
 {
@@ -6097,7 +5906,7 @@
 
             if (pkt->scsi_status & SS_CHECK_CONDITION)
             {
-                BZERO(cp->sense_buffer, CMD_SNSLEN(cp));
+                memset(cp->sense_buffer, 0, CMD_SNSLEN(cp));
                 if (pkt->comp_status != CS_ARS_FAILED)
                 {
                     if ( pkt->req_sense_length < CMD_SNSLEN(cp)  )
@@ -6105,7 +5914,7 @@
                     else
                         sense_sz = CMD_SNSLEN(cp) - 1;
 
-                    BCOPY((caddr_t)&pkt->req_sense_data, cp->sense_buffer,
sense_sz);
+                    memcpy(cp->sense_buffer, &pkt->req_sense_data,
sense_sz);
 
                 }
 #ifdef QL_DEBUG_LEVEL_2
@@ -6118,7 +5927,7 @@
                 DEBUG(qla1280_output_number((uint32_t)l, 10);)
                 DEBUG(qla1280_print("\n\r");)
                 DEBUG(if (sense_sz))
-                    DEBUG(qla1280_dump_buffer(cp->sense_buffer, sense_sz);)
+                    DEBUG(qla1280_dump_buffer((char *)cp->sense_buffer,
sense_sz);)
 #endif
             }
         }
@@ -6148,7 +5957,7 @@
  *      done_q_first = done queue first pointer.
  *      done_q_last  = done queue last pointer.
  */
-STATIC void
+static void
 qla1280_error_entry(scsi_qla_host_t *ha, response_t *pkt, srb_t
**done_q_first,
                     srb_t **done_q_last)
 {
@@ -6199,7 +6008,7 @@
         /* Place command on done queue. */
         qla1280_done_q_put(sp, done_q_first, done_q_last);
     }
-#if  BITS_PER_LONG > 32
+#ifdef QLA_64BIT_PTR
     else if (pkt->entry_type = COMMAND_A64_TYPE)
     {
 #ifdef QL_DEBUG_LEVEL_2
@@ -6225,25 +6034,21 @@
  * Returns:
  *      0 = success
  */
-STATIC uint8_t
+static int
 qla1280_abort_isp(scsi_qla_host_t *ha)
 {
     device_reg_t    *reg = ha->iobase;
-    uint8_t         status = 0;
-    uint16_t        cnt;
     srb_t           *sp;
     scsi_lu_t       *q;
+    int		    status = 0;
+    int		    cnt;
     uint32_t        b, t, l;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-    unsigned long cpu_flags = 0;
-#endif
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_abort_isp");
 #endif
 
-    DRIVER_LOCK
-            ha->flags.isp_abort_needed = FALSE;
+    ha->flags.isp_abort_needed = FALSE;
     if (!ha->flags.abort_isp_active && ha->flags.online)
     {
         ha->flags.abort_isp_active = TRUE;
@@ -6329,7 +6134,7 @@
                 if (!status)
                 { 
                     /* Enable ISP interrupts. */
-                    WRT_REG_WORD(&reg->ictrl, ISP_EN_INT + ISP_EN_RISC);
+                    WRT_REG_WORD(&reg->ictrl, (ISP_EN_INT | ISP_EN_RISC));
                     ha->flags.abort_isp_active = FALSE;
                     /* Restart queues that may have been stopped. */
                     qla1280_restart_queues(ha);
@@ -6353,9 +6158,8 @@
     else
         LEAVE("qla1280_abort_isp");
 #endif
-    DRIVER_UNLOCK
 
-            return(status);
+    return(status);
 }
 
 /*
@@ -6365,7 +6169,7 @@
  * Input:
  *      ha = adapter block pointer.
  */
-STATIC void
+static void
 qla1280_restart_queues(scsi_qla_host_t *ha)
 {
     scsi_lu_t *q;
@@ -6404,7 +6208,7 @@
  * Input:
  *      ha = adapter block pointer.
  */
-STATIC void qla1280_abort_queue_single(scsi_qla_host_t *ha,uint32_t
b,uint32_t t,uint32_t l,uint32_t stat)
+static void qla1280_abort_queue_single(scsi_qla_host_t *ha,uint32_t
b,uint32_t t,uint32_t l,uint32_t stat)
 {
     scsi_lu_t *q;
     srb_t     *sp, *sp_next; 
@@ -6439,7 +6243,7 @@
  * Input:
  *      ha = adapter block pointer.
  */
-STATIC void
+static void
 qla1280_abort_queues(scsi_qla_host_t *ha)
 {
     uint32_t  b, t, l;
@@ -6464,11 +6268,11 @@
  * Returns:
  *      register value.
  */
-STATIC uint16_t
-qla1280_debounce_register(volatile uint16_t *addr)
+static u16
+qla1280_debounce_register(volatile u16 *addr)
 {
-    volatile uint16_t ret;
-    volatile uint16_t ret2;
+    volatile u16 ret;
+    volatile u16 ret2;
 
     do
     {
@@ -6496,7 +6300,7 @@
  ************************************************************************/
 #define SET_SXP_BANK            0x0100
 #define SCSI_PHASE_INVALID      0x87FF
-int  qla1280_check_for_dead_scsi_bus(scsi_qla_host_t *ha, srb_t *sp)
+int qla1280_check_for_dead_scsi_bus(scsi_qla_host_t *ha, srb_t *sp)
 {
     uint16_t  config_reg, scsi_control;
     device_reg_t    *reg = ha->iobase;
@@ -6522,15 +6326,11 @@
         if (scsi_control = SCSI_PHASE_INVALID)
         {
             CMD_RESULT(cp) = DID_NO_CONNECT << 16;
-            CMD_HANDLE(cp) = (unsigned char *) 0;
+            CMD_HANDLE(cp) = NULL;
             /* ha->actthreads--; */
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-            sti(); 
-            (*(cp)->scsi_done)(cp);
-            cli(); 
-#else
+
             (*(cp)->scsi_done)(cp);
-#endif
+
             return(TRUE);   /* bus is dead */
         }
         else
@@ -6542,8 +6342,9 @@
     return(FALSE);   /* bus is not dead */
 }
 
-STATIC uint8_t
-qla12160_set_target_parameters(scsi_qla_host_t *ha, uint32_t b, uint32_t t,
uint32_t l, nvram160_t *nv)
+static int
+qla12160_set_target_parameters(scsi_qla_host_t *ha, uint32_t b,
+                               uint32_t t, uint32_t l, nvram160_t *nv)
 {
     uint16_t        mb[MAILBOX_REGISTER_COUNT];
 
@@ -6563,7 +6364,7 @@
     return( qla1280_mailbox_command(ha, BIT_6|BIT_3|BIT_2|BIT_1|BIT_0,
&mb[0]) ) ;
 }
 
-STATIC void
+static void
 qla12160_get_target_parameters(scsi_qla_host_t *ha, uint32_t b, uint32_t t,
uint32_t l)
 {
     uint16_t        mb[MAILBOX_REGISTER_COUNT];
@@ -6582,6 +6383,32 @@
 }
 
 
+#if DEBUG_QLA1280
+/*
+ *  Out NULL terminated string to COM port.
+ */
+static void
+qla1280_print(char *s)
+{
+    if (ql_debug_print)
+      printk("%s", s);
+}
+
+/*
+ *  Output long number to COM port.
+ */
+static void
+qla1280_output_number(u32 n, int base)
+{
+    char buf[12];
+    if (base = 10)
+      sprintf(buf, " %i", n);
+    else
+      sprintf(buf, " 0x%x", n);
+    qla1280_print(buf);
+}
+#endif
+
 #ifdef QL_DEBUG_ROUTINES
 
/***************************************************************************
*/
 /*                         Driver Debug Functions.
*/
@@ -6590,15 +6417,15 @@
 /*
  *  Get byte from I/O port
  */
-STATIC uint8_t
-qla1280_getbyte(uint8_t *port)
+static u8
+qla1280_getbyte(u8 *port)
 {
-    uint8_t ret;
+    u8 ret;
 
 #if MEMORY_MAPPED_IO
-    ret = *port;
+    ret = readb(unsigned long)port);
 #else
-    ret = inb((long)port);
+    ret = inb((unsigned long)port);
 #endif
 
     if (ql_debug_print)
@@ -6606,7 +6433,7 @@
         qla1280_print("qla1280_getbyte: address = ");
         qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
-        qla1280_output_number((uint32_t)ret, 16);
+        qla1280_output_number((u32)ret, 16);
         qla1280_print("\n\r");
     }
 
@@ -6616,13 +6443,13 @@
 /*
  *  Get word from I/O port
  */
-STATIC uint16_t
-qla1280_getword(uint16_t *port)
+static u16
+qla1280_getword(u16 *port)
 {
-    uint16_t ret;
+    u16 ret;
 
 #if MEMORY_MAPPED_IO
-    ret = *port;
+    ret = readw(unsigned long)port;
 #else
     ret = inw((unsigned long)port);
 #endif
@@ -6632,7 +6459,7 @@
         qla1280_print("qla1280_getword: address = ");
         qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
-        qla1280_output_number((uint32_t)ret, 16);
+        qla1280_output_number((u32)ret, 16);
         qla1280_print("\n\r");
     }
 
@@ -6642,13 +6469,13 @@
 /*
  *  Get double word from I/O port
  */
-STATIC uint32_t
-qla1280_getdword(uint32_t *port)
+static u32
+qla1280_getdword(u32 *port)
 {
-    uint32_t ret;
+    u32 ret;
 
 #if MEMORY_MAPPED_IO
-    ret = *port;
+    ret = readl((unsigned long)port);
 #else
     ret = inl((unsigned long)port);
 #endif
@@ -6658,7 +6485,7 @@
         qla1280_print("qla1280_getdword: address = ");
         qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
-        qla1280_output_number((uint32_t)ret, 16);
+        qla1280_output_number(ret, 16);
         qla1280_print("\n\r");
     }
 
@@ -6668,11 +6495,11 @@
 /*
  *  Send byte to I/O port
  */
-STATIC void
-qla1280_putbyte(uint8_t *port, uint8_t data)
+static void
+qla1280_putbyte(u8 *port, u8 data)
 {
 #if MEMORY_MAPPED_IO
-    *port = data;
+    writeb(data, (unsigned long)port);
 #else
     outb(data, (unsigned long)port);
 #endif
@@ -6682,7 +6509,7 @@
         qla1280_print("qla1280_putbyte: address = ");
         qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
-        qla1280_output_number((uint32_t)data, 16);
+        qla1280_output_number((u32)data, 16);
         qla1280_print("\n\r");
     }
 }
@@ -6690,17 +6517,13 @@
 /*
  *  Send word to I/O port
  */
-STATIC void
-qla1280_putword(uint16_t *port, uint16_t data)
+static void
+qla1280_putword(u16 *port, u16 data)
 {
 #if MEMORY_MAPPED_IO
-    *port = data;
+    writew(data, (unsigned long)port);
 #else
-#ifdef _LINUX_IOPORTS
-    outw(data, (int)port);
-#else
-    outw((unsigned long)port, data);
-#endif
+    outw(data, (unsigned long)port);
 #endif
 
     if (ql_debug_print)
@@ -6708,7 +6531,7 @@
         qla1280_print("qla1280_putword: address = ");
         qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
-        qla1280_output_number((uint32_t)data, 16);
+        qla1280_output_number((u32)data, 16);
         qla1280_print("\n\r");
     }
 }
@@ -6716,17 +6539,13 @@
 /*
  *  Send double word to I/O port
  */
-STATIC void
-qla1280_putdword(uint32_t *port, uint32_t data)
+static void
+qla1280_putdword(u32 *port, u32 data)
 {
 #if MEMORY_MAPPED_IO
-    *port = data;
+    writel(data, (unsigned long)port);
 #else
-#ifdef _LINUX_IOPORTS
-    outl(data,(int)port);
-#else
-    outl((unsigned long)port, data);
-#endif
+    outl(data, (unsigned long)port);
 #endif
 
     if (ql_debug_print)
@@ -6734,7 +6553,7 @@
         qla1280_print("qla1280_putdword: address = ");
         qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
-        qla1280_output_number((uint32_t)data, 16);
+        qla1280_output_number(data, 16);
         qla1280_print("\n\r");
     }
 }
@@ -6754,158 +6573,11 @@
     qla1280_putdword(0, 0);
 }
 
-/*
- *  Out character to COM2 port.
- *      PORT must be at standard address for COM1 = 0x3f8
- */
-#define OUTB(addr,data)   outb((data),(addr))
-
-STATIC void
-qla1280_putc(uint8_t c)
-{
-#ifdef QL_DEBUG_CONSOLE
-    printk("%c", c);
-#else
-    int     com_addr              = 0x3f8;
-    int     hardware_flow_control = 1;
-    int     software_flow_control = 0;
-    uint8_t data;
-
-    /* Wait for transmitter holding and shift registers for empty. */
-    do
-    {
-        data = inb(com_addr+5);
-    }while (!(data & BIT_6));
-
-    /*
-    * Set BAUD rate for COM2 to 9600 (0x6)
-    */
-
-    /* Select rate divisor. */
-    OUTB(com_addr+3, 0x83); 
-
-    /* BAUD rate divisor LSB. */
-    OUTB(com_addr, 0xc);                    /* 0xC = 9600 baud */
-
-    /* BAUD rate divisor MSB. */
-    OUTB(com_addr+1, 0);
-
-    /* Set No parity, 8 bits, 1 stop bit and
-    select interrupt enable register. */
-    OUTB(com_addr+3, 3);
-
-    /* Disable interrupts. */
-    OUTB(com_addr+1, 0);
-
-    /* Set data terminal ready and request to send */
-    OUTB(com_addr+4,3);
-
-    if (hardware_flow_control)
-    {
-        /* Wait for clear-to-send and data-set-ready */
-        do
-        {
-            data = inb(com_addr+6) & (BIT_5 + BIT_4);
-        }while (data != (BIT_5 + BIT_4));
-    }
-    else if (software_flow_control)
-    {
-        /* Test for data ready. */
-        data = inb(com_addr+5);
-        if (data & BIT_0)
-        {
-            /* If XOFF */
-            data = inb(com_addr);
-            if (data = '\023')
-            {
-                /* Wait for XON */
-                do
-                {
-                    /* Wait for char */
-                    do
-                    {
-                        data = inb(com_addr+5);
-                    }while (!(data & BIT_0));
-                    data = inb(com_addr);
-                }while (data != '\021');
-            }
-        }
-    }
-
-    /* Output character. */
-    OUTB(com_addr, c);
-#endif
-}
-
-/*
- *  Out NULL terminated string to COM port.
- */
-STATIC void
-qla1280_print(caddr_t s)
+static void
+qla1280_dump_buffer(char *b, int size)
 {
-    if (ql_debug_print)
-    {
-#ifdef QL_DEBUG_CONSOLE
-        printk("%s",s);
-#else
-        /* Output string. */
-        while (*s)
-            qla1280_putc(*s++);
-#endif
-    }
-}
-
-/*
- *  Output long number to COM port.
- */
-STATIC void
-qla1280_output_number(uint32_t n, uint8_t base)
-{
-    int8_t str[12];
-    int8_t *s     = &str[11];
-    int8_t output = 0;
-    int8_t hex    = FALSE;
-
-    if (ql_debug_print)
-    {
-        if (base = 10 || base = 16)
-        {
-            if (base = 16 && n > 9)
-                hex = TRUE;
-
-            *s = 0;
-            do
-            {
-                s--;
-                *s = n % base;
-                if (*s > 9)
-                    *s += 55;
-                else
-                    *s += '0';
-                n /= base;
-            }while (n);
-
-            for (; *s; s++)
-            {
-                if (*s != '0')
-                    output = 1;
-                if (output)
-                    qla1280_putc(*s);
-            }
-            if (!output)
-                qla1280_putc(*--s);
-
-            if (hex)
-                qla1280_putc('h');
-        }
-    }
-}
-
-STATIC void
-qla1280_dump_buffer(caddr_t b, uint32_t size)
-{
-    uint32_t cnt;
-    uint8_t c;
+    int cnt;
+    u8 c;
 
     if (ql_debug_print)
     {
@@ -6918,25 +6590,26 @@
         {
             c = *b++;
             if (c < 16)
-                qla1280_putc(' ');
-            qla1280_output_number((uint32_t)c, 16);
+                qla1280_print(' ');
+            qla1280_output_number((u32)c, 16);
             cnt++;
             if (!(cnt % 16))
                 qla1280_print("\n\r");
             else if (c < 10)
                 qla1280_print("  ");
             else
-                qla1280_putc(' ');
+                qla1280_print(' ');
         }
         if (cnt % 16)
             qla1280_print("\n\r");
     }
 }
+
 /**************************************************************************
  *   ql1280_print_scsi_cmd
  *
 
**************************************************************************/
-void qla1280_print_scsi_cmd(Scsi_Cmnd *cmd)
+static void qla1280_print_scsi_cmd(Scsi_Cmnd *cmd)
 {
     scsi_qla_host_t *ha;
     struct Scsi_Host  *host = cmd->host;
@@ -6967,7 +6640,7 @@
     {
        sg = (struct scatterlist *) cmd->request_buffer;
        qla1280_print("  SG buffer: \n\r");
-       qla1280_dump_buffer((caddr_t)sg, (cmd->use_sg*sizeof(struct
scatterlist)) );
+       qla1280_dump_buffer((char *)sg, (cmd->use_sg*sizeof(struct
scatterlist)) );
     } */
     sprintf(debug_buff,"  tag=%d, flags=0x%x, transfersize=0x%x \n\r", 
             cmd->tag, cmd->flags,cmd->transfersize );
--- ../linux-2.4.3-zc-010405-backup/drivers/scsi/qla1280.h	Fri Apr 13
18:36:23 2001
+++ drivers/scsi/qla1280.h	Tue Apr 24 15:18:11 2001
@@ -21,10 +21,6 @@
 #define _IO_HBA_QLA1280_H           /* subject to change without notice */
 
 
-#ifndef LINUX_VERSION_CODE 
-#include <linux/version.h>
-#endif  /* LINUX_VERSION_CODE not defined */
-
 #if defined(__cplusplus)
 extern "C" {
 #endif
@@ -60,58 +56,6 @@
 #endif
 
 
-#ifndef KERNEL_VERSION
-#  define KERNEL_VERSION(x,y,z) (((x)<<16)+((y)<<8)+(z))
-#endif
-
-#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,1,92)
-#  if defined(__sparc_v9__) || defined(__powerpc__)
-#    error "PPC and Sparc platforms are only support under 2.1.92 and
above"
-#  endif
-#endif
-
-
-/* 
- * Locking
- */
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,0)
-#  if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
-#    include <asm/spinlock.h>
-#  else
-#    include <linux/spinlock.h>
-#  endif
-#  include <linux/smp.h>
-#  define cpuid smp_processor_id()
-#  if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-#    define DRIVER_LOCK_INIT \
-       spin_lock_init(&ha->spin_lock);
-#    define DRIVER_LOCK \
-       if(!ha->cpu_lock_count[cpuid]) { \
-         spin_lock_irqsave(&ha->spin_lock, cpu_flags); \
-         ha->cpu_lock_count[cpuid]++; \
-       } else { \
-         ha->cpu_lock_count[cpuid]++; \
-       }
-#    define DRIVER_UNLOCK \
-       if(--ha->cpu_lock_count[cpuid] = 0) \
-         spin_unlock_irqrestore(&ha->spin_lock, cpu_flags);
-#  else
-#    define DRIVER_LOCK_INIT
-#    define DRIVER_LOCK
-#    define DRIVER_UNLOCK
-#  endif 
-#else
-#  define cpuid 0
-#  define DRIVER_LOCK_INIT
-#  define DRIVER_LOCK \
-       save_flags(cpu_flags); \
-       cli();
-#  define DRIVER_UNLOCK \
-       restore_flags(cpu_flags);
-#  define le32_to_cpu(x) (x)
-#  define cpu_to_le32(x) (x)
-#endif
-
 /*
  * Data bit definitions.
  */
@@ -148,17 +92,6 @@
 #define BIT_30  0x40000000
 #define BIT_31  0x80000000
 
-/*
- * Common size type definitions
- */
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,0)
-typedef unsigned char  uint8_t; 
-typedef unsigned short uint16_t; 
-typedef unsigned long  uint32_t; 
-typedef char  int8_t; 
-typedef short int16_t; 
-typedef long  int32_t; 
-#endif
 
 /*
  *  Local Macro Definitions.
@@ -173,40 +106,33 @@
 /*
  * I/O port macros
 */
-#define LINUX_IOPORTS                     /* Linux in/out routines are
define*/
-                                          /* differently from other OSs
*/
 /* #define MEMORY_MAPPED_IO */            /* Enable memory mapped I/O */
 #undef MEMORY_MAPPED_IO            /* Disable memory mapped I/O */
 
 #ifdef QL_DEBUG_LEVEL_1
-#define RD_REG_BYTE(addr)         qla1280_getbyte((uint8_t *)addr)
-#define RD_REG_WORD(addr)         qla1280_getword((uint16_t *)addr)
-#define RD_REG_DWORD(addr)        qla1280_getdword((uint32_t *)addr)
-#define WRT_REG_BYTE(addr, data)  qla1280_putbyte((uint8_t *)addr, data)
-#define WRT_REG_WORD(addr, data)  qla1280_putword((uint16_t *)addr, data)
-#define WRT_REG_DWORD(addr, data) qla1280_putdword((uint32_t *)addr, data)
+#define RD_REG_BYTE(addr)		qla1280_getbyte((u8 *)addr)
+#define RD_REG_WORD(addr)		qla1280_getword((u16 *)addr)
+#define RD_REG_DWORD(addr)		qla1280_getdword((u32 *)addr)
+#define WRT_REG_BYTE(addr, data)	qla1280_putbyte((u8 *)addr, data)
+#define WRT_REG_WORD(addr, data)	qla1280_putword((u16 *)addr, data)
+#define WRT_REG_DWORD(addr, data)	qla1280_putdword((u32 *)addr, data)
 #else  /* QL_DEBUG_LEVEL_1 */
+
 #ifdef MEMORY_MAPPED_IO
-      #define RD_REG_BYTE(addr)         (*((volatile uint8_t *)addr))
-       #define RD_REG_WORD(addr)         (*((volatile uint16_t *)addr))
-       #define RD_REG_DWORD(addr)        (*((volatile uint32_t *)addr))
-       #define WRT_REG_BYTE(addr, data)  (*((volatile uint8_t *)addr) data)
-       #define WRT_REG_WORD(addr, data)  (*((volatile uint16_t *)addr) data)
-       #define WRT_REG_DWORD(addr, data) (*((volatile uint32_t *)addr) data) 
+#define RD_REG_BYTE(addr)		readb(addr)
+#define RD_REG_WORD(addr)		readw(addr)
+#define RD_REG_DWORD(addr)		readl(addr)
+#define WRT_REG_BYTE(addr, data)	writeb(data, addr)
+#define WRT_REG_WORD(addr, data)	writew(data, addr)
+#define WRT_REG_DWORD(addr, data)	writel(data, addr)
 #else   /* MEMORY_MAPPED_IO */
-#define RD_REG_BYTE(addr)         (inb((unsigned long)addr))
-#define RD_REG_WORD(addr)         (inw((unsigned long)addr))
-#define RD_REG_DWORD(addr)        (inl((unsigned long)addr))
-#ifdef LINUX_IOPORTS
+#define RD_REG_BYTE(addr)		inb((unsigned long)addr)
+#define RD_REG_WORD(addr)		inw((unsigned long)addr)
+#define RD_REG_DWORD(addr)		inl((unsigned long)addr)
 /* Parameters are reversed in Linux */
-#define WRT_REG_BYTE(addr, data)  (outb(data,(unsigned long)addr))
-#define WRT_REG_WORD(addr, data)  (outw(data,(unsigned long)addr))
-#define WRT_REG_DWORD(addr, data) (outl(data,(unsigned long)addr))
-#else
-#define WRT_REG_BYTE(addr, data)  (outb((unsigned long)addr, data))
-#define WRT_REG_WORD(addr, data)  (outw((unsigned long)addr, data))
-#define WRT_REG_DWORD(addr, data) (outl((unsigned long)addr, data))
-#endif
+#define WRT_REG_BYTE(addr, data)	outb(data, (unsigned long)addr)
+#define WRT_REG_WORD(addr, data)	outw(data, (unsigned long)addr)
+#define WRT_REG_DWORD(addr, data)	outl(data, (unsigned long)addr)
 #endif  /* MEMORY_MAPPED_IO */
 #endif    /* QL_DEBUG_LEVEL_1 */
 
@@ -228,7 +154,7 @@
 #define QLA1280_WDG_TIME_QUANTUM   5    /* In seconds */
 
 /* Command retry count (0-65535) */
-#define COMMAND_RETRY_COUNT   255
+#define COMMAND_RETRY_COUNT	255
 
 /* Maximum outstanding commands in ISP queues (1-65535) */
 #define MAX_OUTSTANDING_COMMANDS   512
@@ -238,10 +164,10 @@
 #define RESPONSE_ENTRY_CNT      16      /* Number of response entries. */
 
 /* Maximum equipage per controller */
-#define MAX_EQ          (MAX_BUSES * MAX_TARGETS * MAX_LUNS)
+#define MAX_EQ			(MAX_BUSES * MAX_TARGETS * MAX_LUNS)
 
 /* Number of segments 1 - 65535 */
-#define SG_SEGMENTS     32             /* Cmd entry + 6 continuations */
+#define SG_SEGMENTS		32	/* Cmd entry + 6 continuations */
 
 
 typedef struct timer_list   timer_t;         /* timer */
@@ -1392,18 +1318,14 @@
     uint8_t          pci_bus;
     uint8_t          pci_device_fn;
     uint8_t          devnum;
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
     struct pci_dev *pdev;
-#endif
+
     volatile unsigned char  *mmpbase;      /* memory mapped address */
     unsigned long            host_no;
     unsigned long            instance;
     uint8_t           revision;
     uint8_t           ports;
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,0)
-    spinlock_t               spin_lock;
-#endif
-    volatile unsigned char   cpu_lock_count[NR_CPUS];
+
     unsigned long            actthreads;
     unsigned long            qthreads;
     unsigned long            isr_count;        /* Interrupt count */
@@ -1420,11 +1342,6 @@
     /* Device LUN queues. */
     scsi_lu_t       *dev[MAX_EQ];      /* Logical unit queues */
 
-#ifdef UNUSED
-    /* Interrupt lock, and data */
-    uint8_t          intr_lock;         /* Lock for interrupt locking */
-#endif
-
     /* bottom half run queue */
     struct tq_struct run_qla_bh;
 
@@ -1432,41 +1349,24 @@
     volatile uint16_t mailbox_out[MAILBOX_REGISTER_COUNT];
 
 #ifdef UNUSED
-    /* ISP ring lock, rings, and indexes */
-    uint8_t          ring_lock;         /* ISP ring lock */
     struct timer_list        dev_timer[MAX_TARGETS];
 #endif
 
-    request_t       req[REQUEST_ENTRY_CNT+1];
-    response_t      res[RESPONSE_ENTRY_CNT+1];
-#if BITS_PER_LONG > 32
     dma_addr_t      request_dma;        /* Physical Address */
-#else
-    uint32_t        request_dma;        /* Physical address. */
-#endif
     request_t       *request_ring;      /* Base virtual address */
     request_t       *request_ring_ptr;  /* Current address. */
     uint16_t        req_ring_index;     /* Current index. */
     uint16_t        req_q_cnt;          /* Number of available entries. */
 
-#if BITS_PER_LONG > 32
     dma_addr_t      response_dma;       /* Physical address. */
-#else
-    uint32_t        response_dma;       /* Physical address. */
-#endif
     response_t      *response_ring;     /* Base virtual address */
     response_t      *response_ring_ptr; /* Current address. */
     uint16_t        rsp_ring_index;     /* Current index. */
 
 #if QL1280_TARGET_MODE_SUPPORT
     /* Target buffer and sense data. */
-#if BITS_PER_LONG > 32
     dma_addr_t      tbuf_dma;           /* Physical address. */
     dma_addr_t      tsense_dma;         /* Physical address. */
-#else
-    uint32_t        tbuf_dma;           /* Physical address. */
-    uint32_t        tsense_dma;         /* Physical address. */
-#endif
     tgt_t           *tbuf;
     uint8_t         *tsense;
 #endif
@@ -1527,9 +1427,6 @@
  */
 #define QLA1280_HIER   HBA_HIER_BASE  /* Locking hierarchy base for hba */
 
-#define QLA1280_WATCHDOG_Q_LOCK(ha, p)   
-#define QLA1280_WATCHDOG_Q_UNLOCK(ha, p) 
-
 #define QLA1280_SCSILU_LOCK(q)  
 #define QLA1280_SCSILU_UNLOCK(q) 
 
@@ -1597,8 +1494,6 @@
 	use_new_eh_code: 0,					\
 	emulated: 0					        \
 }
-
-
 
 #endif /* _IO_HBA_QLA1280_H */
 

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

