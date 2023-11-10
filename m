Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83A0FC4167B
	for <linux-ia64@archiver.kernel.org>; Fri, 10 Nov 2023 03:38:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1345845AbjKJDiR (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 9 Nov 2023 22:38:17 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46954 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234896AbjKJDiP (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 9 Nov 2023 22:38:15 -0500
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E61FC468F
        for <linux-ia64@vger.kernel.org>; Thu,  9 Nov 2023 19:37:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1699587445;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=pROeszy9ePncz4nZyjZpb065/8N1ucMk0OODbP+hams=;
        b=GF7PFWZyMW8P712ez37azl/DCqNiBiJVzwq/YcXWF3yr/Ea28AUcpKn+tQHCYi8CJROUkt
        8zo7tcrYIqPD0uiZ+C2iQT9YXhdSLPUJ5wbWGWsngDKO45N4/p/nFUMaVogxuO581/n/OM
        Us8s6hD9YPeyrw9MfN/KAQCs8Py5aWQ=
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com
 [209.85.167.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-161-jF_wk5RGNXmufV3pqPcwFQ-1; Thu, 09 Nov 2023 22:37:23 -0500
X-MC-Unique: jF_wk5RGNXmufV3pqPcwFQ-1
Received: by mail-oi1-f197.google.com with SMTP id 5614622812f47-3b2ec6de4e4so63835b6e.1
        for <linux-ia64@vger.kernel.org>; Thu, 09 Nov 2023 19:37:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699587442; x=1700192242;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=pROeszy9ePncz4nZyjZpb065/8N1ucMk0OODbP+hams=;
        b=pJJFjIRpbCL4kO3Dxz7uPueBh1wTNXgPL7W5PWxtic8mf2UQIUOrPcwOt70VjYca1C
         Nat9P4UcPoAAO5jB9FGThXSESdLQ6o1YaNsmDNrnvm1L6yx4zOVNWT6+FnGKxP0WUaUw
         79gwlNk0+L4NKCrxQpq2/Kml1YXxW2HGtQypyP2N+mZNtg1riOowumK24ANtj3ViJnTF
         dw6uI8z89jiqA8V9xd0dJs/QVIuTTpcVZ8ZrE1X7m0sgAcboAXTN1G5p+KRBRdWr+XEv
         EMRGkqrOXEI6QOEBWoYfeIZsecV+Ok3IbX289A9aGRUtlyj3ogA17SGML6v3O71whRNZ
         0P7Q==
X-Gm-Message-State: AOJu0Yx38NKblTgBYklVmwCelJ664G5c4OmxMU9kQRFxBYJBSaSRPS/k
        gtC+5HOD5FRqDo/QNmzI1h9lgSTBh/OxIXbun4fUi8/L/AHcv9wf6/mj8MCYTlrrmrPypUEabbt
        70qpax7ZqDoXg5okTw9QfHg==
X-Received: by 2002:a05:6808:199c:b0:3a9:e8e2:579d with SMTP id bj28-20020a056808199c00b003a9e8e2579dmr8276254oib.2.1699587442427;
        Thu, 09 Nov 2023 19:37:22 -0800 (PST)
X-Google-Smtp-Source: AGHT+IFPdXOyaUAzV6aldemEymWFIQu5uK8SS6EoZEeBtta4Ue7SEB3JH44cFaCIyyqf1iZkLKsTPg==
X-Received: by 2002:a05:6808:199c:b0:3a9:e8e2:579d with SMTP id bj28-20020a056808199c00b003a9e8e2579dmr8276228oib.2.1699587442206;
        Thu, 09 Nov 2023 19:37:22 -0800 (PST)
Received: from [10.66.61.39] ([43.228.180.230])
        by smtp.gmail.com with ESMTPSA id e8-20020a63d948000000b005a9b20408a7sm5370547pgj.23.2023.11.09.19.37.17
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 09 Nov 2023 19:37:21 -0800 (PST)
Message-ID: <fd78bb81-1f83-13a4-ec37-3fe0cd040ec0@redhat.com>
Date:   Fri, 10 Nov 2023 11:37:16 +0800
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.15.1
Subject: Re: [PATCH RFC 14/22] arm64: convert to arch_cpu_is_hotpluggable()
Content-Language: en-US
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
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will@kernel.org>
References: <ZUoRY33AAHMc5ThW@shell.armlinux.org.uk>
 <E1r0JLq-00CTxq-CF@rmk-PC.armlinux.org.uk>
From:   Shaoqin Huang <shahuang@redhat.com>
In-Reply-To: <E1r0JLq-00CTxq-CF@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org



On 11/7/23 18:30, Russell King (Oracle) wrote:
> Convert arm64 to use the arch_cpu_is_hotpluggable() helper rather than
> arch_register_cpu().
> 
> Signed-off-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>
Reviewed-by: Shaoqin Huang <shahuang@redhat.com>
> ---
>   arch/arm64/kernel/setup.c | 8 ++------
>   1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index 165bd2c0dd5a..42c690bb2d60 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -402,13 +402,9 @@ static inline bool cpu_can_disable(unsigned int cpu)
>   	return false;
>   }
>   
> -int arch_register_cpu(int num)
> +bool arch_cpu_is_hotpluggable(int num)
>   {
> -	struct cpu *cpu = &per_cpu(cpu_devices, num);
> -
> -	cpu->hotpluggable = cpu_can_disable(num);
> -
> -	return register_cpu(cpu, num);
> +	return cpu_can_disable(num);
>   }
>   
>   static void dump_kernel_offset(void)

-- 
Shaoqin

