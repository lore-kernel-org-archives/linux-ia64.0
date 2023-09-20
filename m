Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 416C7CE79AB
	for <linux-ia64@archiver.kernel.org>; Wed, 20 Sep 2023 08:02:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233071AbjITICV (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Wed, 20 Sep 2023 04:02:21 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51536 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233419AbjITICS (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Wed, 20 Sep 2023 04:02:18 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 315C1B4
        for <linux-ia64@vger.kernel.org>; Wed, 20 Sep 2023 01:01:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1695196891;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=rnpCpoK1Qphye/H0at9y+THlkxPvcEo2r5PdFTxqnHY=;
        b=b6aYi71saap/Q6w8BgWz6mQXiXVwgl0Fs+rUU4R6MWfhjDt9zNt3fGEd7AVhhr8pr9zJre
        OC2aryCtmSl1R8Z8O+dyOWLwWSn26BY3/LKeLeQC8y8e4mb7iJyL2fQPd1q498UpI3K2uK
        7w23AtkppUnbnq9ylCYxW3UKmmU65BU=
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com
 [209.85.221.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-541-mBZKPFYNPSOq8z09SB5ABw-1; Wed, 20 Sep 2023 04:01:30 -0400
X-MC-Unique: mBZKPFYNPSOq8z09SB5ABw-1
Received: by mail-wr1-f70.google.com with SMTP id ffacd0b85a97d-31f79595669so238953f8f.0
        for <linux-ia64@vger.kernel.org>; Wed, 20 Sep 2023 01:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1695196889; x=1695801689;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=rnpCpoK1Qphye/H0at9y+THlkxPvcEo2r5PdFTxqnHY=;
        b=Gg8Zd/b8c0qQVwMQzLm1SRxlZudcVg1TdULw1afbYfS/s7LeXZc90ALEF5/7shJJ8N
         2YTVBggxzI6kaMVZUQTo1KMOVvc1wlljbWfWTluK6IS4HEW3swF0LfWnl2v5PkSznQK9
         MvhekQQjsiZBH0OfrcJtpW3u4lL4okgRlDsdv3YFxQtlrVWjum+zYu4cFY8qSGNZWyac
         TICRTm8K0GTaFvlu3tTmvp+XK5AkJMtwo9esqAJbBN+5bXS0D7Z/6B59y8D/T8XdlVNp
         imUFk62UejtO1uamZpSVHLl+d5YXkTYvpmsRRja6+KV8jMtHju3+XwKL2kdhR+cUkzZl
         MB7A==
X-Gm-Message-State: AOJu0YwGiwDVCExEcPdsxKcy6T5Zrdnj6DPsoycx6ZzV2jCM1NQYMJlk
        MTclmSXLqSU4VVJaBrNh/6zIdxGYh3pC18PgbAVCky8dfTG7R+IeruC0PEi0sW7zXTEqx9pd/lo
        7fLziC/t7r6QPZ+CPfwD84A==
X-Received: by 2002:a5d:4691:0:b0:317:6579:2b9f with SMTP id u17-20020a5d4691000000b0031765792b9fmr1441905wrq.30.1695196888609;
        Wed, 20 Sep 2023 01:01:28 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IEGjMaHCrb95S6OjzxI7LM9YzqMZD+FHo9V0ilc7E6hmphf8oly7XaHzjchfvY6rdHHetD1Jw==
X-Received: by 2002:a5d:4691:0:b0:317:6579:2b9f with SMTP id u17-20020a5d4691000000b0031765792b9fmr1441876wrq.30.1695196888277;
        Wed, 20 Sep 2023 01:01:28 -0700 (PDT)
Received: from localhost (205.pool92-176-231.dynamic.orange.es. [92.176.231.205])
        by smtp.gmail.com with ESMTPSA id a4-20020adffb84000000b0031c5e9c2ed7sm17627845wrr.92.2023.09.20.01.01.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 20 Sep 2023 01:01:27 -0700 (PDT)
From:   Javier Martinez Canillas <javierm@redhat.com>
To:     Thomas Zimmermann <tzimmermann@suse.de>, mpe@ellerman.id.au,
        npiggin@gmail.com, christophe.leroy@csgroup.eu, arnd@arndb.de,
        deller@gmx.de
Cc:     linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org,
        linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org,
        dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org,
        Thomas Zimmermann <tzimmermann@suse.de>,
        sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v4 1/5] fbdev: Avoid file argument in fb_pgprotect()
In-Reply-To: <20230912135050.17155-2-tzimmermann@suse.de>
References: <20230912135050.17155-1-tzimmermann@suse.de>
 <20230912135050.17155-2-tzimmermann@suse.de>
Date:   Wed, 20 Sep 2023 10:01:27 +0200
Message-ID: <87il85l1d4.fsf@minerva.mail-host-address-is-not-set>
MIME-Version: 1.0
Content-Type: text/plain
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Thomas Zimmermann <tzimmermann@suse.de> writes:

Hello Thomas,

> Only PowerPC's fb_pgprotect() needs the file argument, although
> the implementation does not use it. Pass NULL to the internal

Can you please mention the function that's the implementation for
PowerPC ? If I'm looking at the code correctly, that function is
phys_mem_access_prot() defined in the arch/powerpc/mm/mem.c file:

pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
			      unsigned long size, pgprot_t vma_prot)
{
	if (ppc_md.phys_mem_access_prot)
		return ppc_md.phys_mem_access_prot(file, pfn, size, vma_prot);

	if (!page_is_ram(pfn))
		vma_prot = pgprot_noncached(vma_prot);

	return vma_prot;
}

and if set, ppc_md.phys_mem_access_prot is pci_phys_mem_access_prot()
that is defined in the arch/powerpc/kernel/pci-common.c source file:

https://elixir.bootlin.com/linux/v6.6-rc2/source/arch/powerpc/kernel/pci-common.c#L524

That function indeed doesn't use the file argument. So your patch looks
correct to me.

Reviewed-by: Javier Martinez Canillas <javierm@redhat.com>

-- 
Best regards,

Javier Martinez Canillas
Core Platforms
Red Hat

