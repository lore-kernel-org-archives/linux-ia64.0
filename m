Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B00EB64D9
	for <linux-ia64@archiver.kernel.org>; Thu,  6 Jul 2023 15:48:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232483AbjGFPrx (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 6 Jul 2023 11:47:53 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45456 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232034AbjGFPrr (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 6 Jul 2023 11:47:47 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1372C1FC7
        for <linux-ia64@vger.kernel.org>; Thu,  6 Jul 2023 08:46:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1688658413;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=HouZTQm+V70h+gsiEupRVBEwB3PeE/r1+sDrBkNv3ls=;
        b=C7Z0tnZq9x75p//MRwulhDta/Iz//5A9RmQN7vZgHrVe5389S2CxBkW5aVo73o5bqodels
        jL2KzJMJypDKB0PxvqjLQGXRzX3kW+VbPkQshE9mvH0YcE0u2O4+ZBW/mRYKauTmwXLb49
        iOKt4IRaQN0i8TiPalxh2lyHVaswOkg=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-199-zStYdrw0PYmzXl3bYNKOLg-1; Thu, 06 Jul 2023 11:46:47 -0400
X-MC-Unique: zStYdrw0PYmzXl3bYNKOLg-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id EFD23185A794;
        Thu,  6 Jul 2023 15:46:46 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-39.pek2.redhat.com [10.72.12.39])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0F6DCF6431;
        Thu,  6 Jul 2023 15:46:37 +0000 (UTC)
From:   Baoquan He <bhe@redhat.com>
To:     linux-kernel@vger.kernel.org
Cc:     akpm@linux-foundation.org, linux-mm@kvack.org, arnd@arndb.de,
        hch@lst.de, christophe.leroy@csgroup.eu, rppt@kernel.org,
        willy@infradead.org, agordeev@linux.ibm.com,
        wangkefeng.wang@huawei.com, schnelle@linux.ibm.com,
        shorne@gmail.com, David.Laight@ACULAB.COM, deller@gmx.de,
        nathan@kernel.org, glaubitz@physik.fu-berlin.de,
        Baoquan He <bhe@redhat.com>, linux-ia64@vger.kernel.org
Subject: [PATCH v8 08/19] ia64: mm: Convert to GENERIC_IOREMAP
Date:   Thu,  6 Jul 2023 23:45:09 +0800
Message-Id: <20230706154520.11257-9-bhe@redhat.com>
In-Reply-To: <20230706154520.11257-1-bhe@redhat.com>
References: <20230706154520.11257-1-bhe@redhat.com>
MIME-Version: 1.0
Content-type: text/plain
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.5
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

By taking GENERIC_IOREMAP method, the generic generic_ioremap_prot(),
generic_iounmap(), and their generic wrapper ioremap_prot(), ioremap()
and iounmap() are all visible and available to arch. Arch needs to
provide wrapper functions to override the generic versions if there's
arch specific handling in its ioremap_prot(), ioremap() or iounmap().
This change will simplify implementation by removing duplicated code
with generic_ioremap_prot() and generic_iounmap(), and has the equivalent
functioality as before.

Here, add wrapper functions ioremap_prot() and iounmap() for ia64's
special operation when ioremap() and iounmap().

Signed-off-by: Baoquan He <bhe@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Mike Rapoport (IBM) <rppt@kernel.org>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig          |  1 +
 arch/ia64/include/asm/io.h | 13 +++++-------
 arch/ia64/mm/ioremap.c     | 41 ++++++--------------------------------
 3 files changed, 12 insertions(+), 43 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 2cd93e6bf0fe..3ab75f36c037 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -47,6 +47,7 @@ config IA64
 	select GENERIC_IRQ_LEGACY
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_IOMAP
+	select GENERIC_IOREMAP
 	select GENERIC_SMP_IDLE_THREAD
 	select ARCH_TASK_STRUCT_ON_STACK
 	select ARCH_TASK_STRUCT_ALLOCATOR
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 83a492c8d298..eedc0afa8cad 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -243,15 +243,12 @@ static inline void outsl(unsigned long port, const void *src,
 
 # ifdef __KERNEL__
 
-extern void __iomem * ioremap(unsigned long offset, unsigned long size);
+#define _PAGE_IOREMAP pgprot_val(PAGE_KERNEL)
+
 extern void __iomem * ioremap_uc(unsigned long offset, unsigned long size);
-extern void iounmap (volatile void __iomem *addr);
-static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned long size)
-{
-	return ioremap(phys_addr, size);
-}
-#define ioremap ioremap
-#define ioremap_cache ioremap_cache
+
+#define ioremap_prot ioremap_prot
+#define ioremap_cache ioremap
 #define ioremap_uc ioremap_uc
 #define iounmap iounmap
 
diff --git a/arch/ia64/mm/ioremap.c b/arch/ia64/mm/ioremap.c
index 92b81bc91397..711b6abc822e 100644
--- a/arch/ia64/mm/ioremap.c
+++ b/arch/ia64/mm/ioremap.c
@@ -29,13 +29,9 @@ early_ioremap (unsigned long phys_addr, unsigned long size)
 	return __ioremap_uc(phys_addr);
 }
 
-void __iomem *
-ioremap (unsigned long phys_addr, unsigned long size)
+void __iomem *ioremap_prot(phys_addr_t phys_addr, size_t size,
+			   unsigned long flags)
 {
-	void __iomem *addr;
-	struct vm_struct *area;
-	unsigned long offset;
-	pgprot_t prot;
 	u64 attr;
 	unsigned long gran_base, gran_size;
 	unsigned long page_base;
@@ -68,36 +64,12 @@ ioremap (unsigned long phys_addr, unsigned long size)
 	 */
 	page_base = phys_addr & PAGE_MASK;
 	size = PAGE_ALIGN(phys_addr + size) - page_base;
-	if (efi_mem_attribute(page_base, size) & EFI_MEMORY_WB) {
-		prot = PAGE_KERNEL;
-
-		/*
-		 * Mappings have to be page-aligned
-		 */
-		offset = phys_addr & ~PAGE_MASK;
-		phys_addr &= PAGE_MASK;
-
-		/*
-		 * Ok, go for it..
-		 */
-		area = get_vm_area(size, VM_IOREMAP);
-		if (!area)
-			return NULL;
-
-		area->phys_addr = phys_addr;
-		addr = (void __iomem *) area->addr;
-		if (ioremap_page_range((unsigned long) addr,
-				(unsigned long) addr + size, phys_addr, prot)) {
-			vunmap((void __force *) addr);
-			return NULL;
-		}
-
-		return (void __iomem *) (offset + (char __iomem *)addr);
-	}
+	if (efi_mem_attribute(page_base, size) & EFI_MEMORY_WB)
+		return generic_ioremap_prot(phys_addr, size, __pgprot(flags));
 
 	return __ioremap_uc(phys_addr);
 }
-EXPORT_SYMBOL(ioremap);
+EXPORT_SYMBOL(ioremap_prot);
 
 void __iomem *
 ioremap_uc(unsigned long phys_addr, unsigned long size)
@@ -114,8 +86,7 @@ early_iounmap (volatile void __iomem *addr, unsigned long size)
 {
 }
 
-void
-iounmap (volatile void __iomem *addr)
+void iounmap(volatile void __iomem *addr)
 {
 	if (REGION_NUMBER(addr) == RGN_GATE)
 		vunmap((void *) ((unsigned long) addr & PAGE_MASK));
-- 
2.34.1

