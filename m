Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C678AC8DB
	for <linux-ia64@vger.kernel.org>; Mon, 13 Nov 2023 04:13:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="OZL+WGrb"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0E42C1732
	for <linux-ia64@vger.kernel.org>; Sun, 12 Nov 2023 20:13:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1699848795;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=OYixRZav3C3iBpUpIpT8jXDG1/jkmr5ugIcaaWqfvjU=;
	b=OZL+WGrbv969y30HAdb6ZGh2Spj2zw7VPcYnuDt+GtZSosvui9Wukg+zhlNL6J/+FTdzUA
	L+plwWv734GyM+m5HWbmb9/izkNiN8QUKcAZbq9vU+LG4E4YVcYr0enVwKsBxRosTErF2v
	CmeA65Mjm9R51/eG3EB5U1oi1i1PfN4=
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com
 [209.85.214.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-464-KbilS5CAOfafKm9O4EQ9FQ-1; Sun, 12 Nov 2023 23:13:13 -0500
X-MC-Unique: KbilS5CAOfafKm9O4EQ9FQ-1
Received: by mail-pl1-f197.google.com with SMTP id d9443c01a7336-1ccdf149e60so38938325ad.0
        for <linux-ia64@vger.kernel.org>; Sun, 12 Nov 2023 20:13:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699848793; x=1700453593;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=OYixRZav3C3iBpUpIpT8jXDG1/jkmr5ugIcaaWqfvjU=;
        b=tFpxk/QwvIx/sPh/BLqN0YI8p0QJ+ZwHC0Xc9ho5dfSnAPP4XXPw25Lu8D0ck+RGFY
         A+fWDt442w+aCexPnrLGTJX1dCAZ2MU9Z40YIu4kApc08xPVB6tHKQAzIawhqxGSx7/j
         oY3fOvUm0mJ8VU9mI/xsbfCxi7VVVXcW3LEYmkc9A9PxejOR7c5kYmLcxFfj8aqEoB/J
         /pA0veBkfJTQds1Gy8R60oTmv5WLdnejlocazRbCX7KDk4knPqhOKd42GVmIZ19y/7uS
         By5a0cuAZORXUMOwtcwvDX61ZqF2HsZHNoM9no9Qz0HGWPduBK9n4mjM3ENvOEZawXaq
         ieAQ==
X-Gm-Message-State: AOJu0Yzy2JLbP69l1f5mQuld6lEHdp2l4TCGczk0f/JyjFZlLK67m9z5
	PSf3/L2HuQaWwgIatYy5FafIZFD24PINn4I3daAerIzQi6iOSH3dvvzEtRAdZxDIxcSEdY3sdgp
	fVOIjOXdLoQAuYvvJaOyiyw==
X-Received: by 2002:a17:903:41cd:b0:1cc:6fa6:ab62 with SMTP id u13-20020a17090341cd00b001cc6fa6ab62mr4016461ple.29.1699848792639;
        Sun, 12 Nov 2023 20:13:12 -0800 (PST)
X-Google-Smtp-Source: AGHT+IFeVOFMA0QCBZizKA9tBYcgAmzTI5mhR1cqxGbQYoi32/jpLTsg/y/gXt+4vuBSLdXi2pW82A==
X-Received: by 2002:a17:903:41cd:b0:1cc:6fa6:ab62 with SMTP id u13-20020a17090341cd00b001cc6fa6ab62mr4016447ple.29.1699848792330;
        Sun, 12 Nov 2023 20:13:12 -0800 (PST)
Received: from ?IPV6:2001:8003:e5b0:9f00:b890:3e54:96bb:2a15? ([2001:8003:e5b0:9f00:b890:3e54:96bb:2a15])
        by smtp.gmail.com with ESMTPSA id 6-20020a170902c10600b001cc41059a11sm3227272pli.196.2023.11.12.20.13.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 12 Nov 2023 20:13:12 -0800 (PST)
Message-ID: <9890d7b5-a51b-4556-bd20-96b617e6b880@redhat.com>
Date: Mon, 13 Nov 2023 14:13:02 +1000
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC 15/22] x86/topology: Switch over to
 GENERIC_CPU_DEVICES
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
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>,
 "H. Peter Anvin" <hpa@zytor.com>
References: <ZUoRY33AAHMc5ThW@shell.armlinux.org.uk>
 <E1r0JLv-00CTy1-Gq@rmk-PC.armlinux.org.uk>
From: Gavin Shan <gshan@redhat.com>
In-Reply-To: <E1r0JLv-00CTy1-Gq@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11/7/23 20:30, Russell King (Oracle) wrote:
> From: James Morse <james.morse@arm.com>
> 
> Now that GENERIC_CPU_DEVICES calls arch_register_cpu(), which can be
> overridden by the arch code, switch over to this to allow common code
> to choose when the register_cpu() call is made.
> 
> x86's struct cpus come from struct x86_cpu, which has no other members
> or users. Remove this and use the version defined by common code.
> 
> This is an intermediate step to the logic being moved to drivers/acpi,
> where GENERIC_CPU_DEVICES will do the work when booting with acpi=off.
> 
> This patch also has the effect of moving the registration of CPUs from
> subsys to driver core initialisation, prior to any initcalls running.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Signed-off-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>
> ----
> Changes since RFC:
>   * Fixed the second copy of arch_register_cpu() used for non-hotplug
> Changes since RFC v2:
>   * Remove duplicate of the weak generic arch_register_cpu(), spotted
>     by Jonathan Cameron. Add note about initialisation order change.
> Changes since RFC v3:
>   * Adapt to removal of EXPORT_SYMBOL()s
> ---
>   arch/x86/Kconfig           |  1 +
>   arch/x86/include/asm/cpu.h |  4 ----
>   arch/x86/kernel/topology.c | 27 ++++-----------------------
>   3 files changed, 5 insertions(+), 27 deletions(-)
> 

Reviewed-by: Gavin Shan <gshan@redhat.com>

