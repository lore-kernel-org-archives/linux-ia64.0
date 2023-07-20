Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47E57EB64DD
	for <linux-ia64@archiver.kernel.org>; Thu, 20 Jul 2023 22:43:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229805AbjGTWnc (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 20 Jul 2023 18:43:32 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58224 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229528AbjGTWnc (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 20 Jul 2023 18:43:32 -0400
Received: from mail-pl1-x636.google.com (mail-pl1-x636.google.com [IPv6:2607:f8b0:4864:20::636])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8A6081999
        for <linux-ia64@vger.kernel.org>; Thu, 20 Jul 2023 15:43:30 -0700 (PDT)
Received: by mail-pl1-x636.google.com with SMTP id d9443c01a7336-1b89b0c73d7so2100545ad.1
        for <linux-ia64@vger.kernel.org>; Thu, 20 Jul 2023 15:43:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20221208.gappssmtp.com; s=20221208; t=1689893010; x=1690497810;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=pGDsx9JUlDCLhDdZVbcopj8CjB6LG6IiIotvewVMl9o=;
        b=FA/fj/kUmMI9qnrGjP/AyevZ7wIzc5Y6HId4Ujq6YwcwupRy9r/G1acmv7og8ek7b0
         RzxJa0mlxtfOyb+FllaztuHM2a0ZpRSaBazNsVbe+X96RwqgexFT9Na5/h8TFYKl0q99
         Qqp2WM6FXs47FRw/2P28o99leNG5K35kJjDmmo8U6MXUug4fP5A5UNUnGxkD3YUhSBWh
         wXffgooM+Ip6x+9yyv3two16hFYCqyju9fkU1/0Y9lZbK8VRQ8eCz5YsqyaV/27MUG3f
         hFeqOQngK/N/BQYEsIT9KTpdQ6F9HCv3pYQ/qT3/f3nQtSm3GCUX36AixJFxD9Olq2lo
         bEuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1689893010; x=1690497810;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=pGDsx9JUlDCLhDdZVbcopj8CjB6LG6IiIotvewVMl9o=;
        b=NjiDW6eIFbIBIbVoHCqw0JlFZLlTQEN6WHyOa94BVdYzo6wTzSTuHUvo8XmQcqK7Js
         ufrDrB3SqGuHEM/XAHQqLFeQCJXHr6jtMN/km0Lld4CJ1BaXfcnRpSTDc5fU0sFn/uBP
         PHgeW/SvopYkcEFTxjnvulfZqCYPmTSNXkwkOVGUhluWAF8daqxwMfFmpqeNBLsuAQnD
         Jgvj/+8GOMGaklMDYYWw1kY14RHwKj45gxwmUBMTI/4ES+BCfkPB8i8wm1MXRWkYjT8D
         +OKlrfDBSSP1t7jwazAsgSuqCWuKA+06VGe4l+P7UCGVlvuA4MUC4gxjeAukC3T7laNo
         h22w==
X-Gm-Message-State: ABy/qLZDl336YaDQRcG6jP0QKogVKRPW+ZX208X/cGZ/J1K3JfQydk1X
        uhDcw7jI/x22Wsjp8EwE7vbnIg==
X-Google-Smtp-Source: APBJJlHoa8ec9HN3ykeoK8eiQFOEhc3oipMxGFdCEH3M1e2J0t1+R/BHkks1oFQUCaFHKB3bxGOsKA==
X-Received: by 2002:a17:90a:4fe1:b0:263:f36e:d610 with SMTP id q88-20020a17090a4fe100b00263f36ed610mr103844pjh.0.1689893009991;
        Thu, 20 Jul 2023 15:43:29 -0700 (PDT)
Received: from [192.168.1.136] ([198.8.77.157])
        by smtp.gmail.com with ESMTPSA id 5-20020a17090a190500b0025bfda134ccsm1538673pjg.16.2023.07.20.15.43.28
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 20 Jul 2023 15:43:29 -0700 (PDT)
Message-ID: <6dfbaa5b-5894-bfc9-f9a9-09d019c335d9@kernel.dk>
Date:   Thu, 20 Jul 2023 16:43:28 -0600
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:102.0) Gecko/20100101
 Thunderbird/102.13.0
Subject: Re: [PATCH][RFC] io_uring: Fix io_uring_mmu_get_unmapped_area() for
 IA-64
Content-Language: en-US
To:     Helge Deller <deller@gmx.de>, io-uring@vger.kernel.org,
        linux-ia64@vger.kernel.org, matoro_mailinglist_kernel@matoro.tk,
        linux-parisc@vger.kernel.org
References: <ZLhTuTPecx2fGuH1@p100>
 <0a242157-6dd6-77fd-b218-52e3ba06e450@kernel.dk>
 <be208704-b312-f04d-4548-90853a638752@gmx.de>
From:   Jens Axboe <axboe@kernel.dk>
In-Reply-To: <be208704-b312-f04d-4548-90853a638752@gmx.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On 7/20/23 4:38?PM, Helge Deller wrote:
> On 7/21/23 00:30, Jens Axboe wrote:
>> On 7/19/23 3:20?PM, Helge Deller wrote:
>>> The io_uring testcase is broken on IA-64 since commit d808459b2e31
>>> ("io_uring: Adjust mapping wrt architecture aliasing requirements").
>>>
>>> The reason is, that this commit introduced an own architecture
>>> independend get_unmapped_area() search algorithm which doesn't suite the
>>> memory region requirements for IA-64.
>>>
>>> To avoid similar problems in the future it's better to switch back to
>>> the architecture-provided get_unmapped_area() function and adjust the
>>> needed input parameters before the call.  Additionally
>>> io_uring_mmu_get_unmapped_area() will now become easier to understand
>>> and maintain.
>>>
>>> This patch has been tested on physical IA-64 and PA-RISC machines,
>>> without any failures in the io_uring testcases. On PA-RISC the
>>> LTP mmmap testcases did not report any regressions either.
>>>
>>> I don't expect issues for other architectures, but it would be nice if
>>> this patch could be tested on other machines too.
>>
>> Any comments from the IA64 folks?
> 
> matoro tested it on ia64 at least...
> 
>> Helge, should this be split into three patches? One for hppa, one for
>> ia64, and then the io_uring one?
> 
> If we split up, I would prefer to split it into 2 patches: One for
> io_uring together with the hppa patch, since they should go in
> together.

OK, that makes sense. Want to spin a new version done like that?

> The ia64 patch is probably unrelated, and can go seperately. But there
> doesn't seem to be any ia64 maintainer...?

Yeah, not too worried about IA64, and matoro having tested it is great.

> Do you have a chance to test this patch on the other io_uring
> platforms, without applying it into your tree? I think some testing
> would be good.

Yep, I can run it on arm64 and x86-64 pretty easily. Will do so.

-- 
Jens Axboe

