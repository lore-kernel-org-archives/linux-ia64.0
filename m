Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58C9FC0015E
	for <linux-ia64@archiver.kernel.org>; Wed, 19 Jul 2023 13:50:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231414AbjGSNt7 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Wed, 19 Jul 2023 09:49:59 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33828 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230500AbjGSNt6 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Wed, 19 Jul 2023 09:49:58 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 05C3919A
        for <linux-ia64@vger.kernel.org>; Wed, 19 Jul 2023 06:49:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1689774555;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=7gvBqRrgzjiPOFgHQxEB0Nm34S2dkYf27eWyqPPlFhY=;
        b=O5Rd1URVjeh3tsQBpWBdG/ni9Q3s6GpVO5o+5lMdTSIxTxC+ZR8bzquFK10YAccDsOvlyR
        XoUlHlrpd9iy1eW3Y5ZuTwxhSmAJ2kSf7aAHMhuzHBiDNAKzpDLTlcbtMEQn5sMrw1uVPi
        5zZ0MaBdd4Gn7k9rsO3tfhQ+uj8OS+A=
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com
 [209.85.221.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-282-BpBt8EO1Pwi7E32voPI1Qw-1; Wed, 19 Jul 2023 09:49:13 -0400
X-MC-Unique: BpBt8EO1Pwi7E32voPI1Qw-1
Received: by mail-wr1-f71.google.com with SMTP id ffacd0b85a97d-316f39e3e89so349552f8f.1
        for <linux-ia64@vger.kernel.org>; Wed, 19 Jul 2023 06:49:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1689774552; x=1690379352;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=7gvBqRrgzjiPOFgHQxEB0Nm34S2dkYf27eWyqPPlFhY=;
        b=MJ3yNsnlc1oen7qx39wDsRK8Y3dWtcKohVKO/ERgpSOdWNsJB1epz1L8PTR7AWUXop
         no8X59m3kkU62354/mLZLbM/hPHiYgo4tF3XdfUFUJV9ZRLuqsxi2jE2oCL8BPHhtB9+
         vm/PTHRq6RW1DUMfEFhe5/T1X/HPwyirfkse1szSPFLHxqXxb8e6U156WSIE0aJgHbpS
         ASOFTMjdh2D4dANrfJrRchOMGN/lKrT17Vtx/XECl35tor2TEyvaDLKZseEEaUZG0mp8
         gy8WFNuswaEUy3FUknivRds7aLRYqohjhIBGvTzf+7o2hW+2765FFgPFxdZIISbE+OEB
         rDSQ==
X-Gm-Message-State: ABy/qLYjQSFtxYWB8sOkTgWB+d0k4R/TCPnJ1R1e2enqrCpxnJk+cere
        gX4T+WhAsPgaCCK7J2wlpK6C7iwSR/vPwbaoPYlRMT0A+vqPad91d5Wg6V4AdAx9UlLsEHRp6iR
        BopsXfssd+yGqlWm0w8j5wQ==
X-Received: by 2002:a5d:6a04:0:b0:314:3369:df57 with SMTP id m4-20020a5d6a04000000b003143369df57mr1948314wru.5.1689774552637;
        Wed, 19 Jul 2023 06:49:12 -0700 (PDT)
X-Google-Smtp-Source: APBJJlFD8G6VPVcqqGeSjptpNDnOnSs3W+CAZM63rDbbbVz9hymKgoyuOl3Kik6r5ce0mC8oQNhizg==
X-Received: by 2002:a5d:6a04:0:b0:314:3369:df57 with SMTP id m4-20020a5d6a04000000b003143369df57mr1948300wru.5.1689774552274;
        Wed, 19 Jul 2023 06:49:12 -0700 (PDT)
Received: from localhost (205.pool92-176-231.dynamic.orange.es. [92.176.231.205])
        by smtp.gmail.com with ESMTPSA id q2-20020a5d6582000000b003143bb5ecd5sm5381303wru.69.2023.07.19.06.49.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 19 Jul 2023 06:49:11 -0700 (PDT)
From:   Javier Martinez Canillas <javierm@redhat.com>
To:     Arnd Bergmann <arnd@kernel.org>, linux-fbdev@vger.kernel.org,
        Thomas Zimmermann <tzimmermann@suse.de>,
        Helge Deller <deller@gmx.de>
Cc:     Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Ard Biesheuvel <ardb@kernel.org>,
        Borislav Petkov <bp@alien8.de>, Brian Cain <bcain@quicinc.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Christophe Leroy <christophe.leroy@csgroup.eu>,
        Daniel Vetter <daniel@ffwll.ch>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        David Airlie <airlied@gmail.com>,
        Deepak Rawat <drawat.floss@gmail.com>,
        Dexuan Cui <decui@microsoft.com>,
        Dinh Nguyen <dinguyen@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guo Ren <guoren@kernel.org>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Huacai Chen <chenhuacai@kernel.org>,
        Ingo Molnar <mingo@redhat.com>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>,
        Khalid Aziz <khalid@gonehiking.org>,
        Linus Walleij <linus.walleij@linaro.org>,
        Matt Turner <mattst88@gmail.com>,
        Max Filippov <jcmvbkbc@gmail.com>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Nicholas Piggin <npiggin@gmail.com>,
        Palmer Dabbelt <palmer@dabbelt.com>,
        Russell King <linux@armlinux.org.uk>,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        Thomas Gleixner <tglx@linutronix.de>,
        WANG Xuerui <kernel@xen0n.name>, Wei Liu <wei.liu@kernel.org>,
        Will Deacon <will@kernel.org>, x86@kernel.org,
        linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org,
        linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org,
        linux-ia64@vger.kernel.org, loongarch@lists.linux.dev,
        linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-hyperv@vger.kernel.org,
        dri-devel@lists.freedesktop.org
Subject: Re: [PATCH v2 5/9] vgacon: remove screen_info dependency
In-Reply-To: <20230719123944.3438363-6-arnd@kernel.org>
References: <20230719123944.3438363-1-arnd@kernel.org>
 <20230719123944.3438363-6-arnd@kernel.org>
Date:   Wed, 19 Jul 2023 15:49:11 +0200
Message-ID: <87fs5khuzs.fsf@minerva.mail-host-address-is-not-set>
MIME-Version: 1.0
Content-Type: text/plain
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Arnd Bergmann <arnd@kernel.org> writes:

> From: Arnd Bergmann <arnd@arndb.de>
>
> The vga console driver is fairly self-contained, and only used by
> architectures that explicitly initialize the screen_info settings.
>
> Chance every instance that picks the vga console by setting conswitchp
> to call a function instead, and pass a reference to the screen_info
> there.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---

Reviewed-by: Javier Martinez Canillas <javierm@redhat.com>

-- 
Best regards,

Javier Martinez Canillas
Core Platforms
Red Hat

