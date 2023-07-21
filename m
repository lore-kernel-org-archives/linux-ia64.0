Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5EF7C0015E
	for <linux-ia64@archiver.kernel.org>; Fri, 21 Jul 2023 15:42:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232111AbjGUPmE (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Fri, 21 Jul 2023 11:42:04 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43548 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231784AbjGUPmD (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Fri, 21 Jul 2023 11:42:03 -0400
Received: from mail-io1-xd35.google.com (mail-io1-xd35.google.com [IPv6:2607:f8b0:4864:20::d35])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3A92DE6F
        for <linux-ia64@vger.kernel.org>; Fri, 21 Jul 2023 08:42:02 -0700 (PDT)
Received: by mail-io1-xd35.google.com with SMTP id ca18e2360f4ac-785d3a53ed6so25348339f.1
        for <linux-ia64@vger.kernel.org>; Fri, 21 Jul 2023 08:42:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20221208.gappssmtp.com; s=20221208; t=1689954121; x=1690558921;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=QmE20XygINkFooGZCRYhmyeP1CJB0Q7rBQUncn12dzc=;
        b=fntMBIkkna4sH2FFnDW4WcmTJp0xd4jcYTxYtA+hatoUhkv0/crYIowIEji/QPa+Oj
         uAR0cBvS2EuK4QGQfPfsl7kQ0WokezMaJ3QCrdgXv1bzKwLR2K0GmX5ZSOi+Kjm6iolI
         mCfBoAp4FnldGun4T0ANsv3Xyk25+T0+o6RbW8Pin9MRLGL7fpNybD14RaDooOfHoRrN
         r+uPv9X6JxZhFxfg+l7lecWStktExVTX0fQsm92+qKfyxNY05POR5E/hJkctRixB/4Ix
         dTfetZ3g7Mh1K4jlqLozckMPskQBv+ZNKQdRFfjuW/uAsircCIJT9r0TsXCA9Nl+3gUd
         sPYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1689954121; x=1690558921;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=QmE20XygINkFooGZCRYhmyeP1CJB0Q7rBQUncn12dzc=;
        b=OTbtH3Mb52hkx1tXYyXBeDSND1dbcADdkrzcwV1JwQLuT+Tq7Skkg/CDDTOnsLiPhV
         KRnCowyl0KxVu10FcM/0UADpL+3Y+SZeKgOh5pZ6iGvZoxuyseATAa11N2BvmddWjtEj
         gEhFTw3xtIBqtQ8f2sMVy9G32mLftiez6n0N2ZjnyA0C8RKXlQXST8IFAidaCk+YwP0j
         CzaA8jkvSRczG2NSPt6K7pFtR5oOkqXFdTQwEFsfHdzeS9b/NWpVcM567KbTdpCj6Htr
         4a5MnKofD58iQNIZE9ISzfqNB2j41nxqLulHlSKEzps1uhSJ+aYroo4nP28V2n/ZaHFd
         7mag==
X-Gm-Message-State: ABy/qLbEcZ7sSH+HuCnMIKjb+8yOb+6W92MUAEwU0ryNNjLpguiGY+GX
        V6/ddMUonIexABfK9Qh9IWChiw==
X-Google-Smtp-Source: APBJJlE0rgR3hwgj21uTskJVG1R/lx3ngz4QGmAVE9MTa3kec+I1yAq7k9dYV/hZTYol+qztlb0sYw==
X-Received: by 2002:a92:d44c:0:b0:345:a3d0:f0d4 with SMTP id r12-20020a92d44c000000b00345a3d0f0d4mr2183115ilm.3.1689954121634;
        Fri, 21 Jul 2023 08:42:01 -0700 (PDT)
Received: from [192.168.1.94] ([96.43.243.2])
        by smtp.gmail.com with ESMTPSA id q11-20020a056e02078b00b0032afe23820bsm1029860ils.17.2023.07.21.08.42.00
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 21 Jul 2023 08:42:01 -0700 (PDT)
Message-ID: <1ad6ebe8-2f6b-6765-ccbf-4e931bc34351@kernel.dk>
Date:   Fri, 21 Jul 2023 09:42:00 -0600
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:102.0) Gecko/20100101
 Thunderbird/102.13.0
Subject: Re: [PATCH 0/2] io_uring: Fix io_uring mmap() by using
 architecture-provided get_unmapped_area()
Content-Language: en-US
To:     Helge Deller <deller@gmx.de>, linux-kernel@vger.kernel.org,
        io-uring@vger.kernel.org, linux-ia64@vger.kernel.org,
        Jiri Slaby <jirislaby@kernel.org>, linux-parisc@vger.kernel.org
References: <20230721152432.196382-1-deller@gmx.de>
From:   Jens Axboe <axboe@kernel.dk>
In-Reply-To: <20230721152432.196382-1-deller@gmx.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On 7/21/23 9:24?AM, Helge Deller wrote:
> Fix io_uring on IA64 (and x86-32?) which was broken since commit
> d808459b2e31 ("io_uring: Adjust mapping wrt architecture aliasing
> requirements").
> The fix is to switch back to the get_unmapped_area() which is provided by
> each architecture.
> 
> Patch 1 switches io_uring back to use per-arch get_unmapped_area().
> Patch 2 (for IA64) is an independend cleanup.

Let's get this queued up - I marked it for stable as well, for 6.4.
Thanks for taking care of this!

-- 
Jens Axboe

