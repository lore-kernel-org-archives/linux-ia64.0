Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="fAmVaU1q"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7FBFC10E5
	for <linux-ia64@vger.kernel.org>; Thu, 30 Nov 2023 19:48:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1701402523;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=/3AzxV0WgKZTUkZI9KNfIOtjrPxu2v3xdf2PUplwrRY=;
	b=fAmVaU1qLwGmSYFnif6OOQLTppkStrvz9HlB+dDY0FVN1DzUGN+rfk46fdUGhOZdsm6aua
	9gfLBi9A2KYYXO1BbDLJqa5HDkp3kveq3OY5y0t9TU2FgeFuTSJLEy7G6ApGvCp0bCsnVR
	OpifonJc6p5VOu46qy/dSkGbMDIIas4=
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com
 [209.85.214.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-614-ZjnRuFGFMiyCFaP30Q6ESw-1; Thu, 30 Nov 2023 22:48:42 -0500
X-MC-Unique: ZjnRuFGFMiyCFaP30Q6ESw-1
Received: by mail-pl1-f197.google.com with SMTP id d9443c01a7336-1cfcf1e9442so1553185ad.3
        for <linux-ia64@vger.kernel.org>; Thu, 30 Nov 2023 19:48:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1701402521; x=1702007321;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=/3AzxV0WgKZTUkZI9KNfIOtjrPxu2v3xdf2PUplwrRY=;
        b=YkCRsb41ap+jm52dvKRJqMvvqck/cgSPeJqC6DednUYXZZMOtZmPOcElZ7d16v0swZ
         KYRIRC+sTipnLRgKyV91v/yAWkqpxrYxKStzvDwhGsP9nL8o6ifDfOFhFrEWCK5m9Xse
         KgBPyROTMHazYMinxEQhM56qZgQLVjaiwAIDQo2B9qY3qDGA4vWctVlTM0B5P+aALCKQ
         B5IjsFkUYIjSrOnZAR9AeR1azA+WDuSY+f0Nno+gc525kFuNQOuFIwggQ0gCOhJYOS+m
         +yjXluWqwgX01qrrFtOGvmv+Xs2zOtplb96YIP0n2/Nj0LdEQwGIfrScijeWbcJh7ZQE
         H4rg==
X-Gm-Message-State: AOJu0YyiAG2VPubttxrf7p9yYaKLaQZWFVm6kcrFlQ8xJH/3G9MNUlDN
	EmJRNcTB6ZbyrGWdw2q/soVBNRlPEnQGYTKyeGj4uqjkvodYCaFmTgGE2miIx7KcqOCqqFtLknw
	UZn36jbG3865xpYaz1RzdnA==
X-Received: by 2002:a17:903:22cc:b0:1d0:1c45:fca6 with SMTP id y12-20020a17090322cc00b001d01c45fca6mr8848397plg.55.1701402521014;
        Thu, 30 Nov 2023 19:48:41 -0800 (PST)
X-Google-Smtp-Source: AGHT+IFPJHgKJ9VKrBg6ysMgalrHEAISDmXhJQ0ZqsSvXKSLoKD01csDbzaLvkOj/ql3EV9F3wt2Rw==
X-Received: by 2002:a17:903:22cc:b0:1d0:1c45:fca6 with SMTP id y12-20020a17090322cc00b001d01c45fca6mr8848375plg.55.1701402520729;
        Thu, 30 Nov 2023 19:48:40 -0800 (PST)
Received: from [192.168.68.51] ([43.252.115.3])
        by smtp.gmail.com with ESMTPSA id p5-20020a170902e74500b001cfc1a593f7sm2185691plf.217.2023.11.30.19.48.33
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 30 Nov 2023 19:48:40 -0800 (PST)
Message-ID: <86e58855-c5c9-42d0-b983-bf36a8b9b2b0@redhat.com>
Date: Fri, 1 Dec 2023 14:48:33 +1100
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 10/21] drivers: base: Move cpu_dev_init() after
 node_dev_init()
Content-Language: en-US
To: "Russell King (Oracle)" <rmk+kernel@armlinux.org.uk>,
 linux-pm@vger.kernel.org, loongarch@lists.linux.dev,
 linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-riscv@lists.infradead.org, kvmarm@lists.linux.dev, x86@kernel.org,
 linux-csky@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org
Cc: Salil Mehta <salil.mehta@huawei.com>,
 Jean-Philippe Brucker <jean-philippe@linaro.org>, jianyong.wu@arm.com,
 justin.he@arm.com, James Morse <james.morse@arm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>
References: <ZVyz/Ve5pPu8AWoA@shell.armlinux.org.uk>
 <E1r5R3R-00CszO-C0@rmk-PC.armlinux.org.uk>
From: Gavin Shan <gshan@redhat.com>
In-Reply-To: <E1r5R3R-00CszO-C0@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11/22/23 00:44, Russell King (Oracle) wrote:
> From: James Morse <james.morse@arm.com>
> 
> NUMA systems require the node descriptions to be ready before CPUs are
> registered. This is so that the node symlinks can be created in sysfs.
> 
> Currently no NUMA platform uses GENERIC_CPU_DEVICES, meaning that CPUs
> are registered by arch code, instead of cpu_dev_init().
> 
> Move cpu_dev_init() after node_dev_init() so that NUMA architectures
> can use GENERIC_CPU_DEVICES.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Signed-off-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>
> ---
> Note: Jonathan's comment still needs addressing - see
>    https://lore.kernel.org/r/20230914121612.00006ac7@Huawei.com
> ---
>   drivers/base/init.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

Reviewed-by: Gavin Shan <gshan@redhat.com>

