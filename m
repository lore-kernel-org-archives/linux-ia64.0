Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70F6AEB64DB
	for <linux-ia64@archiver.kernel.org>; Wed, 14 Jun 2023 06:51:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S243099AbjFNGv5 convert rfc822-to-8bit (ORCPT
        <rfc822;linux-ia64@archiver.kernel.org>);
        Wed, 14 Jun 2023 02:51:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54108 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234554AbjFNGv4 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Wed, 14 Jun 2023 02:51:56 -0400
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0B59D10FE;
        Tue, 13 Jun 2023 23:51:53 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id F1F3E63CC111;
        Wed, 14 Jun 2023 08:51:50 +0200 (CEST)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10032)
        with ESMTP id NhsAn0pqGJjc; Wed, 14 Jun 2023 08:51:50 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id 756B4608F44F;
        Wed, 14 Jun 2023 08:51:50 +0200 (CEST)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10026)
        with ESMTP id tYnTmxn9hAwM; Wed, 14 Jun 2023 08:51:50 +0200 (CEST)
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lithops.sigma-star.at (Postfix) with ESMTP id 3D44C63CC111;
        Wed, 14 Jun 2023 08:51:50 +0200 (CEST)
Date:   Wed, 14 Jun 2023 08:51:50 +0200 (CEST)
From:   Richard Weinberger <richard@nod.at>
To:     tglx <tglx@linutronix.de>
Cc:     linux-kernel <linux-kernel@vger.kernel.org>, x86 <x86@kernel.org>,
        torvalds <torvalds@linux-foundation.org>,
        Nikolay Borisov <nik.borisov@suse.com>,
        "Ahmed S. Darwish" <darwi@linutronix.de>,
        Arnd Bergmann <arnd@arndb.de>,
        anton ivanov <anton.ivanov@cambridgegreys.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        linux-um <linux-um@lists.infradead.org>,
        Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-ia64@vger.kernel.org, Huacai Chen <chenhuacai@kernel.org>,
        WANG Xuerui <kernel@xen0n.name>, loongarch@lists.linux.dev,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-m68k <linux-m68k@lists.linux-m68k.org>,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        linux-mips <linux-mips@vger.kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>,
        linux-sh@vger.kernel.org, davem <davem@davemloft.net>,
        sparclinux <sparclinux@vger.kernel.org>,
        Richard Henderson <richard.henderson@linaro.org>,
        "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Chris Zankel <chris@zankel.net>,
        Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <308775127.5298661.1686725510008.JavaMail.zimbra@nod.at>
In-Reply-To: <20230613224545.493148694@linutronix.de>
References: <20230613223827.532680283@linutronix.de> <20230613224545.493148694@linutronix.de>
Subject: Re: [patch 10/17] um/cpu: Switch to arch_cpu_finalize_init()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
X-Originating-IP: [195.201.40.130]
X-Mailer: Zimbra 8.8.12_GA_3807 (ZimbraWebClient - FF97 (Linux)/8.8.12_GA_3809)
Thread-Topic: um/cpu: Switch to arch_cpu_finalize_init()
Thread-Index: iSTlBjUa5Wmo5DQJGeG0TUMeIHydTg==
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

----- Ursprüngliche Mail -----
> Von: "tglx" <tglx@linutronix.de>
> check_bugs() is about to be phased out. Switch over to the new
> arch_cpu_finalize_init() implementation.
> 
> No functional change.

Confirmed. :-)
 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Richard Weinberger <richard@nod.at>
> Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Cc: linux-um@lists.infradead.org

Acked-by: Richard Weinberger <richard@nod.at>

Thanks,
//richard
