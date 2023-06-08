Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E990C7EE2E
	for <linux-ia64@archiver.kernel.org>; Thu,  8 Jun 2023 19:32:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234594AbjFHTco (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 8 Jun 2023 15:32:44 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47118 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229459AbjFHTcn (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 8 Jun 2023 15:32:43 -0400
Received: from mail-yb1-xb34.google.com (mail-yb1-xb34.google.com [IPv6:2607:f8b0:4864:20::b34])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BFBE61FFA
        for <linux-ia64@vger.kernel.org>; Thu,  8 Jun 2023 12:32:41 -0700 (PDT)
Received: by mail-yb1-xb34.google.com with SMTP id 3f1490d57ef6-bacf5b89da7so1062840276.2
        for <linux-ia64@vger.kernel.org>; Thu, 08 Jun 2023 12:32:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1686252761; x=1688844761;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=5V1nU3Kqzs/xawWKyc6+rxjcg3uMlDunTMtenGe5HoU=;
        b=24t2BtFN5HXeEnWp4wmjqaz3ba7RZTv3BWN8E2lDsHPicXiEJRz9TlH2WLVzGd8CdE
         of2yNqyqdnSUhfcGIlOsfvovWhpuG53taZz/x9DR/Th5PIOmYH7IKtDML+zGnAiDR7yW
         CrmldFZSb2omivw75gysl+pOyy7IV7uE8SzN+doaYOlbMw3OdLZlcS0TMi0ZgvmIeRDQ
         MJq/tuPeT8xPnNmBXjEKmMP3qPQGwnStEjRQklqNa0dtkxFHtF5PvuvrSEAvR9DPSdcW
         McnyT5sGz87Djsd0XbZMK04rqnZG7iDmeQmmJXSZxSQJU2i6hoMEpfITW8x1lOY4n4VU
         tBMA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1686252761; x=1688844761;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=5V1nU3Kqzs/xawWKyc6+rxjcg3uMlDunTMtenGe5HoU=;
        b=Tk+97jwElBz/M1RIeCjHd3mJ66eM5lGC8uI3+apG8JNG2YobEzyw4VmN4D573WZpuF
         EEDiP8re6seEM+29fa5JrNAxP/+vvaXP4VxQDWW7XQiKXATW1JQOi4fy06MIwasL05Ws
         1fSuUJ3q9yigtKz3eCZGMGdOuHLraKPuz0Ak1TH8yeNelO4O7RVjpkzM3kW/FjAvwijC
         oBMH8vnLIMTzOz943oDDUj/0ALbjenZ9ARiRk4SfVGLiJ5XsyKoDTLwcJd785/ofw648
         fhJ+jpaAj7csai5PMhCYauJIxwTe4xV4WZsrpKzOT7c42sGRmqFromPWeaU9nAJ6k2rk
         wXag==
X-Gm-Message-State: AC+VfDwmsne2L782v7K/ZTdd3TednjMADPPtn93b1ouV1WI2+FvOXZka
        zrNcqmoKeWfo6mIHs3H5a+Jvvg==
X-Google-Smtp-Source: ACHHUZ6ZLPO3tFN/Ri9lGF19A4q4QfMsE5CXjcYyyqXlwc0QGFL9qBHigDBgxXippDMgVek84lg5YA==
X-Received: by 2002:a25:f40b:0:b0:ba8:54c4:3136 with SMTP id q11-20020a25f40b000000b00ba854c43136mr602795ybd.52.1686252760634;
        Thu, 08 Jun 2023 12:32:40 -0700 (PDT)
Received: from ripple.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id k7-20020a258c07000000b00bb0ae4221b8sm428913ybl.43.2023.06.08.12.32.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Jun 2023 12:32:40 -0700 (PDT)
Date:   Thu, 8 Jun 2023 12:32:36 -0700 (PDT)
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
Subject: [PATCH v2 19/23] sparc: allow pte_offset_map() to fail
In-Reply-To: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
Message-ID: <22165adb-581c-9ce1-8aa6-a3385cd39055@google.com>
References: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

In rare transient cases, not yet made possible, pte_offset_map() and
pte_offset_map_lock() may not find a page table: handle appropriately.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/sparc/kernel/signal32.c | 2 ++
 arch/sparc/mm/fault_64.c     | 3 +++
 arch/sparc/mm/tlb.c          | 2 ++
 3 files changed, 7 insertions(+)

diff --git a/arch/sparc/kernel/signal32.c b/arch/sparc/kernel/signal32.c
index dad38960d1a8..ca450c7bc53f 100644
--- a/arch/sparc/kernel/signal32.c
+++ b/arch/sparc/kernel/signal32.c
@@ -328,6 +328,8 @@ static void flush_signal_insns(unsigned long address)
 		goto out_irqs_on;
 
 	ptep = pte_offset_map(pmdp, address);
+	if (!ptep)
+		goto out_irqs_on;
 	pte = *ptep;
 	if (!pte_present(pte))
 		goto out_unmap;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index d91305de694c..d8a407fbe350 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -99,6 +99,7 @@ static unsigned int get_user_insn(unsigned long tpc)
 	local_irq_disable();
 
 	pmdp = pmd_offset(pudp, tpc);
+again:
 	if (pmd_none(*pmdp) || unlikely(pmd_bad(*pmdp)))
 		goto out_irq_enable;
 
@@ -115,6 +116,8 @@ static unsigned int get_user_insn(unsigned long tpc)
 #endif
 	{
 		ptep = pte_offset_map(pmdp, tpc);
+		if (!ptep)
+			goto again;
 		pte = *ptep;
 		if (pte_present(pte)) {
 			pa  = (pte_pfn(pte) << PAGE_SHIFT);
diff --git a/arch/sparc/mm/tlb.c b/arch/sparc/mm/tlb.c
index 9a725547578e..7ecf8556947a 100644
--- a/arch/sparc/mm/tlb.c
+++ b/arch/sparc/mm/tlb.c
@@ -149,6 +149,8 @@ static void tlb_batch_pmd_scan(struct mm_struct *mm, unsigned long vaddr,
 	pte_t *pte;
 
 	pte = pte_offset_map(&pmd, vaddr);
+	if (!pte)
+		return;
 	end = vaddr + HPAGE_SIZE;
 	while (vaddr < end) {
 		if (pte_val(*pte) & _PAGE_VALID) {
-- 
2.35.3

