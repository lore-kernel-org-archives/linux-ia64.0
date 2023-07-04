Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E20F9C001B0
	for <linux-ia64@archiver.kernel.org>; Tue,  4 Jul 2023 16:26:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231280AbjGDQ01 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 4 Jul 2023 12:26:27 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37578 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229610AbjGDQ00 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 4 Jul 2023 12:26:26 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 54380E5
        for <linux-ia64@vger.kernel.org>; Tue,  4 Jul 2023 09:25:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1688487942;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=M8/mkORscNjCU/dvtXt+o+8I4w7Qa8785g4rCe6dq88=;
        b=dtjWkysOlHq5uaRMSRftHkei1a1ILK6vtvXDwGWxj6H9UtNGfSZziG3QQXv3Pw/9mYaOT5
        BFgwdS2tZNoR+A98bGas5LWcWuye1DM2KCxquN9mBMZb8/j6FpFxHM5nnSCZGzzPFrdDPs
        9kEqHhmCTaHdL/oBciG6FhPCYaKlV+I=
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com
 [209.85.128.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-18-ddGcvtldMuKyV1pGSFxRVA-1; Tue, 04 Jul 2023 12:25:41 -0400
X-MC-Unique: ddGcvtldMuKyV1pGSFxRVA-1
Received: by mail-wm1-f71.google.com with SMTP id 5b1f17b1804b1-3fb40ec952bso36420265e9.0
        for <linux-ia64@vger.kernel.org>; Tue, 04 Jul 2023 09:25:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1688487940; x=1691079940;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=M8/mkORscNjCU/dvtXt+o+8I4w7Qa8785g4rCe6dq88=;
        b=S/fpJZFDTqnDP7yt/EKv7ySBMlKMen2ynJ3TMvXodFAXKe/FD2b1RiXLYzr2b7kPRJ
         8D+dsbYAEpgfxqVJUicR5zS+DsHRiNrIH63veovxJg4zg311WUsAgstTjV1WrwMnVFey
         CJWMgsCyZIlmk2F+E+Ud1r4Djjxl6fIFC6b32ioL9L7dfsSFPXf9hHGK2raFF2uvTAgD
         2OUb4Z5CxPR1Ab6PUYPw1ikyVt0/3FPtgiKAzMqq/AKCdTCOij9lpPc/Wrhmw3K3K0Y2
         GUZbiHYKl61pbV8RBKh+xtfRhDCxAngH3Eft+TV9c7ItePim031QtJg4YEni8n5JfLU0
         0xag==
X-Gm-Message-State: AC+VfDy0CkNeLQ2ION2WMrL04uHQZI8GFZ0p0AdV72c3ymQN4CoAG5zZ
        gTozk/fcV9y+UoEd7xdn0X7wQDFN+JYmyaCgFNjoPspKRbtWGX+tARzarg6h7MvJKSrvwEhPRuI
        AonfEx8vio2hE4fvp5zzDog==
X-Received: by 2002:a05:600c:c1:b0:3fa:8cd8:9743 with SMTP id u1-20020a05600c00c100b003fa8cd89743mr12082778wmm.19.1688487940449;
        Tue, 04 Jul 2023 09:25:40 -0700 (PDT)
X-Google-Smtp-Source: ACHHUZ5IB6++c8U11SK9oMV+tMdqHs9QUr8ub/i7nSM7HKLee5NlCRabAo+D01Z67Wv3BYjVWg90GQ==
X-Received: by 2002:a05:600c:c1:b0:3fa:8cd8:9743 with SMTP id u1-20020a05600c00c100b003fa8cd89743mr12082767wmm.19.1688487940180;
        Tue, 04 Jul 2023 09:25:40 -0700 (PDT)
Received: from localhost (205.pool92-176-231.dynamic.orange.es. [92.176.231.205])
        by smtp.gmail.com with ESMTPSA id r8-20020a056000014800b003143b032b7asm4333122wrx.116.2023.07.04.09.25.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 04 Jul 2023 09:25:39 -0700 (PDT)
From:   Javier Martinez Canillas <javierm@redhat.com>
To:     Thomas Zimmermann <tzimmermann@suse.de>, arnd@arndb.de,
        deller@gmx.de, daniel@ffwll.ch, airlied@gmail.com
Cc:     linux-arch@vger.kernel.org, linux-hyperv@vger.kernel.org,
        linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org,
        Thomas Zimmermann <tzimmermann@suse.de>,
        linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org,
        linux-staging@lists.linux.dev, linux-kernel@vger.kernel.org,
        linux-csky@vger.kernel.org, linux-mips@vger.kernel.org,
        linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
        loongarch@lists.linux.dev, linux-alpha@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org,
        linuxppc-dev@lists.ozlabs.org,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
        linux-arm-kernel@lists.infradead.org,
        Teddy Wang <teddy.wang@siliconmotion.com>
Subject: Re: [PATCH 02/12] fbdev/sm712fb: Do not include <linux/screen_info.h>
In-Reply-To: <20230629121952.10559-3-tzimmermann@suse.de>
References: <20230629121952.10559-1-tzimmermann@suse.de>
 <20230629121952.10559-3-tzimmermann@suse.de>
Date:   Tue, 04 Jul 2023 18:25:39 +0200
Message-ID: <87fs63lk3g.fsf@minerva.mail-host-address-is-not-set>
MIME-Version: 1.0
Content-Type: text/plain
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Thomas Zimmermann <tzimmermann@suse.de> writes:

> Sm712fb's dependency on <linux/screen_info.h> is artificial in that
> it only uses struct screen_info for its internals. Replace the use of
> struct screen_info with a custom data structure and remove the include
> of <linux/screen_info.h>.
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Cc: Teddy Wang <teddy.wang@siliconmotion.com>
> Cc: Helge Deller <deller@gmx.de>
> ---

Reviewed-by: Javier Martinez Canillas <javierm@redhat.com>

-- 
Best regards,

Javier Martinez Canillas
Core Platforms
Red Hat

