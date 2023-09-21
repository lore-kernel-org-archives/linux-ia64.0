Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79392E7D0A9
	for <linux-ia64@archiver.kernel.org>; Thu, 21 Sep 2023 20:33:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232024AbjIUUd6 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 21 Sep 2023 16:33:58 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57504 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231699AbjIUUd1 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 21 Sep 2023 16:33:27 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 535B385D08
        for <linux-ia64@vger.kernel.org>; Thu, 21 Sep 2023 10:37:47 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5499BC4E664
        for <linux-ia64@vger.kernel.org>; Thu, 21 Sep 2023 11:53:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1695297227;
        bh=1Oeb8NlvpuEqVOtKVelchqbugYyyi9llld9LK/peaBU=;
        h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
        b=nEVSP9ElrzrVrJEPSqrvSUhISd+Zs6/NeMhn6MlZ/w4Xs4zcIFvKBAEks/Z6G1iQt
         aygCexJjpiM0VZUOPv91RyrXNYOZKkCrLIX1ACMFwRdsv6mO71Muiy6y/Cthx2+f+f
         F2u8cWWUptbGia5YNLimokm1GIn4RjZY9bdjlPZFoMmxPp7iIdphJ0zSYf9bkbYgSy
         KcRJjWP4sMC8X1RnfCimYiEvQVX4rJQj5p9ZZkLExcSbbHgfwuEBOOGT8qH17b2CtQ
         jaOxQz4c5rz4gDtLxjvwHsCwD+ELtMnCzwkok1TeDPUkL4DAu1+ZPgEgpml9r0YmNp
         /Z2GbjyTXaohA==
Received: by mail-lj1-f173.google.com with SMTP id 38308e7fff4ca-2c135cf2459so1952461fa.0
        for <linux-ia64@vger.kernel.org>; Thu, 21 Sep 2023 04:53:47 -0700 (PDT)
X-Gm-Message-State: AOJu0YyYXbD/E9Aq6TkJiPnIwrSbaaz7cUHAQrdg1HF511xmVwKSGEQ2
        Pm+ilSVbHj1ePoAFoGDkq62I8OdGeoRCyjOlQ54=
X-Google-Smtp-Source: AGHT+IGJ0Fz6CIwisVQXQy9hiKPHod+zWnwbUrgVrQEfnrH19V0wpv3KMQJxlh+aXRgURGHuyanyvDVvFqdp+d8cCmE=
X-Received: by 2002:a2e:8905:0:b0:2c0:3186:8efa with SMTP id
 d5-20020a2e8905000000b002c031868efamr4991545lji.11.1695297225508; Thu, 21 Sep
 2023 04:53:45 -0700 (PDT)
MIME-Version: 1.0
References: <adc65a97-2479-8779-0e09-4ec2fe946cb2@web.de>
In-Reply-To: <adc65a97-2479-8779-0e09-4ec2fe946cb2@web.de>
From:   Ard Biesheuvel <ardb@kernel.org>
Date:   Thu, 21 Sep 2023 11:53:34 +0000
X-Gmail-Original-Message-ID: <CAMj1kXGDVWYJMHJay3j8P=EQMMv1cmSLRDoiDBrt1hdvZpOpww@mail.gmail.com>
Message-ID: <CAMj1kXGDVWYJMHJay3j8P=EQMMv1cmSLRDoiDBrt1hdvZpOpww@mail.gmail.com>
Subject: Re: Build regression since v6.6-rc1
To:     Frank Scheiner <frank.scheiner@web.de>,
        Arnd Bergmann <arnd@arndb.de>
Cc:     linux-ia64@vger.kernel.org, rafael.j.wysocki@intel.com,
        michal.wilczynski@intel.com,
        debian-ia64 <debian-ia64@lists.debian.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Hello Frank,

On Thu, 21 Sept 2023 at 10:15, Frank Scheiner <frank.scheiner@web.de> wrote:
>
> Dear all,
>
> since v6.6-rc1 (actually introduced with [1], specific commit on [2])
> the kernel build for ia64 fails like that:
>
> ```
...
>
> Could one ([5]) or the other ([6]) please be included in v6.6 (or
> earlier) to "fix" the build problem for ia64?
>

Do you mean by "fix" that the proposed fixes are just workarounds and
not proper fixes? I don't think that is the case - the function in
question does nothing except apply a quirk for one specific x86
platform.

...
> [5]:
> https://lore.kernel.org/lkml/CAJZ5v0hnNK4O_HyinvTp01YxXR7V4vzpMhf85yW9M2=52-O2Fg@mail.gmail.com/
>
> [6]:
> https://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git/commit/?id=a0334bf78b95532cec54f56b53e8ae1bfe7e1ca1

Either Arnd, Rafael or myself should send a PR to Linus to merge [6]
as a fix, as it is already queued up in -next for v6.7.

Or perhaps Linus doesn't mind grabbing it from here:

------------8<--------------

The following changes since commit 0bb80ecc33a8fb5a682236443c1e740d5c917d1d:

  Linux 6.6-rc1 (2023-09-10 16:28:41 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git
tags/fix-ia64-build-for-v6.6

for you to fetch changes up to a0334bf78b95532cec54f56b53e8ae1bfe7e1ca1:

  acpi: Provide ia64 dummy implementation of
acpi_proc_quirk_mwait_check() (2023-09-11 08:13:17 +0000)

----------------------------------------------------------------
Build fix for Itanium/ia64:

- provide dummy implementation of acpi_proc_quirk_mwait_check() which
  was moved out of generic code into arch/x86, breaking the ia64 build

----------------------------------------------------------------
Ard Biesheuvel (1):
      acpi: Provide ia64 dummy implementation of acpi_proc_quirk_mwait_check()

 arch/ia64/kernel/acpi.c | 4 ++++
 1 file changed, 4 insertions(+)
