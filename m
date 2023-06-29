Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE172EB64DD
	for <linux-ia64@archiver.kernel.org>; Thu, 29 Jun 2023 00:28:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231163AbjF2A2N (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Wed, 28 Jun 2023 20:28:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56564 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230449AbjF2A2M (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Wed, 28 Jun 2023 20:28:12 -0400
Received: from mail-qt1-x82a.google.com (mail-qt1-x82a.google.com [IPv6:2607:f8b0:4864:20::82a])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3D413210E
        for <linux-ia64@vger.kernel.org>; Wed, 28 Jun 2023 17:28:11 -0700 (PDT)
Received: by mail-qt1-x82a.google.com with SMTP id d75a77b69052e-40079620a83so163261cf.0
        for <linux-ia64@vger.kernel.org>; Wed, 28 Jun 2023 17:28:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1687998490; x=1690590490;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=a3sxRrExQR7lJV6jvWZ5R7RjbSffn5YHmj9jbb61spI=;
        b=r2Ch6dd3Oy5ATuKjb580eq8/KXAABw0eOUHkyDtSlLZiQoaZjpTJL/7bARwrgsW66k
         d2gMqg+IrkJCoNVDp2q+/9sCHmVd53nm0vMnZ0uitf5p0hbRBrL4EmdKnkJHDiZK5Oc4
         9oauP8LfD9PAmECrNwlGnV/GIPOUxtyckNSg8ttFE6DANxvYAoTyhysJxBmF7iaOW2Dw
         +uODy5JlFkcEFh0BMppTXoOmmYbFyaKVIgNS3q7JjDNRYN1XUwoy2z0fBIfWvecERfpQ
         soehKD9L2ke2xP6yQiqOAYGP5UH3iItDNw0fQTZK7Xg98xvlIYZg/e0AeDMJg7Ulwxb6
         t2KA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1687998490; x=1690590490;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=a3sxRrExQR7lJV6jvWZ5R7RjbSffn5YHmj9jbb61spI=;
        b=asf3EZLubfiGQQFaz9xx5wu8TaXd6C7sLP6FuY1Toe8RMYQK9v+dTOXA/Hz5XSgKyq
         SW8i2PF15U3xdvFoqU6I2DzGE4b1e6N79OlFavzCcxewuD82psL3hGbk1BRFyPpm5w5o
         WiMK99TCL6AnkFMxYjQOqb+s/+7RLS7vHqE13+I5Bd1OGCzfifcQYJJE5y38jfWuf7E6
         PrR6mfIsPYr6frN+6+DRGvv2U+mTnaE1SV8uIG1s7zBQ/LADys9fdFsn4EpH1ICTJNT5
         qVbNio/ESoXPW1K8gyqHqTI22wJCQmhwBLI1spAaUcVCWhtmbildnzqg5Gf4liQQACNG
         Pn7w==
X-Gm-Message-State: AC+VfDxQMzwyRGQJSIQ3F6K9NfgbFiTEjbC1W33KARSflVjuDp0lyUFJ
        NdxuzGvlDhZADtvNCOOvVIKk/mFZ7klzbxnOCZ5pWQ==
X-Google-Smtp-Source: ACHHUZ5cgzeZsCkQVE5oXJ8aWyDwEbuY/Fyio8PQe622ucd9axAZhja7G4hziS8H14gRW3UCdBVkuxQvLWsO//xg7PA=
X-Received: by 2002:ac8:7f4e:0:b0:3f8:1f30:a1f2 with SMTP id
 g14-20020ac87f4e000000b003f81f30a1f2mr447680qtk.26.1687998490244; Wed, 28 Jun
 2023 17:28:10 -0700 (PDT)
MIME-Version: 1.0
References: <20230626171430.3167004-1-ryan.roberts@arm.com>
 <CAOUHufaUTbUw9MTzw8D=sVrEB+RP6LSBQVGn93TWk=ozV8XobA@mail.gmail.com>
 <CAOUHufa0S_ayrys0XzDbH8KJi5HxvbGCh_bSAhDpAgcmSJjFUQ@mail.gmail.com>
 <1fb0c4cb-a709-de20-d643-32ed43550059@arm.com> <CAOUHufbtNPkdktjt_5qM45GegVO-rCFOMkSh0HQminQ12zsV8Q@mail.gmail.com>
 <dcbbea37-7fbf-3a7c-6cfb-04dae715e967@intel.com>
In-Reply-To: <dcbbea37-7fbf-3a7c-6cfb-04dae715e967@intel.com>
From:   Yu Zhao <yuzhao@google.com>
Date:   Wed, 28 Jun 2023 18:27:34 -0600
Message-ID: <CAOUHufbC76OdP16mRsY3i920qB7khcu8FM+nUOG0kx5BMRdKXw@mail.gmail.com>
Subject: Re: [PATCH v1 00/10] variable-order, large folios for anonymous memory
To:     Yin Fengwei <fengwei.yin@intel.com>
Cc:     Ryan Roberts <ryan.roberts@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
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

On Wed, Jun 28, 2023 at 5:59=E2=80=AFPM Yin Fengwei <fengwei.yin@intel.com>=
 wrote:
>
> Hi Yu,
>
> On 6/29/23 02:22, Yu Zhao wrote:
> > And please make sure it's disabled by default, because we are still
> > missing many important functions, e.g., I don't think we can mlock()
> > when large() && !pmd_mappable(), see mlock_pte_range() and
> > mlock_vma_folio(). We can fix it along with many things later, but we
> > need to present a plan and a schedule now. Otherwise, there would be
> > pushback if we try to land the series without supporting mlock().
> >
> > Do you or Fengwei plan to take on it? (I personally don't.) If not,
> Do you mean the mlock() with large folio? Yes. I can work on it. Thanks.

Great. Thanks!

Other places that have the similar problem but are probably easier to
fix than the mlock() case:
* madvise_cold_or_pageout_pte_range()
* shrink_folio_list()
