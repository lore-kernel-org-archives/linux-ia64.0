Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0B0EC83003
	for <linux-ia64@archiver.kernel.org>; Thu,  8 Jun 2023 19:36:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236824AbjFHTgf (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 8 Jun 2023 15:36:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49374 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236511AbjFHTgd (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 8 Jun 2023 15:36:33 -0400
Received: from mail-yw1-x1136.google.com (mail-yw1-x1136.google.com [IPv6:2607:f8b0:4864:20::1136])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 88CD52113
        for <linux-ia64@vger.kernel.org>; Thu,  8 Jun 2023 12:36:31 -0700 (PDT)
Received: by mail-yw1-x1136.google.com with SMTP id 00721157ae682-568900c331aso9430437b3.3
        for <linux-ia64@vger.kernel.org>; Thu, 08 Jun 2023 12:36:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1686252991; x=1688844991;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=UmemeLuI+WpEQXgz9TQT0mwehV8FTU9BDTa5EhoH+Rw=;
        b=7iZl7qFoE643/vqqfaylOOM4UugSzxQOXfGxIkvhFgrLBJMpREbmLbhzK1Dfpeq7sW
         vLxMNbMxtYruESXi/vLA/FRPFy86oy/Rlv/K+QRhWyPjxrgHE6clF71I8HICL+Wbu4D8
         52TIPF5OsTmaSTlVcpOmlJ2hXgN4iVitvobit3uBB1+XryThJwAiK1B3ovBLWTXnWBEi
         ML7bTpBpfErXrO5jZn41yk5x35HzdiBPWQx9RrfkGfIWSKYY13HndzOzcbi8dz53N7Pe
         Ykc3xEYKN/aDtb36dEI3aYN9owd5brP5GXTjP0NKjFTbVVbOSNnZMLMGudJLdaSlcXEi
         8u1g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1686252991; x=1688844991;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=UmemeLuI+WpEQXgz9TQT0mwehV8FTU9BDTa5EhoH+Rw=;
        b=ifWyIHQikViCkIwL8PHvzOdBdmeyjgAp4oE4zLCb2gCvJvoJgmIMhgTCVWR71DkJ1J
         9/8aiZWd5jNP7vfarrEb07j+MUPHbOOvsHgjfGpiXjopZaLEC3kEoyc+rMjuTinW0TU3
         xDGn7xGX+HQIM2FMqvBMtVmh5QmvjJYhdq2DzBtJNVmw3vP9mzNo1gqfHqvkPYd/fV3b
         1B0Dj2ItLVb2xlbIq+L+rNBw1rehz9coBB5uymUaKy3rZ4/kVlT3yIhL3tRhYzTh8F54
         cuHcp1soK1CjYe9EKSP5BJqGutp4sHG3BrHax2Ij8+oDl6Ljagivxgc49NCXEN81xV3s
         sWgw==
X-Gm-Message-State: AC+VfDwVO33kwKjhTUmYtaxe+H7JDsK/eizO0TVSeKEPwZDZwSDzCJYw
        mSTQCNc3+bZCokpksI63eHuVdA==
X-Google-Smtp-Source: ACHHUZ5QdxKuy9jo3MUvUBLJWa7hkCRN4WqLqFRikF/N35P5/sjJc9i1Jxr6DqBjKGQqjHCt1+UtTA==
X-Received: by 2002:a0d:ef01:0:b0:568:d586:77bb with SMTP id y1-20020a0def01000000b00568d58677bbmr743298ywe.14.1686252990588;
        Thu, 08 Jun 2023 12:36:30 -0700 (PDT)
Received: from ripple.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id a11-20020a81bb4b000000b00545dc7c4a9esm108298ywl.111.2023.06.08.12.36.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Jun 2023 12:36:30 -0700 (PDT)
Date:   Thu, 8 Jun 2023 12:36:26 -0700 (PDT)
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
Subject: [PATCH v2 22/23] x86: sme_populate_pgd() use pte_offset_kernel()
In-Reply-To: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
Message-ID: <497d7777-736e-85f2-c37-aa6bcf155e4@google.com>
References: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

sme_populate_pgd() is an __init function for sme_encrypt_kernel():
it should use pte_offset_kernel() instead of pte_offset_map(), to avoid
the question of whether a pte_unmap() will be needed to balance.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/x86/mm/mem_encrypt_identity.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/mem_encrypt_identity.c b/arch/x86/mm/mem_encrypt_identity.c
index c6efcf559d88..a1ab542bdfd6 100644
--- a/arch/x86/mm/mem_encrypt_identity.c
+++ b/arch/x86/mm/mem_encrypt_identity.c
@@ -188,7 +188,7 @@ static void __init sme_populate_pgd(struct sme_populate_pgd_data *ppd)
 	if (pmd_large(*pmd))
 		return;
 
-	pte = pte_offset_map(pmd, ppd->vaddr);
+	pte = pte_offset_kernel(pmd, ppd->vaddr);
 	if (pte_none(*pte))
 		set_pte(pte, __pte(ppd->paddr | ppd->pte_flags));
 }
-- 
2.35.3

