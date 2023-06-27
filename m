Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39A76EB64DC
	for <linux-ia64@archiver.kernel.org>; Tue, 27 Jun 2023 18:34:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230341AbjF0SeV (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 27 Jun 2023 14:34:21 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58014 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229593AbjF0SeT (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 27 Jun 2023 14:34:19 -0400
Received: from mail-qt1-x836.google.com (mail-qt1-x836.google.com [IPv6:2607:f8b0:4864:20::836])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0765235A6
        for <linux-ia64@vger.kernel.org>; Tue, 27 Jun 2023 11:33:48 -0700 (PDT)
Received: by mail-qt1-x836.google.com with SMTP id d75a77b69052e-40079620a83so44931cf.0
        for <linux-ia64@vger.kernel.org>; Tue, 27 Jun 2023 11:33:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1687890825; x=1690482825;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=PTIY9reQDxCVjeBIGzBvbwdTkf7d3X2+E+ffOvvfOt8=;
        b=IFZFZBAdSS5WPvdUVXRmtMP6d4it0zMJf/l2GDxZXOXh1ctIJNlPkvj2sinpxjJpBe
         LSKJg/UTJqQVTKhWODYjkO1i4nmcSjjuGZmBYcplmBZiyiFW6CuoXRu+bQTCz2WCa1nH
         SdQntuzU7sGVa9Zb4/4LWl80uj4Q0BPHxEdxix7lK5L3lwfGKXDqrn1GAAYX6QuI7vNE
         z1pBKRtW9A03Pn/i46V3X9p17H8SAeO0G3yXELGKIy5uxYSjsIK7Iv6IFYtp9hQ3EnpD
         eG251UrPtZeVpaEySuJiM3LXqN8D4gZAZ/2Sukeubj3yBMBzkQ54sCd/tzIGiPBSNQ4H
         dJIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1687890825; x=1690482825;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=PTIY9reQDxCVjeBIGzBvbwdTkf7d3X2+E+ffOvvfOt8=;
        b=ZCbLxaB1KFfvn2vnD7I60ZuCvyPHPNHCKidFpLQQQCQ220OGoC2Vx6RoxS9S/+l7mf
         F5vOlj8Oxz3KxtrXIdBP7qXtylfjNFFPsd/IVSiEfdQ9jnhb+KSk2EBLBfo3e8NVvHFD
         YfXyZETrRba/yBaHtAN98o+dRgNNh6tCYUFZXpDto5GbYd+CZQhYdP+sR70qoXVys3xj
         qOPHVSQ5YceRMcwoJSdnglFIEBCCcFqMaKLdlrDuwDDNrXbWTMroTXUw7+YKdD+9uLGz
         sYs8ndyUMzOWqBDuzShRovVLAMbrXO3zZ9UDzaTDrnp8yQBpU8xeKJdkQseR5E0+85kR
         0exw==
X-Gm-Message-State: AC+VfDzbym44MTgvsCwcI/h2hUMLUtSq7d8OTht/M0jg1zppqg4JfgkN
        dgo+KH1+CDhKlGDnUEttykM/oUmZnlASHLtnNwXEaw==
X-Google-Smtp-Source: ACHHUZ6J+FwNO1q3sZEb2eJpxaQ1yK9y93HAAT9rQ/w4kcix4s3yyUXUt2xkbkSmZhsyVHdXENGOFgl+h8r/6XgSKPU=
X-Received: by 2002:a05:622a:2d2:b0:3fd:ad1b:4e8a with SMTP id
 a18-20020a05622a02d200b003fdad1b4e8amr15807qtx.22.1687890825017; Tue, 27 Jun
 2023 11:33:45 -0700 (PDT)
MIME-Version: 1.0
References: <20230626171430.3167004-1-ryan.roberts@arm.com>
 <20230626171430.3167004-11-ryan.roberts@arm.com> <CAOUHufarua_JmnTu5NM-W3K4Togw+24F=Pf0HU0ZOjuwbRMC0A@mail.gmail.com>
 <0c98f854-b4e4-9a71-8e0c-1556bc79468c@arm.com>
In-Reply-To: <0c98f854-b4e4-9a71-8e0c-1556bc79468c@arm.com>
From:   Yu Zhao <yuzhao@google.com>
Date:   Tue, 27 Jun 2023 12:33:09 -0600
Message-ID: <CAOUHufa21rX1ODOZ0iJxiy4pstgGqhkbfYozg8-+sRp5ZxAOjA@mail.gmail.com>
Subject: Re: [PATCH v1 10/10] mm: Allocate large folios for anonymous memory
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

On Tue, Jun 27, 2023 at 3:57=E2=80=AFAM Ryan Roberts <ryan.roberts@arm.com>=
 wrote:
>
> On 27/06/2023 04:01, Yu Zhao wrote:
> > On Mon, Jun 26, 2023 at 11:15=E2=80=AFAM Ryan Roberts <ryan.roberts@arm=
.com> wrote:
> >>
> >> With all of the enabler patches in place, modify the anonymous memory
> >> write allocation path so that it opportunistically attempts to allocat=
e
> >> a large folio up to `max_anon_folio_order()` size (This value is
> >> ultimately configured by the architecture). This reduces the number of
> >> page faults, reduces the size of (e.g. LRU) lists, and generally
> >> improves performance by batching what were per-page operations into
> >> per-(large)-folio operations.
> >>
> >> If CONFIG_LARGE_ANON_FOLIO is not enabled (the default) then
> >> `max_anon_folio_order()` always returns 0, meaning we get the existing
> >> allocation behaviour.
> >>
> >> Signed-off-by: Ryan Roberts <ryan.roberts@arm.com>
> >> ---
> >>  mm/memory.c | 159 +++++++++++++++++++++++++++++++++++++++++++++++----=
-
> >>  1 file changed, 144 insertions(+), 15 deletions(-)
> >>
> >> diff --git a/mm/memory.c b/mm/memory.c
> >> index a8f7e2b28d7a..d23c44cc5092 100644
> >> --- a/mm/memory.c
> >> +++ b/mm/memory.c
> >> @@ -3161,6 +3161,90 @@ static inline int max_anon_folio_order(struct v=
m_area_struct *vma)
> >>                 return CONFIG_LARGE_ANON_FOLIO_NOTHP_ORDER_MAX;
> >>  }
> >>
> >> +/*
> >> + * Returns index of first pte that is not none, or nr if all are none=
.
> >> + */
> >> +static inline int check_ptes_none(pte_t *pte, int nr)
> >> +{
> >> +       int i;
> >> +
> >> +       for (i =3D 0; i < nr; i++) {
> >> +               if (!pte_none(ptep_get(pte++)))
> >> +                       return i;
> >> +       }
> >> +
> >> +       return nr;
> >> +}
> >> +
> >> +static int calc_anon_folio_order_alloc(struct vm_fault *vmf, int orde=
r)
> >
> > As suggested previously in 03/10, we can leave this for later.
>
> I disagree. This is the logic that prevents us from accidentally replacin=
g
> already set PTEs, or wandering out of the VMA bounds etc. How would you c=
atch
> all those corener cases without this?

Again, sorry for not being clear previously: we definitely need to
handle alignments & overlapps. But the fallback, i.e., "for (; order >
1; order--) {" in calc_anon_folio_order_alloc() is not necessary.

For now, we just need something like

  bool is_order_suitable() {
    // check whether it fits properly
  }

Later on, we could add

  alloc_anon_folio_best_effort()
  {
    for a list of fallback orders
      is_order_suitable()
  }
