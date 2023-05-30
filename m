Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B726EC7EE23
	for <linux-ia64@archiver.kernel.org>; Tue, 30 May 2023 21:05:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231437AbjE3VFS (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 30 May 2023 17:05:18 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40798 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229945AbjE3VFR (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 30 May 2023 17:05:17 -0400
Received: from mail-ej1-x62d.google.com (mail-ej1-x62d.google.com [IPv6:2a00:1450:4864:20::62d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 28F7B99
        for <linux-ia64@vger.kernel.org>; Tue, 30 May 2023 14:05:16 -0700 (PDT)
Received: by mail-ej1-x62d.google.com with SMTP id a640c23a62f3a-96f9cfa7eddso865311566b.2
        for <linux-ia64@vger.kernel.org>; Tue, 30 May 2023 14:05:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1685480714; x=1688072714;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=zY6UmhhMULE6fnGgyGaQgHHKyvRlJ5+KHuIjScp6VCc=;
        b=QgoRuVbWdKAVUDTUtGNcVdGkopKLlYxzfKAbUR56A2LJ+qfSEWSDkKvZRlO9+x9iYg
         koE03okoUhfbHUsmZt4dJB5e2vLKR/Mk9tT7Utxb6oL8nRX2LJYjA51SuC0cYPRsTGdR
         zkc5B5N0A17BKvGFJUlJNPGxgltt7Eoyw2Q6M=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1685480714; x=1688072714;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=zY6UmhhMULE6fnGgyGaQgHHKyvRlJ5+KHuIjScp6VCc=;
        b=CLMHuRzC9B6kjDuX4GN0M/GiTWgGrivR6i4rrBiusKhG0ZM/R32RHzd9YI/qjje7yh
         fykg5OnObEmCNqY3LDIWkLnxKsSvZuEHIYRQ9gxM0gas62RtDyCg2kNht/jAUnzka2GT
         TG8txPMYmSJ4aw8n+bV440/ii/BTzhIKCshuk+Eii25eftr9ezzqXfYWJWifxPhkFVP7
         lhivivgM2sGRMdZe5FaURmK5h5pMnwP6p7NvatOTiN//CfAzu5jrxOknZswTTL/zxC5e
         iIFFdjpTuUvOcaINCb7uAewisLjC0ST1ddjQyB03b7phxMESXY3UPXA5HCUU9lSAtIsK
         mZeQ==
X-Gm-Message-State: AC+VfDzNi2FwZCwQ5unuJRSVk+DHE7FjshaMcegFZhQlIhz3Ct8DDyGf
        Dgst5lGvQ4aqsGIua2VdnYzLuFCs0D6tlQwAtRcwIwOW
X-Google-Smtp-Source: ACHHUZ7oVCoHTTNZAgagMXJVaYbp79UA91JwBGWZW+daogQoep8JyJwhFIyvnGmS7+I6mNDPziaB7A==
X-Received: by 2002:a17:907:c0c:b0:93b:5f2:36c with SMTP id ga12-20020a1709070c0c00b0093b05f2036cmr3973309ejc.61.1685480714500;
        Tue, 30 May 2023 14:05:14 -0700 (PDT)
Received: from mail-ej1-f44.google.com (mail-ej1-f44.google.com. [209.85.218.44])
        by smtp.gmail.com with ESMTPSA id lr7-20020a170906fb8700b009659fed3612sm7793977ejb.24.2023.05.30.14.05.13
        for <linux-ia64@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 30 May 2023 14:05:13 -0700 (PDT)
Received: by mail-ej1-f44.google.com with SMTP id a640c23a62f3a-96fe2a1db26so867724766b.0
        for <linux-ia64@vger.kernel.org>; Tue, 30 May 2023 14:05:13 -0700 (PDT)
X-Received: by 2002:a17:907:6e27:b0:973:e784:1fe with SMTP id
 sd39-20020a1709076e2700b00973e78401femr3636633ejc.24.1685480713354; Tue, 30
 May 2023 14:05:13 -0700 (PDT)
MIME-Version: 1.0
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de> <ZHErssbUSbSznTVA@bombadil.infradead.org>
 <CAHk-=whuaCqh0RJk1F+SKqdEHPzANoVVP5OU=c9wgogVLCQTVQ@mail.gmail.com>
 <c4ef98ad-cc4e-2949-179d-7edbc3c2a1b5@web.de> <CAHk-=whv0Mr_Gnwbm00vi76oTTw16KviVhC33segbjjZbxOswA@mail.gmail.com>
 <20230530-purchase-amber-fa77ba@meerkat>
In-Reply-To: <20230530-purchase-amber-fa77ba@meerkat>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue, 30 May 2023 17:04:56 -0400
X-Gmail-Original-Message-ID: <CAHk-=wh=mF941kP0DduTt91V+HSuTqBAU8pXp34wSn6DSMPmrQ@mail.gmail.com>
Message-ID: <CAHk-=wh=mF941kP0DduTt91V+HSuTqBAU8pXp34wSn6DSMPmrQ@mail.gmail.com>
Subject: Re: Boot regression in Linux v6.4-rc3
To:     Konstantin Ryabitsev <konstantin@linuxfoundation.org>
Cc:     Frank Scheiner <frank.scheiner@web.de>,
        Guenter Roeck <linux@roeck-us.net>,
        Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org,
        song@kernel.org, debian-ia64 <debian-ia64@lists.debian.org>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>,
        Luis Chamberlain <mcgrof@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org
Message-ID: <20230530210456.lRkuifwvGppEo_qyEtaxHkoLzpWVdcs_SIZCTTojPD8@z>

On Tue, May 30, 2023 at 4:21=E2=80=AFPM Konstantin Ryabitsev
<konstantin@linuxfoundation.org> wrote:
>
> We only add things to lore when someone asks, and nobody's asked. :) I gu=
ess
> I'll consider this an ask and put it on the radar.

Thanks. It would probably be good to see if there are any other
vger.kernel.org lists with any appreciable traffic that aren't on
lore.

               Linus
