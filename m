Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA7CEC87FDD
	for <linux-ia64@archiver.kernel.org>; Thu,  8 Jun 2023 19:37:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235568AbjFHTh5 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 8 Jun 2023 15:37:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50272 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236900AbjFHTh4 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 8 Jun 2023 15:37:56 -0400
Received: from mail-yw1-x112e.google.com (mail-yw1-x112e.google.com [IPv6:2607:f8b0:4864:20::112e])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3FCDA2733
        for <linux-ia64@vger.kernel.org>; Thu,  8 Jun 2023 12:37:54 -0700 (PDT)
Received: by mail-yw1-x112e.google.com with SMTP id 00721157ae682-565ba2c7554so8813537b3.3
        for <linux-ia64@vger.kernel.org>; Thu, 08 Jun 2023 12:37:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1686253073; x=1688845073;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=4B5saBu/vw3gaGnlmIPZ9pQkqfzbj7+JgYM5jpygjcc=;
        b=wrjU6S4EMiU3Ufcg2KZPT551Y8sNhg4QKjD2hAgSPlGh9yj39Rxf3Ke0FjcZO6VxtG
         ALh4CVjSqM9GtJPRdIfEgNIlV/EEkptkG6e4IMSsrcpQSqGrj44uojyylNmPW3FhQBzm
         h+3YVxQpJctPazelaypN7o1DBk1YFmyjCLOyVuE0ZSJNDZN1IWkDf39Bng35IMFfYc2S
         OuTO6+N3JH4bhYslynL29X9VjGEwK1A0ffza+fgs91l3oerVxPUep2x461PcKgDhp6i7
         yNPgK4idQjhQRO3vK4IICQL9mYykeSLt5G3Lqvr2ymPPunZsH8KwR6J1BbGlfhLHc47C
         HKFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1686253073; x=1688845073;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=4B5saBu/vw3gaGnlmIPZ9pQkqfzbj7+JgYM5jpygjcc=;
        b=hNS8ewZs2riUFSAYzaNLjkCNaaqEkfGwT2ExKGkFrcpJ51t4O75ChuuRTIuKoNx+Hs
         /FunU3qNkRWdq2SoWiOC9j/ZgRnR6N/Gou96+lyAm3dsMpTupKseHsxuNdtB5SySSs3E
         WJJ+RpCwQkn4I78UHTsSSFsMOGVILLUSlooII1+P+5fhqlK/K0my9C05e2OSFtAB4h0T
         77Vpi1KK7/t0G1qgEGevIeRvulkViMiDRiESOzC5LWG2KeRI/EX0K7PrjGja2zGBbdUg
         L2PY9OmLfvOhM5akB6P1fbroar+A9CSZNB5MXvsxlJPJygW7fAxxJLfdYm3e5YmxUj2e
         G5HQ==
X-Gm-Message-State: AC+VfDxe178JyrxYOck8uA93Yt94wYqv1QNhGesod4RMuxzSEPkDV1RQ
        Of+t7xEo2NRn6H6IDfCFxqrLQQ==
X-Google-Smtp-Source: ACHHUZ7Ebli0p9041CLEfO4CyQQvBmxN41VJwJsuM0MQnf822wu8ZsrJRZ2ru1aILLAWUog5xqYpmw==
X-Received: by 2002:a81:72d4:0:b0:560:f6ae:a71b with SMTP id n203-20020a8172d4000000b00560f6aea71bmr508956ywc.48.1686253073290;
        Thu, 08 Jun 2023 12:37:53 -0700 (PDT)
Received: from ripple.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id i133-20020a816d8b000000b0056953ab06c5sm114950ywc.95.2023.06.08.12.37.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Jun 2023 12:37:52 -0700 (PDT)
Date:   Thu, 8 Jun 2023 12:37:48 -0700 (PDT)
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
Subject: [PATCH v2 23/23] xtensa: add pte_unmap() to balance
 pte_offset_map()
In-Reply-To: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
Message-ID: <ab2581eb-daa6-894e-4aa6-97c81de3b8c@google.com>
References: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

To keep balance in future, remember to pte_unmap() after a successful
pte_offset_map().  And act as if get_pte_for_vaddr() really needs a map
there, to read the pteval before "unmapping", to be sure page table is
not removed.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/xtensa/mm/tlb.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/xtensa/mm/tlb.c b/arch/xtensa/mm/tlb.c
index 27a477dae232..0a11fc5f185b 100644
--- a/arch/xtensa/mm/tlb.c
+++ b/arch/xtensa/mm/tlb.c
@@ -179,6 +179,7 @@ static unsigned get_pte_for_vaddr(unsigned vaddr)
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	unsigned int pteval;
 
 	if (!mm)
 		mm = task->active_mm;
@@ -197,7 +198,9 @@ static unsigned get_pte_for_vaddr(unsigned vaddr)
 	pte = pte_offset_map(pmd, vaddr);
 	if (!pte)
 		return 0;
-	return pte_val(*pte);
+	pteval = pte_val(*pte);
+	pte_unmap(pte);
+	return pteval;
 }
 
 enum {
-- 
2.35.3

