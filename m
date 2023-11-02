Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88813C4167D
	for <linux-ia64@archiver.kernel.org>; Thu,  2 Nov 2023 17:29:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231339AbjKBR3L (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 2 Nov 2023 13:29:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34560 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229463AbjKBR3L (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 2 Nov 2023 13:29:11 -0400
Received: from mail-ej1-x635.google.com (mail-ej1-x635.google.com [IPv6:2a00:1450:4864:20::635])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2C233123
        for <linux-ia64@vger.kernel.org>; Thu,  2 Nov 2023 10:29:05 -0700 (PDT)
Received: by mail-ej1-x635.google.com with SMTP id a640c23a62f3a-9adb9fa7200so246029166b.0
        for <linux-ia64@vger.kernel.org>; Thu, 02 Nov 2023 10:29:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1698946143; x=1699550943; darn=vger.kernel.org;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=uyMmGK3pqJfPbS0jfDAKY0ZEUhFBNW+33Pb+xOdwSj8=;
        b=cCk5Y1tD8TygWnzE6HR3Jfe6pE2vzR1zf9syWxGcNFJLdHi9yxdlDSKNA//Gi9n4G9
         hGFHyBX+0WDz5L/KHn2hO/9IL6uVEy4Dckma24oEPONFsxcJ71w9+zDHMmVlQ8FRhgJw
         ESkw5Gyaj7oXlqSlozj6kB68H0d8uobFZ28a0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1698946143; x=1699550943;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=uyMmGK3pqJfPbS0jfDAKY0ZEUhFBNW+33Pb+xOdwSj8=;
        b=qGQ24mimJWoadHTfhINiabqcsC7WIKNyTyjd33CQuzep2Kr5/BnnRLyXpOapI8Aw+2
         tXYnDuPYhsx9FKmZMT8B//TsuGXCWpMMdXQcgXbRfzr0XDhDrQl9ypBWOU45USL2c4rv
         bo5hkUNNzM/SbVGHKTPgxZBTACfWcbSN6YsJQPppElY6kbhekGnHFJhTxkclC9HLXVTM
         HESava9nTunB+aWQFW5tlIsK2agmUVKvzE4j/W7K8vojmq7LvwRM3SI1fhQXPV7MZDEF
         uCj9bCE/uUsS47c1XTwT/ikGkc/KCpcB080UaliSgxI7UpcG9rInMLLhsuQLnV4+NJ2U
         PoeQ==
X-Gm-Message-State: AOJu0YxawlQJrxLzXWYQ0R1vWdhyNf2FfTx2SNAHdbz+gPQn2LoGAKCf
        3Ry0BS27NU3KYqLpm6zcXW0UYzW2JQLNlOqeaixezjyI
X-Google-Smtp-Source: AGHT+IGbhFOpf3oLGIM83wmvRmaQ81PxQP8D+R9Kjw4r28HqZIEsl14JwVVUHRg/6h8R/yMOU+KtXA==
X-Received: by 2002:a17:907:9724:b0:9ae:5513:e475 with SMTP id jg36-20020a170907972400b009ae5513e475mr366757ejc.9.1698946143326;
        Thu, 02 Nov 2023 10:29:03 -0700 (PDT)
Received: from mail-ej1-f47.google.com (mail-ej1-f47.google.com. [209.85.218.47])
        by smtp.gmail.com with ESMTPSA id lz9-20020a170906fb0900b009a13fdc139fsm1372021ejb.183.2023.11.02.10.29.02
        for <linux-ia64@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 02 Nov 2023 10:29:03 -0700 (PDT)
Received: by mail-ej1-f47.google.com with SMTP id a640c23a62f3a-9becde9ea7bso463636966b.0
        for <linux-ia64@vger.kernel.org>; Thu, 02 Nov 2023 10:29:02 -0700 (PDT)
X-Received: by 2002:a17:907:1c87:b0:9a9:f0e6:904e with SMTP id
 nb7-20020a1709071c8700b009a9f0e6904emr470853ejc.16.1698946142622; Thu, 02 Nov
 2023 10:29:02 -0700 (PDT)
MIME-Version: 1.0
References: <340fc037-c18f-417f-8aaa-9cf88c9052f4@app.fastmail.com> <8ff191a0-41fa-4f36-86e8-3d32ff3fe75c@web.de>
In-Reply-To: <8ff191a0-41fa-4f36-86e8-3d32ff3fe75c@web.de>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu, 2 Nov 2023 07:28:45 -1000
X-Gmail-Original-Message-ID: <CAHk-=whFLZ67ffzt1juryCYcYz6eL_XjQF8WucDzwUR5H65+rA@mail.gmail.com>
Message-ID: <CAHk-=whFLZ67ffzt1juryCYcYz6eL_XjQF8WucDzwUR5H65+rA@mail.gmail.com>
Subject: Re: [GIT PULL] asm-generic updates for v6.7
To:     Frank Scheiner <frank.scheiner@web.de>
Cc:     Arnd Bergmann <arnd@arndb.de>,
        =?UTF-8?B?VG9tw6HFoSBHbG96YXI=?= <tglozar@gmail.com>,
        linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org,
        Linux-Arch <linux-arch@vger.kernel.org>,
        Ard Biesheuvel <ardb@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On Thu, 2 Nov 2023 at 00:24, Frank Scheiner <frank.scheiner@web.de> wrote:
>
> so the ia64 removal happened despite the efforts - not only from us - to
> keep it alive in Linux. That is a - sad - fact now.

Well, I'd have personally been willing to resurrect it, but I was told
several times that other projects were basically just waiting for the
kernel support to die.

Has the itanium situation really changed?

The thing is, nobody doing new kernel code wants to deal with itanium,
so relegating it to the same situation that i386 support was ("it
still works in old kernels") doesn't seem to be a huge issue for the
people who actually want to use those machines.

That said, I'd be willing to resurrect itanium support, even though I
personally despise the architecture with a passion for being
fundamentally based on faulty design premises, and an implementation
based on politics rather than good technical design.

But only if it turns out to actually have some long-term active
interest (ie I'd compare it to the situation with m68k etc - clearly
dead architectures that we still support despite them being not
relevant - because some people care and they don't cause pain).

So I'd be willing to come back to the "can we resurrect it"
discussion, but not immediately - more along the lines of a "look,
we've been maintaining it out of tree for a year, the other
infrastructure is still alive, there is no impact on the rest of the
kernel, can we please try again"?

               Linus
