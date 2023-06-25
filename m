Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB001EB64DC
	for <linux-ia64@archiver.kernel.org>; Sun, 25 Jun 2023 21:27:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230053AbjFYV1v (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Sun, 25 Jun 2023 17:27:51 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46994 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229586AbjFYV1t (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Sun, 25 Jun 2023 17:27:49 -0400
Received: from mail-wr1-x429.google.com (mail-wr1-x429.google.com [IPv6:2a00:1450:4864:20::429])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E7E7D137
        for <linux-ia64@vger.kernel.org>; Sun, 25 Jun 2023 14:27:47 -0700 (PDT)
Received: by mail-wr1-x429.google.com with SMTP id ffacd0b85a97d-31126037f41so3183926f8f.2
        for <linux-ia64@vger.kernel.org>; Sun, 25 Jun 2023 14:27:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google; t=1687728466; x=1690320466;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=75eDqtaV4HxjbOY0L3WJNiE0VV9dzyg9cgqtVXJznBY=;
        b=P4OMFY0E+kb5eR0W9Y6kEgLPJuc6u7faK0X1O+XQGbwqlajdF/jfFWAcx8BRjDqGzO
         mh6gHGoaEUDX+sh3nKQRSDJ7HA0jh2sHDYtRXrtRDSCN3zTIndInhtFLLYMRLTUVyOKS
         YpCq/XTlPUo+K6NWRXFBXfXuAiMnnc5n0pIhRCxDVLvmATOI8nFzSZ2lOhnffLdUEmwd
         VeArt9sQbwQphWxkK4kf1essGtLoTUS/ckhnahsuy5pt7r3o+oJjlr5xYi1q+x0YAcvy
         jUeA3jWRJo1IshymxkGUWJrB/2Mitej5Iu/x3GJN9KZtlWpfpaIlbv4Lf+DJiRh45Kkw
         WFWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1687728466; x=1690320466;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=75eDqtaV4HxjbOY0L3WJNiE0VV9dzyg9cgqtVXJznBY=;
        b=Vk2y5F+SkgMxeUiARwiiXxmgvwBzDie15nFLwMWmLbvw/UXIiKt/3W87z5Gq/gkHmj
         rgBZ3QaXroOpS9bdz30Mvts20fgQRw718rrnqj3Atkg+M60q/zmRUwzVVmRqWvJj9WY7
         F5OuTyPP/yBjo0aar51m2TqcJN04VFMl8C7ughZznR7O/rx3583Oz96iviXtl96q7sqL
         Jk/ynlWurawuwM7VUvFGEYO51geOkHKwgiCcAJqu340u+L9UdCnmjeY8AmvXspPhWihu
         I+MUMUWcV4nSRV9u8kI3udX/6WwSlr6YlQZBamGZEy9r+ddZ8THLSfmJgeqyyoi+ygfb
         0fpg==
X-Gm-Message-State: AC+VfDxk0ju5oovhsdoim/LwSxjwf1vKuxUEgL7ldfFdZ5JItYOrT7xG
        spo4wkM3D3GBSoUbE74JkgE4eg==
X-Google-Smtp-Source: ACHHUZ6Hjasu9Lrk/CatQAEzcCmcG0JhA1BO0YkpChmI4xEA5JcA/nNpFTMJqb3YFVfr7dLSsRzufQ==
X-Received: by 2002:a5d:474f:0:b0:313:f07b:8027 with SMTP id o15-20020a5d474f000000b00313f07b8027mr1072096wrs.36.1687728466257;
        Sun, 25 Jun 2023 14:27:46 -0700 (PDT)
Received: from [192.168.69.115] ([176.187.212.184])
        by smtp.gmail.com with ESMTPSA id r13-20020adfe68d000000b0030fb4b55c13sm5420254wrm.96.2023.06.25.14.27.41
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 25 Jun 2023 14:27:45 -0700 (PDT)
Message-ID: <9c362e4f-ba40-02a6-fb22-aed6598ec536@linaro.org>
Date:   Sun, 25 Jun 2023 23:27:40 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:102.0)
 Gecko/20100101 Thunderbird/102.12.0
Subject: Re: [patch 03/17] ARM: cpu: Switch to arch_cpu_finalize_init()
Content-Language: en-US
To:     Thomas Gleixner <tglx@linutronix.de>,
        LKML <linux-kernel@vger.kernel.org>
Cc:     x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Nikolay Borisov <nik.borisov@suse.com>,
        "Ahmed S. Darwish" <darwi@linutronix.de>,
        Arnd Bergmann <arnd@arndb.de>,
        Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
        Huacai Chen <chenhuacai@kernel.org>,
        WANG Xuerui <kernel@xen0n.name>, loongarch@lists.linux.dev,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-m68k@lists.linux-m68k.org,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        linux-mips@vger.kernel.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>,
        linux-sh@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        sparclinux@vger.kernel.org, Richard Weinberger <richard@nod.at>,
        Anton Ivanov <anton.ivanov@cambridgegreys.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        linux-um@lists.infradead.org,
        Richard Henderson <richard.henderson@linaro.org>,
        "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Chris Zankel <chris@zankel.net>,
        Tom Lendacky <thomas.lendacky@amd.com>
References: <20230613223827.532680283@linutronix.de>
 <20230613224545.078124882@linutronix.de>
From:   =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
In-Reply-To: <20230613224545.078124882@linutronix.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On 14/6/23 01:39, Thomas Gleixner wrote:
> check_bugs() is about to be phased out. Switch over to the new
> arch_cpu_finalize_init() implementation.
> 
> No functional change.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-arm-kernel@lists.infradead.org
> ---
>   arch/arm/Kconfig            |    1 +
>   arch/arm/include/asm/bugs.h |    4 ----
>   arch/arm/kernel/bugs.c      |    3 ++-
>   3 files changed, 3 insertions(+), 5 deletions(-)

Reviewed-by: Philippe Mathieu-Daudé <philmd@linaro.org>

