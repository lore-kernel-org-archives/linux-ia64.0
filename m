Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64913EB64DD
	for <linux-ia64@archiver.kernel.org>; Tue, 27 Jun 2023 07:50:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231523AbjF0HuD (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 27 Jun 2023 03:50:03 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42754 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231577AbjF0Ht4 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 27 Jun 2023 03:49:56 -0400
Received: from mail-qt1-x82f.google.com (mail-qt1-x82f.google.com [IPv6:2607:f8b0:4864:20::82f])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A69B910DA
        for <linux-ia64@vger.kernel.org>; Tue, 27 Jun 2023 00:49:54 -0700 (PDT)
Received: by mail-qt1-x82f.google.com with SMTP id d75a77b69052e-401f4408955so141961cf.1
        for <linux-ia64@vger.kernel.org>; Tue, 27 Jun 2023 00:49:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1687852194; x=1690444194;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=eo3fjt+pdVHwFcUAUU2kV7EYv7OpDGZ269voWMltBrg=;
        b=lPaiuSe+QrHU/UAvIGj5ZYbZ3Cp+GUm9cg80JCZveFMlflbA5+j7acPoyJ5ZXu1Lut
         FvOPlQDymVBgnVuR4hmh5Rco8ghw0Rg53DPB/gJFQYhTQnfSG8GRcqsJdpzvenYBbgxO
         Bi+5qxIiGDf+RzqveF5bTQ7NC1lRm0Od9CVoE1bC8quQqKSsm1IfBZndE2JX0j2xNKaz
         Bofk6w6z/7YGNhu0EDK+9BZHKwWBWxbdHqZDaCr+FWfJ6huk/DCN3qp5dmlaQNZlxUoB
         mH+TY6w+jgwSZUPvcKkJsuIZP2Qo4uVMrri0wcbSXHK3rmedhiI2mEkWxD2pnIzjHwJm
         OQrg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1687852194; x=1690444194;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=eo3fjt+pdVHwFcUAUU2kV7EYv7OpDGZ269voWMltBrg=;
        b=DWWJd7SSpoikupQTOLsKu6tkFi64kFLXr0rc4eI70JtsUeKmDC/1e0ft6hSGbhJ+Ud
         wop5MwmRd0qPW5TIV4UvNGBJqmxhjiMr3OSbmW0xuBLJ6cYAdilM3PK0RAKtuCM4rnta
         nAfAo/eJCCRNYshXdDorEEkK6OejuyjEIiXrmD30aVnUxn3sRlqHfhG7axGxBBcTqUhe
         7gBH8cIdGHqZYV75ruVW2gk0v3nJIDlZ4fIOVyDwcr5/QW5/6qko9HeQHY9kVZq7XWbH
         9J8q8Vrz8wmoukdndpac2U38ei/1tEFSoYcZpm+tJb+8BHBJRbVunCpHtR1OJF8oIpDY
         0uTQ==
X-Gm-Message-State: AC+VfDwDBZygnnkatXnRNmT8ZmsX9JzSFKOBPbyKotwm7VkAobOAIO/I
        4ann7/iEj9Uy7rJgUl1uyTRVMlLzsaD5DHM9cP0xKg==
X-Google-Smtp-Source: ACHHUZ5rzyvlEwiwm8ZlPLzXXXFoW47j8ogId6VZIKwnpEI8aX6A+N2v3sluywDVKjd03Lly1yKQPmxRIaEW9WvVzeQ=
X-Received: by 2002:a05:622a:24a:b0:3f6:97b4:1a4d with SMTP id
 c10-20020a05622a024a00b003f697b41a4dmr430821qtx.23.1687852193576; Tue, 27 Jun
 2023 00:49:53 -0700 (PDT)
MIME-Version: 1.0
References: <20230626171430.3167004-1-ryan.roberts@arm.com> <CAOUHufaUTbUw9MTzw8D=sVrEB+RP6LSBQVGn93TWk=ozV8XobA@mail.gmail.com>
In-Reply-To: <CAOUHufaUTbUw9MTzw8D=sVrEB+RP6LSBQVGn93TWk=ozV8XobA@mail.gmail.com>
From:   Yu Zhao <yuzhao@google.com>
Date:   Tue, 27 Jun 2023 01:49:17 -0600
Message-ID: <CAOUHufa0S_ayrys0XzDbH8KJi5HxvbGCh_bSAhDpAgcmSJjFUQ@mail.gmail.com>
Subject: Re: [PATCH v1 00/10] variable-order, large folios for anonymous memory
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

On Mon, Jun 26, 2023 at 9:30=E2=80=AFPM Yu Zhao <yuzhao@google.com> wrote:
>
> On Mon, Jun 26, 2023 at 11:14=E2=80=AFAM Ryan Roberts <ryan.roberts@arm.c=
om> wrote:
> >
> > Hi All,
> >
> > Following on from the previous RFCv2 [1], this series implements variab=
le order,
> > large folios for anonymous memory. The objective of this is to improve
> > performance by allocating larger chunks of memory during anonymous page=
 faults:
> >
> >  - Since SW (the kernel) is dealing with larger chunks of memory than b=
ase
> >    pages, there are efficiency savings to be had; fewer page faults, ba=
tched PTE
> >    and RMAP manipulation, fewer items on lists, etc. In short, we reduc=
e kernel
> >    overhead. This should benefit all architectures.
> >  - Since we are now mapping physically contiguous chunks of memory, we =
can take
> >    advantage of HW TLB compression techniques. A reduction in TLB press=
ure
> >    speeds up kernel and user space. arm64 systems have 2 mechanisms to =
coalesce
> >    TLB entries; "the contiguous bit" (architectural) and HPA (uarch).
> >
> > This patch set deals with the SW side of things only and based on feedb=
ack from
> > the RFC, aims to be the most minimal initial change, upon which future
> > incremental changes can be added. For this reason, the new behaviour is=
 hidden
> > behind a new Kconfig switch, CONFIG_LARGE_ANON_FOLIO, which is disabled=
 by
> > default. Although the code has been refactored to parameterize the desi=
red order
> > of the allocation, when the feature is disabled (by forcing the order t=
o be
> > always 0) my performance tests measure no regression. So I'm hoping thi=
s will be
> > a suitable mechanism to allow incremental submissions to the kernel wit=
hout
> > affecting the rest of the world.
> >
> > The patches are based on top of v6.4 plus Matthew Wilcox's set_ptes() s=
eries
> > [2], which is a hard dependency. I'm not sure of Matthew's exact plans =
for
> > getting that series into the kernel, but I'm hoping we can start the re=
view
> > process on this patch set independently. I have a branch at [3].
> >
> > I've posted a separate series concerning the HW part (contpte mapping) =
for arm64
> > at [4].
> >
> >
> > Performance
> > -----------
> >
> > Below results show 2 benchmarks; kernel compilation and speedometer 2.0=
 (a
> > javascript benchmark running in Chromium). Both cases are running on Am=
pere
> > Altra with 1 NUMA node enabled, Ubuntu 22.04 and XFS filesystem. Each b=
enchmark
> > is repeated 15 times over 5 reboots and averaged.
> >
> > All improvements are relative to baseline-4k. 'anonfolio-basic' is this=
 series.
> > 'anonfolio' is the full patch set similar to the RFC with the additiona=
l changes
> > to the extra 3 fault paths. The rest of the configs are described at [4=
].
> >
> > Kernel Compilation (smaller is better):
> >
> > | kernel          |   real-time |   kern-time |   user-time |
> > |:----------------|------------:|------------:|------------:|
> > | baseline-4k     |        0.0% |        0.0% |        0.0% |
> > | anonfolio-basic |       -5.3% |      -42.9% |       -0.6% |
> > | anonfolio       |       -5.4% |      -46.0% |       -0.3% |
> > | contpte         |       -6.8% |      -45.7% |       -2.1% |
> > | exefolio        |       -8.4% |      -46.4% |       -3.7% |
> > | baseline-16k    |       -8.7% |      -49.2% |       -3.7% |
> > | baseline-64k    |      -10.5% |      -66.0% |       -3.5% |
> >
> > Speedometer 2.0 (bigger is better):
> >
> > | kernel          |   runs_per_min |
> > |:----------------|---------------:|
> > | baseline-4k     |           0.0% |
> > | anonfolio-basic |           0.7% |
> > | anonfolio       |           1.2% |
> > | contpte         |           3.1% |
> > | exefolio        |           4.2% |
> > | baseline-16k    |           5.3% |
>
> Thanks for pushing this forward!
>
> > Changes since RFCv2
> > -------------------
> >
> >   - Simplified series to bare minimum (on David Hildenbrand's advice)
>
> My impression is that this series still includes many pieces that can
> be split out and discussed separately with followup series.
>
> (I skipped 04/10 and will look at it tomorrow.)

I went through the series twice. Here what I think a bare minimum
series (easier to review/debug/land) would look like:
1. a new arch specific function providing a prefered order within (0,
PMD_ORDER).
2. an extended anon folio alloc API taking that order (02/10, partially).
3. an updated folio_add_new_anon_rmap() covering the large() &&
!pmd_mappable() case (similar to 04/10).
4. s/folio_test_pmd_mappable/folio_test_large/ in page_remove_rmap()
(06/10, reviewed-by provided).
5. finally, use the extended anon folio alloc API with the arch
preferred order in do_anonymous_page() (10/10, partially).

The rest can be split out into separate series and move forward in
parallel with probably a long list of things we need/want to do.
