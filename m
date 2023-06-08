Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2B7AC7EE23
	for <linux-ia64@archiver.kernel.org>; Thu,  8 Jun 2023 19:23:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236136AbjFHTXL (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 8 Jun 2023 15:23:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40090 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234383AbjFHTXK (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 8 Jun 2023 15:23:10 -0400
Received: from mail-yb1-xb31.google.com (mail-yb1-xb31.google.com [IPv6:2607:f8b0:4864:20::b31])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3A0D430FD
        for <linux-ia64@vger.kernel.org>; Thu,  8 Jun 2023 12:22:46 -0700 (PDT)
Received: by mail-yb1-xb31.google.com with SMTP id 3f1490d57ef6-b9a6eec8611so3072591276.0
        for <linux-ia64@vger.kernel.org>; Thu, 08 Jun 2023 12:22:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1686252164; x=1688844164;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=VvuiwGfmHxTbGTIrjZEu2Atjrxfj5l7d/xiFwRLchQg=;
        b=5jRACtmOYl24iPoTbIjNRpyUFAC/FI9lpuvtUNHnC43m7VYioQ/BjHL7bdRB1Sderj
         Ku/HQKtR0qPfeCfubIqZ/AIBxONFw9MhEvcLPL8cbaxLn3mTiR/nWL6P2PCLjm+BwcQW
         0EgQz3QqN/pDsKtdmzyltGWnacSj5IwEptrUle8FLf/akecGFE+OR3UMPvCEsj1BvLU9
         B+ORl75p95EI9Mde8VL9yv1b1t+G7YgfanAmLLFyt7bpvhgPlWiVhcJ7Ue5u8gtJ1wSb
         o7+vcjNZQIk2HsdRh5Pl//khJzNempIfA/Kf3RkDsGtD4+XKnKjXxiMtp0DlEfTwETu/
         3u+w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1686252164; x=1688844164;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=VvuiwGfmHxTbGTIrjZEu2Atjrxfj5l7d/xiFwRLchQg=;
        b=eJ2FMXV5i/AsKQ/6dg0JbUg2cFlHExfJl0VvSFe49pcyD5QvJsJ3XnNrCXNCShVEP2
         qcdmTysimyYvzy603s7TwlUX8SNYdC/tFfWJF31kTtLuyuAWN8tHPaTJoagCa3H3jr2M
         ixPsB1KHwsDYZGgnYfK2hZeP2aggAnjy4ruaVyp74brcfsgmtAtAfwSsPY4Dv1ENEuhX
         Nyp3yPdfJU2xJbYjHil4NZammcl+J2jQkkUJz3Ck6P8Qaa/8ms/4EHYoadU6WC8t0Tai
         xfDinbSSd26bA9TOewuVnLhpNQ2AMftYvgG1gwH5W/yQ4VyWbx0mwWQgyKTKgeuPvfsp
         NFpg==
X-Gm-Message-State: AC+VfDzhJOSajc1Yi/+LFcOWmfxJqmcOWb9YAOdrW2dX6kRJ2irBRU+v
        mViW4K6jqCc6JdQsV5VJVbc1/g==
X-Google-Smtp-Source: ACHHUZ40hyaOIkdH7B5oJObv6N1cySgcI9o6+PKHZNW5ZVazdwvrvX10Wz2CSgkv/8emrW9KOXZU2A==
X-Received: by 2002:a81:a08c:0:b0:569:ef9b:eda with SMTP id x134-20020a81a08c000000b00569ef9b0edamr823988ywg.10.1686252163900;
        Thu, 08 Jun 2023 12:22:43 -0700 (PDT)
Received: from ripple.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id n126-20020a817284000000b00561949f713fsm118018ywc.39.2023.06.08.12.22.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Jun 2023 12:22:43 -0700 (PDT)
Date:   Thu, 8 Jun 2023 12:22:39 -0700 (PDT)
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
Subject: [PATCH v2 11/23] powerpc: kvmppc_unmap_free_pmd()
 pte_offset_kernel()
In-Reply-To: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
Message-ID: <c76aa421-aec3-4cc8-cc61-4130f2e27e1@google.com>
References: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

kvmppc_unmap_free_pmd() use pte_offset_kernel(), like everywhere else
in book3s_64_mmu_radix.c: instead of pte_offset_map(), which will come
to need a pte_unmap() to balance it.

But note that this is a more complex case than most: see those -EAGAINs
in kvmppc_create_pte(), which is coping with kvmppc races beween page
table and huge entry, of the kind which we are expecting to address
in pte_offset_map() - this might want to be revisited in future.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/powerpc/kvm/book3s_64_mmu_radix.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index 461307b89c3a..572707858d65 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -509,7 +509,7 @@ static void kvmppc_unmap_free_pmd(struct kvm *kvm, pmd_t *pmd, bool full,
 		} else {
 			pte_t *pte;
 
-			pte = pte_offset_map(p, 0);
+			pte = pte_offset_kernel(p, 0);
 			kvmppc_unmap_free_pte(kvm, pte, full, lpid);
 			pmd_clear(p);
 		}
-- 
2.35.3

