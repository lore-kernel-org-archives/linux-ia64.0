Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE4B5EB64D8
	for <linux-ia64@archiver.kernel.org>; Tue, 13 Jun 2023 20:21:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240034AbjFMUVL (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 13 Jun 2023 16:21:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34320 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233084AbjFMUVK (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 13 Jun 2023 16:21:10 -0400
Received: from mail-pl1-x635.google.com (mail-pl1-x635.google.com [IPv6:2607:f8b0:4864:20::635])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1AC921989
        for <linux-ia64@vger.kernel.org>; Tue, 13 Jun 2023 13:21:07 -0700 (PDT)
Received: by mail-pl1-x635.google.com with SMTP id d9443c01a7336-1b3cc77ccbfso17091195ad.1
        for <linux-ia64@vger.kernel.org>; Tue, 13 Jun 2023 13:21:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google; t=1686687666; x=1689279666;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
        bh=xxCRqTUpCdcaL5d+zxoNNIGdAwVO5d6gYOiArNvEfDk=;
        b=MdG3P+8ihRjSOh7LybABvISRLscCMBxkCXrypPOlWdC+OtYj0yftCdz/uUj98Dw73e
         FhGLYHBT+mUIwYBKA7+2i75jw7j0RCQu7cApPRXOzrZZaHzRGXsKvoXhl03dGB8ouUuG
         /A5TFZGtg2AeZl6z7cZS08VFOGBVeakdEkhkM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1686687666; x=1689279666;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=xxCRqTUpCdcaL5d+zxoNNIGdAwVO5d6gYOiArNvEfDk=;
        b=Wu82mFQK1ApmaViRlMX79ty/gz9EPS3MfcPFxMZTYxpqh1eMy7oINuKINUWX04FGJK
         oqKWKmm1ZJ9LVs1K0jLbPEheNnbX8cPp/ukaHqmvW7bqHmQydCANxF5YtHyNFT8jv/M8
         ix77j7j4osZVUqV0vU1nh4BWvIqRSEkk31oQP0Dg907O2LAEOEvSRiNVY0bhhb4tQlr/
         kyieO8I62obtqesFHjrQK3yNgxzpHqGV97Pi2evSHEBdikVlmLJMquPdruZDj1kt+sYT
         5kdSfQtkJTiyGRReW/SYBdKr+iDFzk8fbdiOJZtKiAaVSj5JDcDkrx9xu32GvcAakOYX
         VZ7A==
X-Gm-Message-State: AC+VfDwLUaSQXAz3FfcwHrQ9rqU9WyGy8BWjm5W3ond+Hx0WF+Faz3d+
        YHIHru9e7jNXUWdAF8FJBAhZ+A==
X-Google-Smtp-Source: ACHHUZ4FjJE13zDDzcDgsWgBZwhdFAkpwfh7UQt9gQTWfr+WAlSvDzNOiSEYdsJRmv+1hwafinJSyA==
X-Received: by 2002:a17:902:8d8a:b0:1ad:e633:ee96 with SMTP id v10-20020a1709028d8a00b001ade633ee96mr8591788plo.55.1686687666576;
        Tue, 13 Jun 2023 13:21:06 -0700 (PDT)
Received: from www.outflux.net (198-0-35-241-static.hfc.comcastbusiness.net. [198.0.35.241])
        by smtp.gmail.com with ESMTPSA id p4-20020a1709026b8400b001b034d2e71csm10608371plk.34.2023.06.13.13.21.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Jun 2023 13:21:06 -0700 (PDT)
Date:   Tue, 13 Jun 2023 13:21:05 -0700
From:   Kees Cook <keescook@chromium.org>
To:     Eric DeVolder <eric.devolder@oracle.com>
Cc:     linux@armlinux.org.uk, catalin.marinas@arm.com, will@kernel.org,
        chenhuacai@kernel.org, geert@linux-m68k.org,
        tsbogend@alpha.franken.de, James.Bottomley@hansenpartnership.com,
        deller@gmx.de, ysato@users.sourceforge.jp, dalias@libc.org,
        glaubitz@physik.fu-berlin.de, tglx@linutronix.de, mingo@redhat.com,
        bp@alien8.de, dave.hansen@linux.intel.com, 86@kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-ia64@vger.kernel.org, loongarch@lists.linux.dev,
        linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
        linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, kernel@xen0n.name, mpe@ellerman.id.au,
        npiggin@gmail.com, christophe.leroy@csgroup.eu,
        paul.walmsley@sifive.com, palmer@dabbelt.com,
        aou@eecs.berkeley.edu, hca@linux.ibm.com, gor@linux.ibm.com,
        agordeev@linux.ibm.com, borntraeger@linux.ibm.com,
        svens@linux.ibm.com, hpa@zytor.com, paulmck@kernel.org,
        peterz@infradead.org, frederic@kernel.org,
        akpm@linux-foundation.org, ardb@kernel.org,
        samitolvanen@google.com, juerg.haefliger@canonical.com,
        arnd@arndb.de, rmk+kernel@armlinux.org.uk,
        linus.walleij@linaro.org, sebastian.reichel@collabora.com,
        rppt@kernel.org, kirill.shutemov@linux.intel.com,
        anshuman.khandual@arm.com, ziy@nvidia.com, masahiroy@kernel.org,
        ndesaulniers@google.com, mhiramat@kernel.org, ojeda@kernel.org,
        thunder.leizhen@huawei.com, xin3.li@intel.com, tj@kernel.org,
        gregkh@linuxfoundation.org, tsi@tuyoix.net, bhe@redhat.com,
        hbathini@linux.ibm.com, sourabhjain@linux.ibm.com,
        boris.ostrovsky@oracle.com, konrad.wilk@oracle.com
Subject: Re: [PATCH v1 00/21] refactor Kconfig to consolidate KEXEC and CRASH
 options
Message-ID: <202306131314.EFA558B7@keescook>
References: <20230612172805.681179-1-eric.devolder@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230612172805.681179-1-eric.devolder@oracle.com>
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On Mon, Jun 12, 2023 at 01:27:52PM -0400, Eric DeVolder wrote:
> The Kconfig is refactored to consolidate KEXEC and CRASH options from
> various arch/<arch>/Kconfig files into new file kernel/Kconfig.kexec.

This looks very nice!

> [...]
> - The boolean ARCH_HAS_<option> in effect allows the arch to determine
>   when the feature is allowed.  Archs which don't have the feature
>   simply do not provide the corresponding ARCH_HAS_<option>.
>   For each arch, where there previously were KEXEC and/or CRASH
>   options, these have been replaced with the corresponding boolean
>   ARCH_HAS_<option>, and an appropriate def_bool statement.
> 
>   For example, if the arch supports KEXEC_FILE, then the
>   ARCH_HAS_KEXEC_FILE simply has a 'def_bool y'. This permits the
>   KEXEC_FILE option to be available.
> 
>   If the arch has a 'depends on' statement in its original coding
>   of the option, then that expression becomes part of the def_bool
>   expression. For example, arm64 had:
> 
>   config KEXEC
>     depends on PM_SLEEP_SMP
> 
>   and in this solution, this converts to:
> 
>   config ARCH_HAS_KEXEC
>     def_bool PM_SLEEP_SMP
> 
> 
> - In order to account for the differences in the config coding for
>   the three common options, the ARCH_SUPPORTS_<option> is used.
>   This options has a 'depends on <option>' statement to couple it
>   to the main option, and from there can insert the differences
>   from the common option and the arch original coding of that option.
> 
>   For example, a few archs enable CRYPTO and CRYTPO_SHA256 for
>   KEXEC_FILE. These require a ARCH_SUPPORTS_KEXEC_FILE and
>   'select CRYPTO' and 'select CRYPTO_SHA256' statements.

Naming nit: "HAS" and "SUPPORTS" feel very similar, and looking at
existing configs, "ARCH_SUPPORTS_..." is already used for doing this
kind of bare "bool" management. e.g. see ARCH_SUPPORTS_INT128

It looks like you need to split "depends" and "select" so the options
can be chosen separately from the "selectable" configs.

How about naming this ARCH_SELECTS_<option>, since that's what it's
there for?

-Kees

-- 
Kees Cook
