Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BDFCE20E1
	for <linux-ia64@vger.kernel.org>; Mon, 13 Nov 2023 00:04:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ULED0Udk"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4A7872102
	for <linux-ia64@vger.kernel.org>; Sun, 12 Nov 2023 16:04:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1699833856;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=M1WVqrzwlUh2mFk7/OXOeRxfOSDsmH8Tq2hZjVjJnnk=;
	b=ULED0UdkevXxnpA529ii6wMpCVsfN8KO7P6nj/NfqSRyTgrRXPxf1+HFa8aVupeZHx/uG8
	/HG1+S69vheKq+lRm84cXzO1vrkc3/XHKZxib1McgCTLqMesKaBEIXAaHDru4j7tjaYiUB
	g2lIIjgzwY/J18hOz6z/GadyCIqFTYk=
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com
 [209.85.210.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-248-rDfDqRe6PxqxmlTtMdXGFA-1; Sun, 12 Nov 2023 19:04:14 -0500
X-MC-Unique: rDfDqRe6PxqxmlTtMdXGFA-1
Received: by mail-pf1-f199.google.com with SMTP id d2e1a72fcca58-692bf04c548so3925192b3a.0
        for <linux-ia64@vger.kernel.org>; Sun, 12 Nov 2023 16:04:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699833854; x=1700438654;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=M1WVqrzwlUh2mFk7/OXOeRxfOSDsmH8Tq2hZjVjJnnk=;
        b=IPS9fgqi9i63a0gVFDGlWN0RcXkZMn5uGuvknupR7lu0nTF9nCCL6FrzXlodq75FN4
         iDIvm/jMQl0iFFBZwdzYQJB0exwImf3AUdnnFst16jGMyPVJPCUGFYYd5bPQSISvGcTl
         tqo02k4XNQGxo1mqeZ6bWeKDWtpaK6ku4dH8TdfJm+2toXNa/rptWBEHNenTzK96lhAW
         RUH16JXRUh/JDikVjDuZBeib0j7XKR80l1TSrW0GB5GG/cpsg7pAyLOWsF22mRTgqnWW
         YrFe/fJ8xsfmpXL9PvPhdoFpczOePdSUQs+tkWG98RmybPv/0EGtDVyKNXRYrOae/zlx
         ShCw==
X-Gm-Message-State: AOJu0Yx4VSmAHQVUpI6NfPHoNtGUCytmE59aIeoS2thThp1zzTtlaAhX
	B74DqrveN5v+qJuxWOQhRDTol39r8bbXoEnXfj3eQJ0dHHPpmge+mqC9tCDuJXgAb1UsKS9ixqJ
	sACmNqrcb0Tgs1XB4zPFszQ==
X-Received: by 2002:a05:6a20:4b17:b0:180:eef7:b3bf with SMTP id fp23-20020a056a204b1700b00180eef7b3bfmr2894317pzb.52.1699833853851;
        Sun, 12 Nov 2023 16:04:13 -0800 (PST)
X-Google-Smtp-Source: AGHT+IFVhoHB7vfaN82g5SuEmn8wzwgzjtloVlrEIKNxLO/QhN9bWo7fbjYF4amHORPXU4K9sObvCw==
X-Received: by 2002:a05:6a20:4b17:b0:180:eef7:b3bf with SMTP id fp23-20020a056a204b1700b00180eef7b3bfmr2894294pzb.52.1699833853518;
        Sun, 12 Nov 2023 16:04:13 -0800 (PST)
Received: from ?IPV6:2001:8003:e5b0:9f00:b890:3e54:96bb:2a15? ([2001:8003:e5b0:9f00:b890:3e54:96bb:2a15])
        by smtp.gmail.com with ESMTPSA id jj3-20020a170903048300b001cc29ffcd96sm3038705plb.192.2023.11.12.16.04.06
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 12 Nov 2023 16:04:13 -0800 (PST)
Message-ID: <cf5a08b3-c8f0-438e-a7ba-c34d684dac42@redhat.com>
Date: Mon, 13 Nov 2023 10:04:06 +1000
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC 01/22] arch_topology: Make
 register_cpu_capacity_sysctl() tolerant to late CPUs
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
 Sudeep Holla <sudeep.holla@arm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>
References: <ZUoRY33AAHMc5ThW@shell.armlinux.org.uk>
 <E1r0JKl-00CTwT-Hx@rmk-PC.armlinux.org.uk>
From: Gavin Shan <gshan@redhat.com>
In-Reply-To: <E1r0JKl-00CTwT-Hx@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11/7/23 20:29, Russell King (Oracle) wrote:
> From: James Morse <james.morse@arm.com>
> 
> register_cpu_capacity_sysctl() adds a property to sysfs that describes
> the CPUs capacity. This is done from a subsys_initcall() that assumes
> all possible CPUs are registered.
> 
> With CPU hotplug, possible CPUs aren't registered until they become
> present, (or for arm64 enabled). This leads to messages during boot:
> | register_cpu_capacity_sysctl: too early to get CPU1 device!
> and once these CPUs are added to the system, the file is missing.
> 
> Move this to a cpuhp callback, so that the file is created once
> CPUs are brought online. This covers CPUs that are added late by
> mechanisms like hotplug.
> One observable difference is the file is now missing for offline CPUs.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
> If the offline CPUs thing is a problem for the tools that consume
> this value, we'd need to move cpu_capacity to be part of cpu.c's
> common_cpu_attr_groups.
> ---
>   drivers/base/arch_topology.c | 38 ++++++++++++++++++++++++------------
>   1 file changed, 26 insertions(+), 12 deletions(-)
> 

Reviewed-by: Gavin Shan <gshan@redhat.com>

