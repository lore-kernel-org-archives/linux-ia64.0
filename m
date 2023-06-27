Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAC6DEB64D9
	for <linux-ia64@archiver.kernel.org>; Tue, 27 Jun 2023 02:53:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230121AbjF0Cxs (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Mon, 26 Jun 2023 22:53:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56652 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230055AbjF0Cxs (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Mon, 26 Jun 2023 22:53:48 -0400
Received: from mail-qt1-x830.google.com (mail-qt1-x830.google.com [IPv6:2607:f8b0:4864:20::830])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 278B219A4
        for <linux-ia64@vger.kernel.org>; Mon, 26 Jun 2023 19:53:46 -0700 (PDT)
Received: by mail-qt1-x830.google.com with SMTP id d75a77b69052e-401f4408955so89821cf.1
        for <linux-ia64@vger.kernel.org>; Mon, 26 Jun 2023 19:53:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1687834425; x=1690426425;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=jXL2A5XwGkQBMKHvJmT9XBgr9QrqO5b2xYT/yObtZVs=;
        b=xBIB9H6D26duO7D5p9m4SYXnyo8r6ka9obuVuhUc1nSeyBJJHDhGhS//0CYhrq0cEo
         C3ZegRAqeuF/nHp1Hz01nsb8c9MfJMrAHGvaaVYgKY+EepRGYl1OeaJM6w1KW+G0F5aY
         Ja7Ufnd8fXGxS7FeHYaRjSPLXtMSgzv5A2UfRDFV+8V3+yG9iAYrGactEFGmsUrKFpMO
         lx6ka2RYtqwA6/JcD2tJ0Voq7K6g6sgAIIREvF1zoR/jNw4UZJnFjM6K6j2Ysp9yjdfl
         md6pDBt8J1TZcYvdzAlWxXHjudvUk4mbHTfK96zyrtLCi00HysOXC1SH5YQBPjkeB6Rt
         +7Og==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1687834425; x=1690426425;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=jXL2A5XwGkQBMKHvJmT9XBgr9QrqO5b2xYT/yObtZVs=;
        b=jZmbYwDkVY9qwRmby2v+ky7uln+x8oJWK/nP7PJXTnxT4iABEZWYYpfI4icyAnB5e3
         ZF92pj1jE7vSHlFyCUdkBrPPnovtdv48X3bYz8WbANWYxooMyf4b5pIgsPQNM8v9rpdq
         XioBUKucV+cnf614tFVwDTVAUMhpt1CBAsTcb+c1IOy1kNvQMl/C7/OuRzd/T2JpsGkt
         fA9Fy/HtP/vUI6SM/jW/vo3vt1TXToRLtrd+J7hTdXIV3ChseIaWs+ipwMBEWVFbDJA/
         qYdEDCOMcri6xyfUyVfkt4DZLdb5s5Uli/GaUY/WEnHx+y2qsi6OWWAPBnvLJsJUBzEM
         97Xw==
X-Gm-Message-State: AC+VfDyzuCruOsLGgeASS0c4HvHjZw25+I6NmeGwPkCG8DeZzXpHQJco
        B9s78XR/sSp+bC13og8F8e3KWZB+vyr8gDgdCEZ1Ug==
X-Google-Smtp-Source: ACHHUZ6zI76K2CG0sVaEiLZmWTUL3AMky+bfMr9SxVJfeyKmojoMzl9FYlquTsH7N5mo4L8oNK3cBNdwJ5mTx/oVrN8=
X-Received: by 2002:ac8:5a4d:0:b0:3ed:86f6:6eab with SMTP id
 o13-20020ac85a4d000000b003ed86f66eabmr658445qta.14.1687834425082; Mon, 26 Jun
 2023 19:53:45 -0700 (PDT)
MIME-Version: 1.0
References: <20230626171430.3167004-1-ryan.roberts@arm.com> <20230626171430.3167004-10-ryan.roberts@arm.com>
In-Reply-To: <20230626171430.3167004-10-ryan.roberts@arm.com>
From:   Yu Zhao <yuzhao@google.com>
Date:   Mon, 26 Jun 2023 20:53:09 -0600
Message-ID: <CAOUHufaUT3UzGj-ohPN72CHtgXQHpKFrvJgcPfkJ6HAO=ywKQQ@mail.gmail.com>
Subject: Re: [PATCH v1 09/10] arm64: mm: Declare support for large anonymous folios
To:     Ryan Roberts <ryan.roberts@arm.com>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Yin Fengwei <fengwei.yin@intel.com>,
        David Hildenbrand <david@redhat.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will@kernel.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Christian Borntraeger <borntraeger@linux.ibm.com>,
        Sven Schnelle <svens@linux.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-alpha@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
        linux-m68k@lists.linux-m68k.org, linux-s390@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On Mon, Jun 26, 2023 at 11:15=E2=80=AFAM Ryan Roberts <ryan.roberts@arm.com=
> wrote:
>
> For the unhinted case, when THP is not permitted for the vma, don't
> allow anything bigger than 64K. This means we don't waste too much
> memory. Additionally, for 4K pages this is the contpte size, and for
> 16K, this is (usually) the HPA size when the uarch feature is
> implemented. For the hinted case, when THP is permitted for the vma,
> allow the contpte size for all page size configurations; 64K for 4K, 2M
> for 16K and 2M for 64K.
>
> Signed-off-by: Ryan Roberts <ryan.roberts@arm.com>
> ---
>  arch/arm64/Kconfig | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 343e1e1cae10..0e91b5bc8cd9 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -243,6 +243,7 @@ config ARM64
>         select TRACE_IRQFLAGS_SUPPORT
>         select TRACE_IRQFLAGS_NMI_SUPPORT
>         select HAVE_SOFTIRQ_ON_OWN_STACK
> +       select ARCH_SUPPORTS_LARGE_ANON_FOLIO
>         help
>           ARM 64-bit (AArch64) Linux support.
>
> @@ -281,6 +282,18 @@ config ARM64_CONT_PMD_SHIFT
>         default 5 if ARM64_16K_PAGES
>         default 4
>
> +config ARCH_LARGE_ANON_FOLIO_NOTHP_ORDER_MAX
> +       int
> +       default 0 if ARM64_64K_PAGES    # 64K (1 page)
> +       default 2 if ARM64_16K_PAGES    # 64K (4 pages; benefits from HPA=
 where HW supports it)
> +       default 4 if ARM64_4K_PAGES     # 64K (16 pages; eligible for con=
tpte-mapping)
> +
> +config ARCH_LARGE_ANON_FOLIO_THP_ORDER_MAX
> +       int
> +       default 5 if ARM64_64K_PAGES    # 2M  (32 page; eligible for cont=
pte-mapping)
> +       default 7 if ARM64_16K_PAGES    # 2M  (128 pages; eligible for co=
ntpte-mapping)
> +       default 4 if ARM64_4K_PAGES     # 64K (16 pages; eligible for con=
tpte-mapping)
> +
>  config ARCH_MMAP_RND_BITS_MIN
>         default 14 if ARM64_64K_PAGES
>         default 16 if ARM64_16K_PAGES

Can we please just add one Kconfig for the large anon folio feature,
i.e., ARCH_WANTS_PTE_ORDER, for now?

Feel free to add as many as you wish for arm specific features like
HPA and contpte.
