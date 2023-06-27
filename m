Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D27DCEB64DC
	for <linux-ia64@archiver.kernel.org>; Tue, 27 Jun 2023 02:34:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230156AbjF0Ce5 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Mon, 26 Jun 2023 22:34:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53534 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229988AbjF0Ce5 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Mon, 26 Jun 2023 22:34:57 -0400
Received: from mail-qt1-x830.google.com (mail-qt1-x830.google.com [IPv6:2607:f8b0:4864:20::830])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8C42C19A1
        for <linux-ia64@vger.kernel.org>; Mon, 26 Jun 2023 19:34:55 -0700 (PDT)
Received: by mail-qt1-x830.google.com with SMTP id d75a77b69052e-40079620a83so132501cf.0
        for <linux-ia64@vger.kernel.org>; Mon, 26 Jun 2023 19:34:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1687833294; x=1690425294;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=xQTOkBN0GiMAgDG6ZOmDj9RulFsjN3i64Kvjq5jchlk=;
        b=2ONe3v1NzdXE0h5fj2MWjBVQiq6S1GdLr8eEH6r69uFRebt1NiaIjiqToWQ5+oQSIg
         deN/EOrGfQJTX8/IdlI46HYmmnUjOnsrxEv13aUKomZIkHWSGMAKvqYevb/K3QWcLbR9
         uYFa99/05449KMzf049eKDYSuN8GMHKbyRc3dA/tpDmhB1dFdyQovn3/8ZOwws6k7JBz
         eiSy+SaSo4Ndcni6q+aCfD0OlX9EaJRWRRtbkqrZf+yUHqoDEIGNFR2AH3ma4yaceXsd
         OztHi2s5KfV5Yj8S0MHsmjPInWKZAWUFhMFQytcdDY0Yz3p6nPMmWy44dUIHb/wSpgHH
         azgw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1687833294; x=1690425294;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=xQTOkBN0GiMAgDG6ZOmDj9RulFsjN3i64Kvjq5jchlk=;
        b=V7S1Hf9SeYuLHeRxF7Y/OXzM/VgZ/NE1zfjgT3wZk+xfDcBoSHqSJ+k+vFyyY16PRg
         h9X8WMAi5NNODSJXMuKSJ4Tmsu2UGBWoc78iz5+yR6U0g0AX30kvUyxS/RjSx2UvDd0/
         pcep5vdWVUIkWvhjBrn9YCzAdvvGKJRcd3Eycl0pMeEEAcVpAnaYdmu2XDNfc9oBb9h6
         YC/02m50CkiN6zqn+7jN0+PbJlrSXI3MFcC2K9RFe87HQcOwPnJmLRgdN1SgSKn81MNY
         KisIDUooAQ55LH8+LDKkVk0LKpCEUKk3FJ+blO+8L2yjxelFHmKq5/4Rcc3s7REpnjof
         duYA==
X-Gm-Message-State: AC+VfDyYuMZNsPhxO40CQuAjrHRUPVnlXuf8pq6t7ndYReMr5KOgHXde
        Z7eVg/qKK55wxw8N90pxFAtr7/3kzW0Im9LevkDmcw==
X-Google-Smtp-Source: ACHHUZ5HoW4XPHfg6XbF+Oslzos42MHdia8Ruth5exgz8mKxPN8m+nytOZ3PCELPRviuNzXWfKSV+3UQR1cRdLtaqqk=
X-Received: by 2002:a05:622a:5c8:b0:3ef:3361:75d5 with SMTP id
 d8-20020a05622a05c800b003ef336175d5mr535403qtb.11.1687833294539; Mon, 26 Jun
 2023 19:34:54 -0700 (PDT)
MIME-Version: 1.0
References: <20230626171430.3167004-1-ryan.roberts@arm.com> <20230626171430.3167004-4-ryan.roberts@arm.com>
In-Reply-To: <20230626171430.3167004-4-ryan.roberts@arm.com>
From:   Yu Zhao <yuzhao@google.com>
Date:   Mon, 26 Jun 2023 20:34:18 -0600
Message-ID: <CAOUHufZKM+aS_hYQ5nDUHh74UQwWipJ27Na5Sw4n+RDqnwyWHA@mail.gmail.com>
Subject: Re: [PATCH v1 03/10] mm: Introduce try_vma_alloc_movable_folio()
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

On Mon, Jun 26, 2023 at 11:14=E2=80=AFAM Ryan Roberts <ryan.roberts@arm.com=
> wrote:
>
> Opportunistically attempt to allocate high-order folios in highmem,
> optionally zeroed. Retry with lower orders all the way to order-0, until
> success. Although, of note, order-1 allocations are skipped since a
> large folio must be at least order-2 to work with the THP machinery. The
> user must check what they got with folio_order().
>
> This will be used to oportunistically allocate large folios for
> anonymous memory with a sensible fallback under memory pressure.
>
> For attempts to allocate non-0 orders, we set __GFP_NORETRY to prevent
> high latency due to reclaim, instead preferring to just try for a lower
> order. The same approach is used by the readahead code when allocating
> large folios.
>
> Signed-off-by: Ryan Roberts <ryan.roberts@arm.com>
> ---
>  mm/memory.c | 33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 367bbbb29d91..53896d46e686 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3001,6 +3001,39 @@ static vm_fault_t fault_dirty_shared_page(struct v=
m_fault *vmf)
>         return 0;
>  }
>
> +static inline struct folio *vma_alloc_movable_folio(struct vm_area_struc=
t *vma,
> +                               unsigned long vaddr, int order, bool zero=
ed)
> +{
> +       gfp_t gfp =3D order > 0 ? __GFP_NORETRY | __GFP_NOWARN : 0;
> +
> +       if (zeroed)
> +               return vma_alloc_zeroed_movable_folio(vma, vaddr, gfp, or=
der);
> +       else
> +               return vma_alloc_folio(GFP_HIGHUSER_MOVABLE | gfp, order,=
 vma,
> +                                                               vaddr, fa=
lse);
> +}
> +
> +/*
> + * Opportunistically attempt to allocate high-order folios, retrying wit=
h lower
> + * orders all the way to order-0, until success. order-1 allocations are=
 skipped
> + * since a folio must be at least order-2 to work with the THP machinery=
. The
> + * user must check what they got with folio_order(). vaddr can be any vi=
rtual
> + * address that will be mapped by the allocated folio.
> + */
> +static struct folio *try_vma_alloc_movable_folio(struct vm_area_struct *=
vma,
> +                               unsigned long vaddr, int order, bool zero=
ed)
> +{
> +       struct folio *folio;
> +
> +       for (; order > 1; order--) {
> +               folio =3D vma_alloc_movable_folio(vma, vaddr, order, zero=
ed);
> +               if (folio)
> +                       return folio;
> +       }
> +
> +       return vma_alloc_movable_folio(vma, vaddr, 0, zeroed);
> +}

I'd drop this patch. Instead, in do_anonymous_page():

  if (IS_ENABLED(CONFIG_ARCH_WANTS_PTE_ORDER))
    folio =3D vma_alloc_zeroed_movable_folio(vma, addr,
CONFIG_ARCH_WANTS_PTE_ORDER))

  if (!folio)
    folio =3D vma_alloc_zeroed_movable_folio(vma, addr, 0);
