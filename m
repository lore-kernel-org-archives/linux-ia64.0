Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE7FEC158
	for <linux-ia64@vger.kernel.org>; Mon, 13 Nov 2023 04:07:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="E0dpLxbI"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1CAEB1980
	for <linux-ia64@vger.kernel.org>; Sun, 12 Nov 2023 20:07:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1699848468;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4vPpPFrFkMrzqnxNhFYjlLboUr7aR9ku5ew8hulbyck=;
	b=E0dpLxbI7R5BxBXHoIUwlquXQJXPu9mzaFo1AaAIuiH3eu3V/V/Z7tGFY8rcXTj8RMh638
	Cr2IWPNBN6p7cIFx6E+vyO+Q+I6pQmOUXrbpFllSOGPiuElCYouQUR2Y5qd2h/RAwWiN6J
	r36MGRwHg2IBJkareVBAaVREmfnW+Fs=
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com
 [209.85.214.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-534-TyGjpE_mNlGmjd-r9RayAg-1; Sun, 12 Nov 2023 23:07:46 -0500
X-MC-Unique: TyGjpE_mNlGmjd-r9RayAg-1
Received: by mail-pl1-f197.google.com with SMTP id d9443c01a7336-1cc391ca417so45467735ad.0
        for <linux-ia64@vger.kernel.org>; Sun, 12 Nov 2023 20:07:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699848465; x=1700453265;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=4vPpPFrFkMrzqnxNhFYjlLboUr7aR9ku5ew8hulbyck=;
        b=UBn1jkdvVJ6cvg3hKCMEd8yk611s+GhbabgJTqYp90l940eKu+xi/9HqDOmppY03Pp
         U44fPXVimB3sZwx8XW38zmfBfrqCJVF5tl5FuBEYFU1AvnO7PjV1LK2fW0O5VGtjS+H2
         iYYT5eDoHHfY6f+PeV1/4HAA5tct2k3HGA9IfgWmkoe9bX5c3gHnzdxRmVdq9qzXR1B/
         ZnUmyCs1aBOKWnJwF7J7P4AdfouPOvsSJU/5bfL40tMbJHm8OlUhZ7XfRQSQLoCdL2zC
         7RmFMYdSZLvGN8EmhE5+YLB5vnaB+RnH2vdqYXkeFr2bGdZvgLSYh+RLSrxxJ4al+8hs
         rsXA==
X-Gm-Message-State: AOJu0Yye1rwJmrzBBoOYHMFbpeVJ97mWOWjcf5q2d3B4LhXCW7QgrFCj
	ZJY/GZK975HzH2VNltOZBbTabNTP6O3lPeMVrnlXjMnodJ27iyms2Hp+WaS3C6XWxIM9m33s1IZ
	HdOi4fPWDaFOmEOd9FT5O5Q==
X-Received: by 2002:a17:903:18f:b0:1c9:b2c1:139c with SMTP id z15-20020a170903018f00b001c9b2c1139cmr7261836plg.62.1699848465408;
        Sun, 12 Nov 2023 20:07:45 -0800 (PST)
X-Google-Smtp-Source: AGHT+IHWMylLMVWpWug6Cxx/NC9nXPjOFm1HEloPQE99Sn7p/Alc1N4hJ0inQY3toOaSbmTdKDWFaA==
X-Received: by 2002:a17:903:18f:b0:1c9:b2c1:139c with SMTP id z15-20020a170903018f00b001c9b2c1139cmr7261816plg.62.1699848465098;
        Sun, 12 Nov 2023 20:07:45 -0800 (PST)
Received: from ?IPV6:2001:8003:e5b0:9f00:b890:3e54:96bb:2a15? ([2001:8003:e5b0:9f00:b890:3e54:96bb:2a15])
        by smtp.gmail.com with ESMTPSA id b1-20020a170903228100b001cc3098c9f8sm3225162plh.275.2023.11.12.20.07.38
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 12 Nov 2023 20:07:44 -0800 (PST)
Message-ID: <a6fe7a98-d215-4639-9949-b0044313681f@redhat.com>
Date: Mon, 13 Nov 2023 14:07:36 +1000
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC 13/22] arm64: setup: Switch over to
 GENERIC_CPU_DEVICES using arch_register_cpu()
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
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>
References: <ZUoRY33AAHMc5ThW@shell.armlinux.org.uk>
 <E1r0JLl-00CTxk-7O@rmk-PC.armlinux.org.uk>
From: Gavin Shan <gshan@redhat.com>
In-Reply-To: <E1r0JLl-00CTxk-7O@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11/7/23 20:30, Russell King (Oracle) wrote:
> From: James Morse <james.morse@arm.com>
> 
> To allow ACPI's _STA value to hide CPUs that are present, but not
> available to online right now due to VMM or firmware policy, the
> register_cpu() call needs to be made by the ACPI machinery when ACPI
> is in use. This allows it to hide CPUs that are unavailable from sysfs.
> 
> Switching to GENERIC_CPU_DEVICES is an intermediate step to allow all
> five ACPI architectures to be modified at once.
> 
> Switch over to GENERIC_CPU_DEVICES, and provide an arch_register_cpu()
> that populates the hotpluggable flag. arch_register_cpu() is also the
> interface the ACPI machinery expects.
> 
> The struct cpu in struct cpuinfo_arm64 is never used directly, remove
> it to use the one GENERIC_CPU_DEVICES provides.
> 
> This changes the CPUs visible in sysfs from possible to present, but
> on arm64 smp_prepare_cpus() ensures these are the same.
> 
> This patch also has the effect of moving the registration of CPUs from
> subsys to driver core initialisation, prior to any initcalls running.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>
> Signed-off-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>
> ---
> Changes since RFC v2:
>   * Add note about initialisation order change.
> ---
>   arch/arm64/Kconfig           |  1 +
>   arch/arm64/include/asm/cpu.h |  1 -
>   arch/arm64/kernel/setup.c    | 13 ++++---------
>   3 files changed, 5 insertions(+), 10 deletions(-)
> 

Reviewed-by: Gavin Shan <gshan@redhat.com>

