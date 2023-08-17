Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64FDEC3DA5C
	for <linux-ia64@archiver.kernel.org>; Thu, 17 Aug 2023 16:54:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1352104AbjHQQxv (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 17 Aug 2023 12:53:51 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56848 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1351737AbjHQQx3 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 17 Aug 2023 12:53:29 -0400
Received: from mail-pg1-x52d.google.com (mail-pg1-x52d.google.com [IPv6:2607:f8b0:4864:20::52d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 09F81171F
        for <linux-ia64@vger.kernel.org>; Thu, 17 Aug 2023 09:53:28 -0700 (PDT)
Received: by mail-pg1-x52d.google.com with SMTP id 41be03b00d2f7-565439b6b3fso26813a12.2
        for <linux-ia64@vger.kernel.org>; Thu, 17 Aug 2023 09:53:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google; t=1692291207; x=1692896007;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
        bh=wd2eEJ8bKVLE4jt9D8MWLfi2bLdIG89C4XSDUA4XuM4=;
        b=mEGHcVfvJ1Ie/DKOGJ3cn4M75JEBivLZpO+OsJ8xCiLQ1GJQQMl36SlQjVy5cWWoaq
         QCelzu3Ao/JQ4pT9CBZGSIUuqXTpzHjc5tspYcUQlnZQeOLtgEczpE44hcHTy8fe+Cmp
         Ys7Fq1A1PBZe8vZ8xA4v38u9i5nGqrAggwr6Y=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1692291207; x=1692896007;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=wd2eEJ8bKVLE4jt9D8MWLfi2bLdIG89C4XSDUA4XuM4=;
        b=CFj7qY3VlgZQUuojWMaIBKxYST1xNiya24YpCHS0YwTDvcYQkgR9jQJzrBhvRyZh0i
         //5rfPzooiMNrevbuwQV0hwpOeIkKyMyfwBNCqGO8r6BYbVEc0nwJRp9ewPjf2wnqqZ/
         vLcAlo+Ak1I6PaAQ0ttc0ryXAKOG4IvIepSnhO5bgqubsTY0vmpf1PMLHTKoKE0lEP5d
         4RzEI5CEtSk6tK6cUYhe5vHDxZ6pq49abRhhREAX4TRBEaNJHTXl5RCHWCQa+lSQVtMN
         NpMsMYMg2WKtkRnkE1LG5PWpu8zTmPPrYGjfzDqtQoX/U/eZDXDFwgpgvtoVWEDFDFjc
         7gJw==
X-Gm-Message-State: AOJu0YwtsX38OJz6nQ9ZWEcL/F1tNxDEFTGLu6linwfZ4Ck9FRxw+je7
        R/wwBbXsEuVCvI7WLD6oIafIQQ==
X-Google-Smtp-Source: AGHT+IEBtVDJzAH7jjK/Tzl/XqL8sfAWLGYo2+wPKkU1O+/+nEh6rMeDF/flz5bgJyCIwogSa+XEHQ==
X-Received: by 2002:a05:6a20:3a83:b0:13e:b7e9:1a71 with SMTP id d3-20020a056a203a8300b0013eb7e91a71mr263073pzh.14.1692291207506;
        Thu, 17 Aug 2023 09:53:27 -0700 (PDT)
Received: from www.outflux.net (198-0-35-241-static.hfc.comcastbusiness.net. [198.0.35.241])
        by smtp.gmail.com with ESMTPSA id u8-20020aa78488000000b00687227dd8f1sm13085118pfn.122.2023.08.17.09.53.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 17 Aug 2023 09:53:26 -0700 (PDT)
Date:   Thu, 17 Aug 2023 09:53:26 -0700
From:   Kees Cook <keescook@chromium.org>
To:     Oleg Nesterov <oleg@redhat.com>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Jiri Slaby <jirislaby@kernel.org>,
        Christian Brauner <brauner@kernel.org>,
        linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] kill do_each_thread()
Message-ID: <202308170953.ECBAA9A@keescook>
References: <20230817163708.GA8248@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230817163708.GA8248@redhat.com>
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On Thu, Aug 17, 2023 at 06:37:08PM +0200, Oleg Nesterov wrote:
> Eric has pointed out that we still have 3 users of do_each_thread().
> Change them to use for_each_process_thread() and kill this helper.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
