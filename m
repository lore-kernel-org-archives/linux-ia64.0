Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 342F9C4332F
	for <linux-ia64@archiver.kernel.org>; Fri, 10 Nov 2023 03:27:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232516AbjKJD15 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 9 Nov 2023 22:27:57 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59486 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229627AbjKJD14 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 9 Nov 2023 22:27:56 -0500
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7B05144BF
        for <linux-ia64@vger.kernel.org>; Thu,  9 Nov 2023 19:27:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1699586831;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=AaVo9IVfWLz/BqLc17ue4Q1CD1g0z57ZzeqlpNNIaz0=;
        b=AI+3iqjYkNgekXMZ0Y75EZxXN8kpa0Ap5/GzVhym37pb9d7YfhHh3fWrtGygQDjiEVfTZs
        uQhmSDzkdbgs264S6oQ5uOsCYRQigFPlYqrB6eBp2TP7jwiPEofF0268juhAk0BFaCMZMz
        SvDCxQu19pSWd407CSkiDl7s6mNF3V0=
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com
 [209.85.210.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-672-KQfrtO9lOCCPmXWQAHrt-Q-1; Thu, 09 Nov 2023 22:27:10 -0500
X-MC-Unique: KQfrtO9lOCCPmXWQAHrt-Q-1
Received: by mail-pf1-f199.google.com with SMTP id d2e1a72fcca58-6bdc140103bso50290b3a.1
        for <linux-ia64@vger.kernel.org>; Thu, 09 Nov 2023 19:27:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699586829; x=1700191629;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=AaVo9IVfWLz/BqLc17ue4Q1CD1g0z57ZzeqlpNNIaz0=;
        b=Lb2ep1TdP5qFlNrt6VQ2CktV90syfc1HxunfUS7K4PoYPiJ+otqOpzXGq7Z4VJRV90
         xHLJZIW9yryo/OwX/E6GvpTj7kIAdPoyb5nWMjU4PfPekagwAZ6m4it3lFLgpeIRIH3L
         qAIwE3Z0R2mndD7yd9Y1uIcFs7l2cH3anjNJSpmVqh3lrvK57/sQTfTTbxm+67qQ835U
         RDmboN6K6iSFQF3qUfgUBq9E3OHAG+WTNuVVK2omo/T4YIhAOP0umsyrgk0zPiEOv12C
         HGb/zljcwGrfXnpBzEFs47fKnFVg1qq4lTc8vFEPeAXBGtkL9mGg77H0U2F6nkAWzRBc
         PYbw==
X-Gm-Message-State: AOJu0YxqgqSm1CripF7gyWJ1UM3vWbCSHP7VioaY1SmcufV9YwtSRfb4
        OmLEjE67+XzBbDVREgMKyYg22EDLhO6Xd50T6ZX/vDQsoLt8QLCH3JNr4zsUYRoObU9jTGpMph4
        KsfkacClDibyHQSd87TEtHQ==
X-Received: by 2002:a05:6a20:7d9b:b0:183:e7bb:591b with SMTP id v27-20020a056a207d9b00b00183e7bb591bmr7360656pzj.3.1699586829273;
        Thu, 09 Nov 2023 19:27:09 -0800 (PST)
X-Google-Smtp-Source: AGHT+IG+bD56KpX+FmB2BSMLL1SeOrK5m+loI6ihIPtQEVukH9L6DA0riRGJoTQywaV/bE7t1yJhWw==
X-Received: by 2002:a05:6a20:7d9b:b0:183:e7bb:591b with SMTP id v27-20020a056a207d9b00b00183e7bb591bmr7360636pzj.3.1699586828966;
        Thu, 09 Nov 2023 19:27:08 -0800 (PST)
Received: from [10.66.61.39] ([43.228.180.230])
        by smtp.gmail.com with ESMTPSA id ix22-20020a170902f81600b001b8a00d4f7asm4274245plb.9.2023.11.09.19.27.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 09 Nov 2023 19:27:08 -0800 (PST)
Message-ID: <b594e092-0002-61d8-fdb9-74fad2285245@redhat.com>
Date:   Fri, 10 Nov 2023 11:27:02 +0800
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.15.1
Subject: Re: [PATCH RFC 09/22] drivers: base: add arch_cpu_is_hotpluggable()
To:     "Russell King (Oracle)" <rmk+kernel@armlinux.org.uk>,
        linux-pm@vger.kernel.org, loongarch@lists.linux.dev,
        linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-riscv@lists.infradead.org, kvmarm@lists.linux.dev,
        x86@kernel.org, linux-csky@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-parisc@vger.kernel.org
Cc:     Salil Mehta <salil.mehta@huawei.com>,
        Jean-Philippe Brucker <jean-philippe@linaro.org>,
        jianyong.wu@arm.com, justin.he@arm.com,
        James Morse <james.morse@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Peter Zijlstra <peterz@infradead.org>
References: <ZUoRY33AAHMc5ThW@shell.armlinux.org.uk>
 <E1r0JLQ-00CTxK-Ln@rmk-PC.armlinux.org.uk>
Content-Language: en-US
From:   Shaoqin Huang <shahuang@redhat.com>
In-Reply-To: <E1r0JLQ-00CTxK-Ln@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org



On 11/7/23 18:30, Russell King (Oracle) wrote:
> The differences between architecture specific implementations of
> arch_register_cpu() are down to whether the CPU is hotpluggable or not.
> Rather than overriding the weak version of arch_register_cpu(), provide
> a function that can be used to provide this detail instead.
> 
> Signed-off-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>
Reviewed-by: Shaoqin Huang <shahuang@redhat.com>
> ---
>   drivers/base/cpu.c  | 11 ++++++++++-
>   include/linux/cpu.h |  1 +
>   2 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
> index 58bb86091b34..221ffbeb1c9b 100644
> --- a/drivers/base/cpu.c
> +++ b/drivers/base/cpu.c
> @@ -527,9 +527,18 @@ EXPORT_SYMBOL_GPL(cpu_is_hotpluggable);
>   #ifdef CONFIG_GENERIC_CPU_DEVICES
>   DEFINE_PER_CPU(struct cpu, cpu_devices);
>   
> +bool __weak arch_cpu_is_hotpluggable(int cpu)
> +{
> +	return false;
> +}
> +
>   int __weak arch_register_cpu(int cpu)
>   {
> -	return register_cpu(&per_cpu(cpu_devices, cpu), cpu);
> +	struct cpu *c = &per_cpu(cpu_devices, cpu);
> +
> +	c->hotpluggable = arch_cpu_is_hotpluggable(cpu);
> +
> +	return register_cpu(c, cpu);
>   }
>   
>   #ifdef CONFIG_HOTPLUG_CPU
> diff --git a/include/linux/cpu.h b/include/linux/cpu.h
> index 1e982d63eae8..dcb89c987164 100644
> --- a/include/linux/cpu.h
> +++ b/include/linux/cpu.h
> @@ -80,6 +80,7 @@ extern __printf(4, 5)
>   struct device *cpu_device_create(struct device *parent, void *drvdata,
>   				 const struct attribute_group **groups,
>   				 const char *fmt, ...);
> +extern bool arch_cpu_is_hotpluggable(int cpu);
>   extern int arch_register_cpu(int cpu);
>   extern void arch_unregister_cpu(int cpu);
>   #ifdef CONFIG_HOTPLUG_CPU

-- 
Shaoqin

