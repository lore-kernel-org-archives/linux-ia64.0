Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29DFEC77B7A
	for <linux-ia64@archiver.kernel.org>; Tue, 30 May 2023 21:11:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230154AbjE3VLK (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 30 May 2023 17:11:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42048 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233157AbjE3VLK (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 30 May 2023 17:11:10 -0400
Received: from mail-qk1-x736.google.com (mail-qk1-x736.google.com [IPv6:2607:f8b0:4864:20::736])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 35730C0
        for <linux-ia64@vger.kernel.org>; Tue, 30 May 2023 14:11:09 -0700 (PDT)
Received: by mail-qk1-x736.google.com with SMTP id af79cd13be357-75b17b80834so524292285a.1
        for <linux-ia64@vger.kernel.org>; Tue, 30 May 2023 14:11:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linuxfoundation.org; s=google; t=1685481068; x=1688073068;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date:from:to
         :cc:subject:date:message-id:reply-to;
        bh=Xa+N49Nm2tVkLvxrUw1Evt8r7Fe+85kqP6q6OfZAaAI=;
        b=L409Jf3IOoTWO8LAB0cedEcoyFQhlGXJV3dDWBm3DZ5oS9I4A9kSgIYOnaxfc4sLG9
         CJ0M1DwqvxQQp465Cr9x9NWIEV6fL7lqIU90HbmMEbu9wt7x29HzSaJKvTeruDlvgXSF
         NfI5SU5ULa4HKktbC8eY0eAMCMXItXQCO5few=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1685481068; x=1688073068;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=Xa+N49Nm2tVkLvxrUw1Evt8r7Fe+85kqP6q6OfZAaAI=;
        b=fM2wQwtpRcHivToHlFnBSF0ssi6jEQFr+VuywF5IRXP/4I1rTuH+6TEBuCNsoU7xLp
         CmRIqwDhux5kEQZozuVdGShuBGLlBXYoWjxaFBC9BIUWAtImRcuE90adDqFfprigVWRe
         v2es8iUanobpYeYxwE9KNF474JOxv9MgWfQgiU4rpTm3DhyCar2/koCMbCZGzbpwq4BA
         WU7jcXai3BER1O09oljRRCcN+UVckAmuUmMdoQh3XLkdRZ59x0be3f6pbEi3Ce2ofe0G
         zFizGyGZZ0C5fj2mi6t25KpZ3slEdj2Nz0Su7P+TB+O5sEQO9SbZReZvl4Ugpa1YXetO
         92SQ==
X-Gm-Message-State: AC+VfDxt2vAKcMnzzADYZRQAbhvyJIKP9kXsgiZq1tzHDxg9+9Ha/Q2T
        B8DI1+GOeHDIQa8F007zec337w==
X-Google-Smtp-Source: ACHHUZ72ZYjmYa4iLIi/+OuzxDiJ+FjdOVWtwVrUGRS1JzqbqL5Oe0IaZaJfa5k5Cb63yUhBM41Ssw==
X-Received: by 2002:a37:a810:0:b0:75c:cc95:671 with SMTP id r16-20020a37a810000000b0075ccc950671mr2815275qke.26.1685481068311;
        Tue, 30 May 2023 14:11:08 -0700 (PDT)
Received: from meerkat.local (bras-base-mtrlpq5031w-grc-30-209-226-106-132.dsl.bell.ca. [209.226.106.132])
        by smtp.gmail.com with ESMTPSA id u22-20020a05620a121600b007579ff44f0dsm4403115qkj.124.2023.05.30.14.11.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 30 May 2023 14:11:07 -0700 (PDT)
Date:   Tue, 30 May 2023 17:11:06 -0400
From:   Konstantin Ryabitsev <konstantin@linuxfoundation.org>
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     Frank Scheiner <frank.scheiner@web.de>,
        Guenter Roeck <linux@roeck-us.net>,
        Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org,
        song@kernel.org, debian-ia64 <debian-ia64@lists.debian.org>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>,
        Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: Boot regression in Linux v6.4-rc3
Message-ID: <20230530-richly-vowed-cbd6d6@meerkat>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
 <ZHErssbUSbSznTVA@bombadil.infradead.org>
 <CAHk-=whuaCqh0RJk1F+SKqdEHPzANoVVP5OU=c9wgogVLCQTVQ@mail.gmail.com>
 <c4ef98ad-cc4e-2949-179d-7edbc3c2a1b5@web.de>
 <CAHk-=whv0Mr_Gnwbm00vi76oTTw16KviVhC33segbjjZbxOswA@mail.gmail.com>
 <20230530-purchase-amber-fa77ba@meerkat>
 <CAHk-=wh=mF941kP0DduTt91V+HSuTqBAU8pXp34wSn6DSMPmrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHk-=wh=mF941kP0DduTt91V+HSuTqBAU8pXp34wSn6DSMPmrQ@mail.gmail.com>
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org
Message-ID: <20230530211106.umcc9MqZWT6XSiZ-Ffn6i3PNMFs-cOO14xjHxH1SgLU@z>

On Tue, May 30, 2023 at 05:04:56PM -0400, Linus Torvalds wrote:
> On Tue, May 30, 2023 at 4:21 PM Konstantin Ryabitsev
> <konstantin@linuxfoundation.org> wrote:
> >
> > We only add things to lore when someone asks, and nobody's asked. :) I guess
> > I'll consider this an ask and put it on the radar.
> 
> Thanks. It would probably be good to see if there are any other
> vger.kernel.org lists with any appreciable traffic that aren't on
> lore.

Yes, that will auto-fix itself as we continue to migrate things over to
subspace ("new vger").

-K
