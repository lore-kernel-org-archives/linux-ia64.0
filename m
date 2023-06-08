Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C76BC83003
	for <linux-ia64@archiver.kernel.org>; Thu,  8 Jun 2023 19:12:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236051AbjFHTMN (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 8 Jun 2023 15:12:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58892 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231908AbjFHTML (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 8 Jun 2023 15:12:11 -0400
Received: from mail-yw1-x1132.google.com (mail-yw1-x1132.google.com [IPv6:2607:f8b0:4864:20::1132])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 339D62D7B
        for <linux-ia64@vger.kernel.org>; Thu,  8 Jun 2023 12:12:05 -0700 (PDT)
Received: by mail-yw1-x1132.google.com with SMTP id 00721157ae682-568928af8f5so14441867b3.1
        for <linux-ia64@vger.kernel.org>; Thu, 08 Jun 2023 12:12:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1686251524; x=1688843524;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=zVLRceEeXaiGvlgxdYbIgAo+AcDyW1dS+jDGBb+h1UA=;
        b=1l3g323zHExDgYGww0zFXmVgic3jDwyc0JAOaU14MB4NUoruSezWtFEVocvA8VR+wP
         D+bOPBhVpeN5TR7Q94HiD/7UXFwgvkn75HwqVtdM3hi/WhalPJUwiHRXSp3bpeKIuRdm
         orIqBvL0rae06pUEOxuRX8a0MpgqpKjI5TTzLJ98WQmBBEIDz4RhToD7qotfuISdygmL
         gKqyyQ61v8JQcZhpfriPzCyTWiXBbfQnLuFCKxtspZkjhV60I7fgSoyr0iHs2+KGMqLW
         csaRWwWg7YMEgY5GV8POPk7y+6y3olAQXOM6liWFfJYYRJ0sFo+4jM2u98tnCjYnFP0Y
         93kg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1686251524; x=1688843524;
        h=mime-version:references:message-id:in-reply-to:subject:cc:to:from
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=zVLRceEeXaiGvlgxdYbIgAo+AcDyW1dS+jDGBb+h1UA=;
        b=ZYtwoz+xqjIqxIV26J1aIy/WkPgob8xDPbeEIhuTZoQgNemdjVnTaOVj8Zj6kAdISJ
         h+3LrZzLb4Bd1tKt8BA5MVRQYReTcje1TFd5TwMeWou5+PzgHG82NIKn7iasGtF9JV9d
         olDNFu/ojsCrPwXIfP1ADOHouHAWvvI24V5anmCabqnZry2m4lZ/jTKlyWNvLukFoH55
         9ufTZZS+u9UAYNYukHetvzG+caJsCOQKJJMRcuHHZrhy929BjXHJ/fLWXc/D26vPy+ce
         prudtbX+v2n1QXn17tMW2VGONashrJvQvs2HazIw21Ar/5zsgoo9fvGXQw2kXqVQvTIs
         pdhA==
X-Gm-Message-State: AC+VfDwm9/yB9RnE8XzA4Xi0AAvK8X43T6Pm1QnQe05/69CeY43Atfg8
        ROkh60b3X7nMqMtujgkmNS/3Bw==
X-Google-Smtp-Source: ACHHUZ6kOJKeygbedx9f6pcNR03LNZvYC4ZecjCRxiqOz1IuKMf5mVIHIRdEhOcWlcOzm+o3M8bu5Q==
X-Received: by 2002:a0d:ead2:0:b0:569:ec03:14eb with SMTP id t201-20020a0dead2000000b00569ec0314ebmr668029ywe.23.1686251523870;
        Thu, 08 Jun 2023 12:12:03 -0700 (PDT)
Received: from ripple.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id d144-20020a814f96000000b00559f1cb8444sm106718ywb.70.2023.06.08.12.12.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Jun 2023 12:12:03 -0700 (PDT)
Date:   Thu, 8 Jun 2023 12:11:59 -0700 (PDT)
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
Subject: [PATCH v2 02/23] arm64: allow pte_offset_map() to fail
In-Reply-To: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
Message-ID: <35e46485-8499-4337-c51f-b8fa495a1a93@google.com>
References: <a4963be9-7aa6-350-66d0-2ba843e1af44@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

In rare transient cases, not yet made possible, pte_offset_map() and
pte_offset_map_lock() may not find a page table: handle appropriately.

Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/mm/fault.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index cb21ccd7940d..f3aaba853547 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -177,6 +177,9 @@ static void show_pte(unsigned long addr)
 			break;
 
 		ptep = pte_offset_map(pmdp, addr);
+		if (!ptep)
+			break;
+
 		pte = READ_ONCE(*ptep);
 		pr_cont(", pte=%016llx", pte_val(pte));
 		pte_unmap(ptep);
-- 
2.35.3

