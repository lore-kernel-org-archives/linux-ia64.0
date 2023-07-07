Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33F47EB64DA
	for <linux-ia64@archiver.kernel.org>; Fri,  7 Jul 2023 15:28:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232991AbjGGP14 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Fri, 7 Jul 2023 11:27:56 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58836 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229695AbjGGP1z (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Fri, 7 Jul 2023 11:27:55 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F2CA82688
        for <linux-ia64@vger.kernel.org>; Fri,  7 Jul 2023 08:27:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1688743630;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=+8qlgKJYI7kB6D1e5SNd04VHZ2yM21oq3nfTt/gANL8=;
        b=UviOnqTeLZ+PLbCdocCIZTxDAXj++a6rTmvyJFx8d2fu4C6nA6cBt66MTgJOM0uELIQybm
        4a6smt6EyB9khFjjFL0E6kUNPybp5PWGXay95ImsbkGcDHmwXMYeColiIQXnsqVmFLNB/B
        R+pfQXUDba9lAK8qe5KS7cIUQ8cBV0w=
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com
 [209.85.221.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-622-RV61VjkPPU6BJDRSDKWK0Q-1; Fri, 07 Jul 2023 11:27:06 -0400
X-MC-Unique: RV61VjkPPU6BJDRSDKWK0Q-1
Received: by mail-wr1-f72.google.com with SMTP id ffacd0b85a97d-3142665f122so1022684f8f.0
        for <linux-ia64@vger.kernel.org>; Fri, 07 Jul 2023 08:27:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1688743624; x=1691335624;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=+8qlgKJYI7kB6D1e5SNd04VHZ2yM21oq3nfTt/gANL8=;
        b=e8XcKSWG/+Vxg0wHK4vCz4W0kWuqvuJOkwec3Kspk2n+9JSiLAJd2WTovTpQtWlsHi
         mx+Iyf8fuVfgOLz+VaGWfveXaVxk3f9bHV+VmdhWoavvkCSGusleQAbSbU5mFhz9/xsU
         8gugrh3LfJvn44JE6zIYxvE6w6rNiSWG4jrf+ZJaVvEbVeXFAbxNn1/3Q0BH0fegPiJA
         bIF2MdvimzX3ZPJUqdOBGmbomEQI3+wYLUzmXHYRhC8pjnRXb7v4GWLg/f+zhZK5tBCc
         jDjs/fXWxXwz/U/Ch6UOT2lSWzThn+HYhHOPA7M4aNbXrKsS3esUSL1f7zXL1WaXY8Yl
         fRNw==
X-Gm-Message-State: ABy/qLac3W9eiFCJBmvFbqPQryJMHZy2i+Uq/m+qw4tphkBPJxgm8MOy
        XIHt1Zm/5DfulR00xBePybVsAHsZcT5Ywvft4HEM65n7du0kDjKhefBgkE8imbeT/58uwzTK7C3
        SxlG9GF4vq8Ch2mT8COeBmtIjpF1aMA==
X-Received: by 2002:adf:f052:0:b0:30a:a15d:eb2f with SMTP id t18-20020adff052000000b0030aa15deb2fmr4668110wro.3.1688743624754;
        Fri, 07 Jul 2023 08:27:04 -0700 (PDT)
X-Google-Smtp-Source: APBJJlGmxd1jbrrvV1R0iu/TeFKW/e1nuXfI0DnXijMIXAlyALphvzgzqltgfOe8J565vUOEzxyvoA==
X-Received: by 2002:adf:f052:0:b0:30a:a15d:eb2f with SMTP id t18-20020adff052000000b0030aa15deb2fmr4668074wro.3.1688743624480;
        Fri, 07 Jul 2023 08:27:04 -0700 (PDT)
Received: from localhost (205.pool92-176-231.dynamic.orange.es. [92.176.231.205])
        by smtp.gmail.com with ESMTPSA id bl1-20020adfe241000000b003143c9beeaesm4711005wrb.44.2023.07.07.08.27.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 07 Jul 2023 08:27:04 -0700 (PDT)
From:   Javier Martinez Canillas <javierm@redhat.com>
To:     Arnd Bergmann <arnd@arndb.de>, Arnd Bergmann <arnd@kernel.org>,
        Thomas Zimmermann <tzimmermann@suse.de>
Cc:     linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Russell King <linux@armlinux.org.uk>,
        dri-devel@lists.freedesktop.org, Ard Biesheuvel <ardb@kernel.org>,
        Helge Deller <deller@gmx.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Richard Henderson <richard.henderson@linaro.org>,
        Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
        Matt Turner <mattst88@gmail.com>,
        Huacai Chen <chenhuacai@kernel.org>,
        WANG Xuerui <kernel@xen0n.name>,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Nicholas Piggin <npiggin@gmail.com>,
        Christophe Leroy <christophe.leroy@csgroup.eu>,
        Paul Walmsley <paul.walmsley@sifive.com>,
        Palmer Dabbelt <palmer@dabbelt.com>,
        Albert Ou <aou@eecs.berkeley.edu>, linux-alpha@vger.kernel.org,
        linux-ia64@vger.kernel.org, loongarch@lists.linux.dev,
        linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-riscv@lists.infradead.org
Subject: Re: [PATCH 2/4] vgacon: rework screen_info #ifdef checks
In-Reply-To: <ff9bfcfa-fa3b-42d2-b429-059b5103bce2@app.fastmail.com>
References: <20230707095415.1449376-1-arnd@kernel.org>
 <20230707095415.1449376-2-arnd@kernel.org>
 <87jzvbyh4p.fsf@minerva.mail-host-address-is-not-set>
 <ff9bfcfa-fa3b-42d2-b429-059b5103bce2@app.fastmail.com>
Date:   Fri, 07 Jul 2023 17:27:03 +0200
Message-ID: <87bkgnyc6w.fsf@minerva.mail-host-address-is-not-set>
MIME-Version: 1.0
Content-Type: text/plain
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

"Arnd Bergmann" <arnd@arndb.de> writes:

> On Fri, Jul 7, 2023, at 15:40, Javier Martinez Canillas wrote:

[...]

>> And this is only used by mdacon (not supported by ia64), vgacon and
>> vga16fb (not supported by ia64 either).
>>
>> So this could just be guarded just by CONFIG_VGA_CONSOLE for ia64 ?
>
> Right, I though about doing this more accurately, but in the end
> went for the simplest change rather than spending much more time
> trying to clean up the unused variables etc.
>
> Let me know if you'd prefer me to respin this part, otherwise
> I'd call the ia64 bit good enough for the purpose of the series.
>

No need to re-spin, agreed that makes sense to keep it simpler.

-- 
Best regards,

Javier Martinez Canillas
Core Platforms
Red Hat

