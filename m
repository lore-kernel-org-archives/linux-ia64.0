Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EA24C7EE29
	for <linux-ia64@archiver.kernel.org>; Thu,  8 Jun 2023 19:19:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235504AbjFHTTS (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 8 Jun 2023 15:19:18 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36392 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231857AbjFHTTR (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 8 Jun 2023 15:19:17 -0400
Received: from mail-yb1-xb34.google.com (mail-yb1-xb34.google.com [IPv6:2607:f8b0:4864:20::b34])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 538FB3584
        for <linux-ia64@vger.kernel.org>; Thu,  8 Jun 2023 12:18:43 -0700 (PDT)
Received: by mail-yb1-xb34.google.com with SMTP id 3f1490d57ef6-bacfa9fa329so1078203276.0
        for <linux-ia64@vger.kernel.org>; Thu, 08 Jun 2023 12:18:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1686251920; x=1688843920;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=WLKDOkdQ4oq0ww1Vlfy/KRTEhctwBXtXyzZrgpalkvM=;
        b=HEwZycAEZshzMQG1RY6xWzkEzRNEN/UEaemUkYXNmWskdkmVKrA8S+97io6IqWp9/V
         /Ki/r1s4TSfiiefdOd1an7zeCiAQCXani7OPWb0Yu0dH1JXoMBV7ddckrsj8wmhXsvpX
         lxVVQwwTUjyQXS/CCeF4VIDT1g2/zM6/NDtUcqQOoZLozwlnlFrDor/PrqoADqkak2qo
         deaYgmKHf6xqfmf4KVoYNd/vj1wQpn8eoXEC4WQqeZC4WPbGo41LYWdy4IN4tXqheqG/
         6B0lxLrh+XpboJCYpvDK5+1gNhnxK8xFzRPNdKypeMnMcoGI/ayoAWXa0T/S7aKkyUXg
         eIPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1686251920; x=1688843920;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=WLKDOkdQ4oq0ww1Vlfy/KRTEhctwBXtXyzZrgpalkvM=;
        b=gfeqtcmpM0H1CIBoogt6+XlmoVNuDH19kb3IewCls197/fNWptw76KgEyY9/Xam4qp
         ku8qUL3iWoUMdYHYYYrS/OegxZuCnvipErhmJ1p184JBeTPNKPQMx5FJodQpS2LFDtOU
         k2BN7RoMxnVcjQBGdJ6RdPyb3m+5QKF+6YbeLYt9YkMYUd4T8ifD+3yXwf7yTTc7HlYy
         VN5+xMTt4VQVHmC00Z/yYr0hGiWdR29Mc1v5HDMmyDTJCJSA1JRidfiFk1DnrXrYcXmc
         oPyinAmtOPIIU099VeatubmH6BVbw/JKgjJt8Rs+5xgoDv5THsQZyqnPzjPwIZCm1Pb4
         busw==
X-Gm-Message-State: AC+VfDyoj8FmejAThkEeSrI6uYHThyPiZT+BW0T+nJruIbRPNlMj3N/V
        frT84RD4JtvIX8FJcaGWCdgLdQ==
X-Google-Smtp-Source: ACHHUZ78uQ3KAa2UlmiLkPkJ1ItAoVICWyvDzVcoJt54uwUIKvQ1XvbxMYD2Oe7/oQdSR2X0isfU0g==
X-Received: by 2002:a25:e307:0:b0:ba8:7f98:4afa with SMTP id z7-20020a25e307000000b00ba87f984afamr579046ybd.26.1686251920409;
        Thu, 08 Jun 2023 12:18:40 -0700 (PDT)
Received: from ripple.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id 22-20020a250316000000b00bb2f5dda19bsm432908ybd.47.2023.06.08.12.18.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Jun 2023 12:18:39 -0700 (PDT)
Date:   Thu, 8 Jun 2023 12:18:35 -0700 (PDT)
From:   Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@ripple.attlocal.net
To:     Andrew Morton <akpm@linux-foundation.org>
cc:     Mike Kravetz <mike.kravetz@oracle.com>,
        Mike Rapoport <rppt@kernel.org>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Matthew Wilcox <willy@infradead.org>,
        David Hildenbrand <david@redhat.com>,
        Suren Baghdasaryan <surenb@google.com>,
        Qi Zheng <zhengqi.arch@bytedance.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will@kernel.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Ungerer <gerg@linux-m68k.org>,
        Michal Simek <monstr@monstr.eu>,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        Helge Deller <deller@gmx.de>,
        John David Anglin <dave.anglin@bell.net>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Alexandre Ghiti <alexghiti@rivosinc.com>,
        Palmer Dabbelt <palmer@dabbelt.com>,
        Heiko Carstens <hca@linux.ibm.com>,
        Christian Borntraeger <borntraeger@linux.ibm.com>,
        Claudio Imbrenda <imbrenda@linux.ibm.com>,
        Alexander Gordeev <agordeev@linux.ibm.com>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>,
        "David S. Miller" <davem@davemloft.net>,
        Chris Zankel <chris@zankel.net>,
        Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
        linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
        linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH v2 08/23] parisc: add pte_unmap() to balance get_ptep()
In-Reply-To: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
Message-ID: <653369-95ef-acd2-d6ea-e95f5a997493@google.com>
References: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

To keep balance in future, remember to pte_unmap() after a successful
get_ptep().  And act as if flush_cache_pages() really needs a map there,
to read the pfn before "unmapping", to be sure page table is not removed.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/parisc/kernel/cache.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
index ca4a302d4365..501160250bb7 100644
--- a/arch/parisc/kernel/cache.c
+++ b/arch/parisc/kernel/cache.c
@@ -426,10 +426,15 @@ void flush_dcache_page(struct page *page)
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		addr = mpnt->vm_start + offset;
 		if (parisc_requires_coherency()) {
+			bool needs_flush = false;
 			pte_t *ptep;
 
 			ptep = get_ptep(mpnt->vm_mm, addr);
-			if (ptep && pte_needs_flush(*ptep))
+			if (ptep) {
+				needs_flush = pte_needs_flush(*ptep);
+				pte_unmap(ptep);
+			}
+			if (needs_flush)
 				flush_user_cache_page(mpnt, addr);
 		} else {
 			/*
@@ -561,14 +566,20 @@ EXPORT_SYMBOL(flush_kernel_dcache_page_addr);
 static void flush_cache_page_if_present(struct vm_area_struct *vma,
 	unsigned long vmaddr, unsigned long pfn)
 {
-	pte_t *ptep = get_ptep(vma->vm_mm, vmaddr);
+	bool needs_flush = false;
+	pte_t *ptep;
 
 	/*
 	 * The pte check is racy and sometimes the flush will trigger
 	 * a non-access TLB miss. Hopefully, the page has already been
 	 * flushed.
 	 */
-	if (ptep && pte_needs_flush(*ptep))
+	ptep = get_ptep(vma->vm_mm, vmaddr);
+	if (ptep) {
+		needs_flush = pte_needs_flush(*ptep);
+		pte_unmap(ptep);
+	}
+	if (needs_flush)
 		flush_cache_page(vma, vmaddr, pfn);
 }
 
@@ -635,17 +646,22 @@ static void flush_cache_pages(struct vm_area_struct *vma, unsigned long start, u
 	pte_t *ptep;
 
 	for (addr = start; addr < end; addr += PAGE_SIZE) {
+		bool needs_flush = false;
 		/*
 		 * The vma can contain pages that aren't present. Although
 		 * the pte search is expensive, we need the pte to find the
 		 * page pfn and to check whether the page should be flushed.
 		 */
 		ptep = get_ptep(vma->vm_mm, addr);
-		if (ptep && pte_needs_flush(*ptep)) {
+		if (ptep) {
+			needs_flush = pte_needs_flush(*ptep);
+			pfn = pte_pfn(*ptep);
+			pte_unmap(ptep);
+		}
+		if (needs_flush) {
 			if (parisc_requires_coherency()) {
 				flush_user_cache_page(vma, addr);
 			} else {
-				pfn = pte_pfn(*ptep);
 				if (WARN_ON(!pfn_valid(pfn)))
 					return;
 				__flush_cache_page(vma, addr, PFN_PHYS(pfn));
-- 
2.35.3

