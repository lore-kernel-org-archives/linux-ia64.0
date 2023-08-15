Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF688C04A6A
	for <linux-ia64@archiver.kernel.org>; Tue, 15 Aug 2023 07:43:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233691AbjHOHm2 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 15 Aug 2023 03:42:28 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57942 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232625AbjHOHlz (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 15 Aug 2023 03:41:55 -0400
Received: from mail-lj1-x231.google.com (mail-lj1-x231.google.com [IPv6:2a00:1450:4864:20::231])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3841A172C
        for <linux-ia64@vger.kernel.org>; Tue, 15 Aug 2023 00:41:54 -0700 (PDT)
Received: by mail-lj1-x231.google.com with SMTP id 38308e7fff4ca-2b9f48b6796so77734231fa.3
        for <linux-ia64@vger.kernel.org>; Tue, 15 Aug 2023 00:41:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1692085312; x=1692690112;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=ptPuBEpK+bTuLrHXWomcWZqL5q0T5IOC69Hvw3A95bI=;
        b=KiV7caJTECb9PUu5+oAo/V6w2dUO/5kFCBeqdA8GqO9YWrimpQ+rbRMheEl+tKhsVF
         yYgKNchWh1j5VNciYA/OwUNSBJU2NTJwJ+8GypxejFToD4sNzutpHnTPv6X1AFZZhaqS
         uWeaP2D2oZNGCMh1mXHUCRQ5SCq6jnfQ9rlh8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1692085312; x=1692690112;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=ptPuBEpK+bTuLrHXWomcWZqL5q0T5IOC69Hvw3A95bI=;
        b=Tfgzf0efYHiTbyEslZt7kUegkheV890i99GXYu9r2ZryVIYG6qzHuJfWKIfQ++xk5Y
         mELrYCl2WRJWTZj+jUnhnMRsg+yFmHijFOfC/nfLy+aPlqIONRKbUD/z1iSiICd44ghF
         Z9f2ZUe7AVWAGc8H8AH71/NDUCtT6WBIlEynrh/8CD+6vbyVbNJSMW162BYIVFFam2nX
         6kQVUUzMpS9M/raNrwbyFeVgaztLypd5iwTLJVSAQf4Dw1R8CpOoRNaksJTCF/Zr6PKD
         ucBUm+O0ykOlkxGipaCNLpS2vISq4Ic+E7jefuGkLiehgiafyfyGfFvJeHgE8xB+Zf8g
         gmjQ==
X-Gm-Message-State: AOJu0YwpuHP0sDa70LbRU0m8N5v+FG80y0KyTaEx8i/qHwtzwzxSCW8V
        j79/PH41yj8ledIBCL2/EYACGDdpTZWvQpu2KSFy1saE
X-Google-Smtp-Source: AGHT+IE7AC0TYxuK53dxtA64BL7LfnQplIcueHhA31VM7pYMpkfIUdY9tNBS+a2zMuJwqDcA8QDx+w==
X-Received: by 2002:a05:651c:234:b0:2b6:cdfb:d06a with SMTP id z20-20020a05651c023400b002b6cdfbd06amr9143322ljn.22.1692085312144;
        Tue, 15 Aug 2023 00:41:52 -0700 (PDT)
Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com. [209.85.167.45])
        by smtp.gmail.com with ESMTPSA id 8-20020a05651c00c800b002b6fe751b6esm2828914ljr.124.2023.08.15.00.41.51
        for <linux-ia64@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 15 Aug 2023 00:41:51 -0700 (PDT)
Received: by mail-lf1-f45.google.com with SMTP id 2adb3069b0e04-4fe2de785e7so8202266e87.1
        for <linux-ia64@vger.kernel.org>; Tue, 15 Aug 2023 00:41:51 -0700 (PDT)
X-Received: by 2002:a05:6402:290:b0:523:1004:1c9a with SMTP id
 l16-20020a056402029000b0052310041c9amr8202386edv.35.1692084833506; Tue, 15
 Aug 2023 00:33:53 -0700 (PDT)
MIME-Version: 1.0
References: <202308151426.97be5bd8-oliver.sang@intel.com>
In-Reply-To: <202308151426.97be5bd8-oliver.sang@intel.com>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue, 15 Aug 2023 07:33:36 +0000
X-Gmail-Original-Message-ID: <CAHk-=whbOEhPUL1m8Ua-+-E7kJXED4xa+duzRF-wJKR84NAPWg@mail.gmail.com>
Message-ID: <CAHk-=whbOEhPUL1m8Ua-+-E7kJXED4xa+duzRF-wJKR84NAPWg@mail.gmail.com>
Subject: Re: [linus:master] [locking] c8afaa1b0f: stress-ng.zero.ops_per_sec
 6.3% improvement
To:     kernel test robot <oliver.sang@intel.com>
Cc:     Mateusz Guzik <mjguzik@gmail.com>, oe-lkp@lists.linux.dev,
        lkp@intel.com, linux-kernel@vger.kernel.org,
        linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, ying.huang@intel.com,
        feng.tang@intel.com, fengwei.yin@intel.com
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On Tue, 15 Aug 2023 at 07:12, kernel test robot <oliver.sang@intel.com> wrote:
>
> kernel test robot noticed a 6.3% improvement of stress-ng.zero.ops_per_sec on:

WTF? That's ridiculous. Why would that even test new_inode() at all?
And why would it make any difference anyway to prefetch a new inode?
The 'zero' test claims to just read /dev/zero in a loop...

[ Goes looking ]

>      39.35            -0.3       39.09        perf-profile.calltrace.cycles-pp.inode_sb_list_add.new_inode.shmem_get_inode.__shmem_file_setup.shmem_zero_setup

Ahh. It also does the mmap side, and the shared case ends up always
creating a new inode.

And while the test only tests *reading* and the mmap is read-only, the
/dev/zero file descriptor was opened for writing too, for a different
part of a test.

So even though the mapping is never written to, MAYWRITE is set, and
so the /dev/zero mapping is done as a shared memory mapping and we
can't do it as just a private one.

That's kind of stupid and looks unintentional, but whatever.

End result: that benchmark ends up being at least partly (and a fairly
noticeable part) a shmem setup benchmark, for no actual good reason.

Oh well. I certainly don't mind the removal apparently then also
helping some odd benchmark case, but I don't think this translates to
anything real. Very random.

                    Linus
