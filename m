Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54856EB64DD
	for <linux-ia64@archiver.kernel.org>; Tue, 27 Jun 2023 03:36:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230377AbjF0Dgy (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Mon, 26 Jun 2023 23:36:54 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45622 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230064AbjF0DgR (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Mon, 26 Jun 2023 23:36:17 -0400
Received: from mail-qt1-x831.google.com (mail-qt1-x831.google.com [IPv6:2607:f8b0:4864:20::831])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id EC67A4C12
        for <linux-ia64@vger.kernel.org>; Mon, 26 Jun 2023 20:30:57 -0700 (PDT)
Received: by mail-qt1-x831.google.com with SMTP id d75a77b69052e-401d1d967beso142171cf.0
        for <linux-ia64@vger.kernel.org>; Mon, 26 Jun 2023 20:30:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20221208; t=1687836655; x=1690428655;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Dps86R1lndJwF4gJQy/c3O9t7fuW8Q1JEcrGXaT4yyM=;
        b=DPpXKg59gxCfYZfd9BY428kZ8iu0DYsney6Rdb3rBdwDtXCqI6by6+cpd+iFCxaq79
         l5qUs+UtG6qNw6vClJxqZ156uilkFr4nqOfpOjwb4sCDK3cewEwBmVMA0EIXWOjk8R9i
         TVfgsTBk1kHsR06KuWByKOPsHwpa4kfikZiOJBSb1rUERnaQZ2h4T5rsCZtkeArohaZX
         Mkw8ML+8yLd2TpK+iFeG6sjz2DCcKu+mgd+76Du4ZXe9n58Em657zW5MzIJDxXMzqKBe
         fEm9np6GD+3Cx5VBNcJHXVbW+BthLgsTGUPU+3D1UFEeHCXje/m+ogWz3nybucVagpcD
         4StQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1687836655; x=1690428655;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Dps86R1lndJwF4gJQy/c3O9t7fuW8Q1JEcrGXaT4yyM=;
        b=diqa6Nm5yhxYVWbSKVnkHZm1aaHKc3Yr75l32YJ1dLO6+vbBfbdPZ56AXfBI7qKBDs
         I6jPrC59dIjcseuYwEUXdgJUuEvzipmCoZOiezHcpoz1o2Ce7OT1nT/mw0R7WI0eCx+3
         +EXXWKfgezGaoGSJhgkgeUBkjaBExbYU3uClP+U54ONrGXIVSGFBu0W8Dd11pe4w52nZ
         W3voFSA2cBVfuj8S8t+aFRhjMrrrhbE4XgYoZHh6hM60NtCkr3EpUGu9GcRx4LmZov9M
         3oH82Gpa+RwpOGp6IQag+ngYPhnm6A5vo6BaoC9Eg7hxkZoWw9TK4zXDr+AYqVT94SdF
         aztw==
X-Gm-Message-State: AC+VfDxoBuf7LBXtD0jYxSy79ppCKbkwZhs9hPWJsb5nFkFqJmjxosyW
        F1awQQid7fxqEaiwMFPNS+uiwOZ4+MOjSsO8yvDV0w==
X-Google-Smtp-Source: ACHHUZ4qGh8xmLwSTj4hOczEKK2tKapgoJ7DPtSPYajCf/D7+00nPQt51ielpDPZJ55CqXUcttPpnW7qGjNXY0ewa5Y=
X-Received: by 2002:ac8:5953:0:b0:3f5:49b6:f18d with SMTP id
 19-20020ac85953000000b003f549b6f18dmr57784qtz.11.1687836655385; Mon, 26 Jun
 2023 20:30:55 -0700 (PDT)
MIME-Version: 1.0
References: <20230626171430.3167004-1-ryan.roberts@arm.com>
In-Reply-To: <20230626171430.3167004-1-ryan.roberts@arm.com>
From:   Yu Zhao <yuzhao@google.com>
Date:   Mon, 26 Jun 2023 21:30:19 -0600
Message-ID: <CAOUHufaUTbUw9MTzw8D=sVrEB+RP6LSBQVGn93TWk=ozV8XobA@mail.gmail.com>
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

On Mon, Jun 26, 2023 at 11:14=E2=80=AFAM Ryan Roberts <ryan.roberts@arm.com=
> wrote:
>
> Hi All,
>
> Following on from the previous RFCv2 [1], this series implements variable=
 order,
> large folios for anonymous memory. The objective of this is to improve
> performance by allocating larger chunks of memory during anonymous page f=
aults:
>
>  - Since SW (the kernel) is dealing with larger chunks of memory than bas=
e
>    pages, there are efficiency savings to be had; fewer page faults, batc=
hed PTE
>    and RMAP manipulation, fewer items on lists, etc. In short, we reduce =
kernel
>    overhead. This should benefit all architectures.
>  - Since we are now mapping physically contiguous chunks of memory, we ca=
n take
>    advantage of HW TLB compression techniques. A reduction in TLB pressur=
e
>    speeds up kernel and user space. arm64 systems have 2 mechanisms to co=
alesce
>    TLB entries; "the contiguous bit" (architectural) and HPA (uarch).
>
> This patch set deals with the SW side of things only and based on feedbac=
k from
> the RFC, aims to be the most minimal initial change, upon which future
> incremental changes can be added. For this reason, the new behaviour is h=
idden
> behind a new Kconfig switch, CONFIG_LARGE_ANON_FOLIO, which is disabled b=
y
> default. Although the code has been refactored to parameterize the desire=
d order
> of the allocation, when the feature is disabled (by forcing the order to =
be
> always 0) my performance tests measure no regression. So I'm hoping this =
will be
> a suitable mechanism to allow incremental submissions to the kernel witho=
ut
> affecting the rest of the world.
>
> The patches are based on top of v6.4 plus Matthew Wilcox's set_ptes() ser=
ies
> [2], which is a hard dependency. I'm not sure of Matthew's exact plans fo=
r
> getting that series into the kernel, but I'm hoping we can start the revi=
ew
> process on this patch set independently. I have a branch at [3].
>
> I've posted a separate series concerning the HW part (contpte mapping) fo=
r arm64
> at [4].
>
>
> Performance
> -----------
>
> Below results show 2 benchmarks; kernel compilation and speedometer 2.0 (=
a
> javascript benchmark running in Chromium). Both cases are running on Ampe=
re
> Altra with 1 NUMA node enabled, Ubuntu 22.04 and XFS filesystem. Each ben=
chmark
> is repeated 15 times over 5 reboots and averaged.
>
> All improvements are relative to baseline-4k. 'anonfolio-basic' is this s=
eries.
> 'anonfolio' is the full patch set similar to the RFC with the additional =
changes
> to the extra 3 fault paths. The rest of the configs are described at [4].
>
> Kernel Compilation (smaller is better):
>
> | kernel          |   real-time |   kern-time |   user-time |
> |:----------------|------------:|------------:|------------:|
> | baseline-4k     |        0.0% |        0.0% |        0.0% |
> | anonfolio-basic |       -5.3% |      -42.9% |       -0.6% |
> | anonfolio       |       -5.4% |      -46.0% |       -0.3% |
> | contpte         |       -6.8% |      -45.7% |       -2.1% |
> | exefolio        |       -8.4% |      -46.4% |       -3.7% |
> | baseline-16k    |       -8.7% |      -49.2% |       -3.7% |
> | baseline-64k    |      -10.5% |      -66.0% |       -3.5% |
>
> Speedometer 2.0 (bigger is better):
>
> | kernel          |   runs_per_min |
> |:----------------|---------------:|
> | baseline-4k     |           0.0% |
> | anonfolio-basic |           0.7% |
> | anonfolio       |           1.2% |
> | contpte         |           3.1% |
> | exefolio        |           4.2% |
> | baseline-16k    |           5.3% |

Thanks for pushing this forward!

> Changes since RFCv2
> -------------------
>
>   - Simplified series to bare minimum (on David Hildenbrand's advice)

My impression is that this series still includes many pieces that can
be split out and discussed separately with followup series.

(I skipped 04/10 and will look at it tomorrow.)
