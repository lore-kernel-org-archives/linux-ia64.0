From: Martin Hicks <mort@wildopensource.com>
Date: Thu, 22 Jan 2004 19:38:42 +0000
Subject: Re: [PATCH] remove old SN1 machvec header file
Message-Id: <20040122193842.GC15871@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="WChQLJJJfbwij+9x"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040122181150.GZ15871@localhost>
In-Reply-To: <20040122181150.GZ15871@localhost>
To: linux-ia64@vger.kernel.org


--WChQLJJJfbwij+9x
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline



On Thu, Jan 22, 2004 at 11:09:36AM -0800, David Mosberger wrote:
> Look ma, no patch! ;-)
> 

Yeah,  I'm a retard.  Here's the patch.

mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--WChQLJJJfbwij+9x
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="remove-sn1-machvec.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1354  -> 1.1355 
#	include/asm-ia64/machvec_sn1.h	1.9     ->         (deleted)      
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/03	mort@green.(none)	1.1355
# Remove old sn1 machvec header file.
# --------------------------------------------
#
diff -Nru a/include/asm-ia64/machvec_sn1.h b/include/asm-ia64/machvec_sn1.h
--- a/include/asm-ia64/machvec_sn1.h	Mon Nov  3 10:16:06 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,85 +0,0 @@
-/*
- * Copyright (c) 2002 Silicon Graphics, Inc.  All Rights Reserved.
- * 
- * This program is free software; you can redistribute it and/or modify it 
- * under the terms of version 2 of the GNU General Public License 
- * as published by the Free Software Foundation.
- * 
- * This program is distributed in the hope that it would be useful, but 
- * WITHOUT ANY WARRANTY; without even the implied warranty of 
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
- * 
- * Further, this software is distributed without any warranty that it is 
- * free of the rightful claim of any third person regarding infringement 
- * or the like.  Any license provided herein, whether implied or 
- * otherwise, applies only to this software file.  Patent licenses, if 
- * any, provided herein do not apply to combinations of this program with 
- * other software, or any other product whatsoever.
- * 
- * You should have received a copy of the GNU General Public 
- * License along with this program; if not, write the Free Software 
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
- * 
- * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
- * Mountain View, CA  94043, or:
- * 
- * http://www.sgi.com 
- * 
- * For further information regarding this notice, see: 
- * 
- * http://oss.sgi.com/projects/GenInfo/NoticeExplan
- */
-
-#ifndef _ASM_IA64_MACHVEC_SN1_h
-#define _ASM_IA64_MACHVEC_SN1_h
-
-extern ia64_mv_setup_t sn1_setup;
-extern ia64_mv_cpu_init_t sn_cpu_init;
-extern ia64_mv_irq_init_t sn1_irq_init;
-extern ia64_mv_send_ipi_t sn1_send_IPI;
-extern ia64_mv_global_tlb_purge_t sn1_global_tlb_purge;
-extern ia64_mv_inb_t sn1_inb;
-extern ia64_mv_inw_t sn1_inw;
-extern ia64_mv_inl_t sn1_inl;
-extern ia64_mv_outb_t sn1_outb;
-extern ia64_mv_outw_t sn1_outw;
-extern ia64_mv_outl_t sn1_outl;
-extern ia64_mv_dma_alloc_coherent	sn1_dma_alloc_coherent;
-extern ia64_mv_dma_free_coherent	sn1_dma_free_coherent;
-extern ia64_mv_dma_map_single		sn1_dma_map_single;
-extern ia64_mv_dma_unmap_single		sn1_dma_unmap_single;
-extern ia64_mv_dma_map_sg		sn1_dma_map_sg;
-extern ia64_mv_dma_unmap_sg		sn1_dma_unmap_sg;
-extern ia64_mv_dma_sync_single		sn1_dma_sync_single;
-extern ia64_mv_dma_sync_sg		sn1_dma_sync_sg;
-
-/*
- * This stuff has dual use!
- *
- * For a generic kernel, the macros are used to initialize the
- * platform's machvec structure.  When compiling a non-generic kernel,
- * the macros are used directly.
- */
-#define platform_name		"sn1"
-#define platform_setup		sn1_setup
-#define platform_cpu_init	sn_cpu_init
-#define platform_irq_init	sn1_irq_init
-#define platform_send_ipi	sn1_send_IPI
-#define platform_global_tlb_purge       sn1_global_tlb_purge
-#define platform_inb		sn1_inb
-#define platform_inw		sn1_inw
-#define platform_inl		sn1_inl
-#define platform_outb		sn1_outb
-#define platform_outw		sn1_outw
-#define platform_outl		sn1_outl
-#define platform_dma_init	machvec_noop
-#define platform_dma_alloc_coherent	sn1_dma_alloc_coherent
-#define platform_dma_free_coherent	sn1_dma_free_coherent
-#define platform_dma_map_single		sn1_dma_map_single
-#define platform_dma_unmap_single	sn1_dma_unmap_single
-#define platform_dma_map_sg		sn1_dma_map_sg
-#define platform_dma_unmap_sg		sn1_dma_unmap_sg
-#define platform_dma_sync_single	sn1_dma_sync_single
-#define platform_dma_sync_sg		sn1_dma_sync_sg
-
-#endif /* _ASM_IA64_MACHVEC_SN1_h */

--WChQLJJJfbwij+9x--
