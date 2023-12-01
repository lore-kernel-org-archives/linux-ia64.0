Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="MUwzZzuj"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F13C5172D
	for <linux-ia64@vger.kernel.org>; Thu, 30 Nov 2023 19:49:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1701402556;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=IO8CL2qjeIUr0LsYwreVkjK8516DQtyOeewHK7H786o=;
	b=MUwzZzuj76BvgwfhNB4ZwdMGzVE207iu/8lSntm1dg5KVHHNkD89lyjN1QhB7UNiaeT/Ek
	uyT5SuxzNaS6r+C57niqtXJ6Oi8/67Op8FwaKIsKtk05OYLWdQB9b3kDdCFLWi1n/bJa8L
	76qnFjdKqdngFw9DSwHHh2iFMdMzeYs=
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com
 [209.85.214.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-202-SYKnFHapPQqfGwP9Rfwk1g-1; Thu, 30 Nov 2023 22:49:13 -0500
X-MC-Unique: SYKnFHapPQqfGwP9Rfwk1g-1
Received: by mail-pl1-f198.google.com with SMTP id d9443c01a7336-1d04d286b5cso1717535ad.0
        for <linux-ia64@vger.kernel.org>; Thu, 30 Nov 2023 19:49:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1701402552; x=1702007352;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=IO8CL2qjeIUr0LsYwreVkjK8516DQtyOeewHK7H786o=;
        b=q0OGQM3rfw9kbJKyNON3BSuOWYVGEjq+1D1Gm5Pxw9HlK8Q9oVweGdRAjnbt3qWExO
         zXwP8GsDVQ2SxWp2vnDNejogcJEs1GAT+A7dn2swmPxqhEPuFUZ050TSRPczJvvsmQi1
         tH5SZLWjkbuEOlz9sP/HA+IRXQ9NH4n8TcEn/4cmPsgEQAFDVjfi3d+SR0XoP8NxmGR7
         Nm/8I9E/z5QE90JJawS3e9/TWM2pH9v2Iwb8CzTcTJqS105WtE9FsnMzvG9Ho9madGU1
         zWvStZyftWl5OGuWlXP8HS8ksMVuHZFYhMeYsSyvBZ7NfBHlkAKTK0OlTaDK5pwc6t6J
         OuqQ==
X-Gm-Message-State: AOJu0YyLssCSPhV30n2UpJVMKTHwiJPrxYdXCY2zL31Nugmlc+VEIJ30
	N5PGQhz68MeO9pChQaEK97QgWNM73NBg8piopyekbWAak618a0N6xK7ggHPJWUjr9lXHZPkp6KT
	Gi6nkk64yhkIOQGeCVEiBJg==
X-Received: by 2002:a17:902:e80e:b0:1cf:daca:2b5e with SMTP id u14-20020a170902e80e00b001cfdaca2b5emr17322855plg.38.1701402552346;
        Thu, 30 Nov 2023 19:49:12 -0800 (PST)
X-Google-Smtp-Source: AGHT+IHVVbr2zUe8qqYTBkmHgB1fO8oP/OS0GFEHLzxacC4remFDnJNuIkfv1IWdcQ4cpeu8xrZWrg==
X-Received: by 2002:a17:902:e80e:b0:1cf:daca:2b5e with SMTP id u14-20020a170902e80e00b001cfdaca2b5emr17322834plg.38.1701402551963;
        Thu, 30 Nov 2023 19:49:11 -0800 (PST)
Received: from [192.168.68.51] ([43.252.115.3])
        by smtp.gmail.com with ESMTPSA id p5-20020a170902e74500b001cfc1a593f7sm2185691plf.217.2023.11.30.19.49.03
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 30 Nov 2023 19:49:11 -0800 (PST)
Message-ID: <e0b38120-8b09-4695-974c-f3c3ef226f22@redhat.com>
Date: Fri, 1 Dec 2023 14:49:03 +1100
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 11/21] drivers: base: Print a warning instead of panic()
 when register_cpu() fails
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
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt
 <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>
References: <ZVyz/Ve5pPu8AWoA@shell.armlinux.org.uk>
 <E1r5R3W-00CszU-GM@rmk-PC.armlinux.org.uk>
From: Gavin Shan <gshan@redhat.com>
In-Reply-To: <E1r5R3W-00CszU-GM@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


On 11/22/23 00:44, Russell King (Oracle) wrote:
> From: James Morse <james.morse@arm.com>
> 
> loongarch, mips, parisc, riscv and sh all print a warning if
> register_cpu() returns an error. Architectures that use
> GENERIC_CPU_DEVICES call panic() instead.
> 
> Errors in this path indicate something is wrong with the firmware
> description of the platform, but the kernel is able to keep running.
> 
> Downgrade this to a warning to make it easier to debug this issue.
> 
> This will allow architectures that switching over to GENERIC_CPU_DEVICES
> to drop their warning, but keep the existing behaviour.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>
> Reviewed-by: Shaoqin Huang <shahuang@redhat.com>
> Signed-off-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>
> ---
>   drivers/base/cpu.c | 7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
> 

Reviewed-by: Gavin Shan <gshan@redhat.com>

