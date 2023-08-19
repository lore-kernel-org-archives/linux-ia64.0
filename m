Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA32FEE49B5
	for <linux-ia64@archiver.kernel.org>; Sun, 20 Aug 2023 00:34:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229659AbjHTAda (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Sat, 19 Aug 2023 20:33:30 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46916 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229743AbjHTAdF (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Sat, 19 Aug 2023 20:33:05 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1F72188CF4;
        Sat, 19 Aug 2023 16:34:04 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 5F26261A60;
        Sat, 19 Aug 2023 23:34:03 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 84FE2C433C8;
        Sat, 19 Aug 2023 23:34:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1692488042;
        bh=nIfDO5AJtyTcclk+tlfLVxSChbajrljmwnUClALdUiU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=iwhxDMVrzGufl+ixJQKMhyTnX23HBwjB6h5t1xAGlTU8wwL2WiNTgGnCcROe+OykL
         tF8d2Cr/akJbQv1jYHqQchg7Y99XZXP56OI5D0OCx9XzHmOTCoBcdHzIWJnfsTwNDA
         raw+RvcJMyha9xPI/46eXKXdIvTVop59G+EEW0BUYcCkqSdMqQYBA5/lptUafTNta5
         baHBu0m6pe/5uz3i5g8I6BtObpQsjwJW11Sd8iSG0fnwLfHORnrzD2XUGFeVO15zQm
         RZRHGtISyt1Tfc1UCZJ00scvKc1Mi8BsYTg2KrfEymLzMH5V8ZC6u+7/zwpFtsMism
         sU0fZl4rAV/ZQ==
From:   Masahiro Yamada <masahiroy@kernel.org>
To:     linux-kbuild@vger.kernel.org
Cc:     linux-arch@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>,
        linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 4/6] ia64: remove <asm/export.h>
Date:   Sun, 20 Aug 2023 08:33:51 +0900
Message-Id: <20230819233353.3683813-4-masahiroy@kernel.org>
X-Mailer: git-send-email 2.39.2
In-Reply-To: <20230819233353.3683813-1-masahiroy@kernel.org>
References: <20230819233353.3683813-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

All *.S files under arch/ia64/ have been converted to include
<linux/export.h> instead of <asm/export.h>.

Remove <asm/export.h>.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/ia64/include/asm/Kbuild | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 33733245f42b..aefae2efde9f 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -1,7 +1,6 @@
 # SPDX-License-Identifier: GPL-2.0
 generated-y += syscall_table.h
 generic-y += agp.h
-generic-y += export.h
 generic-y += kvm_para.h
 generic-y += mcs_spinlock.h
 generic-y += vtime.h
-- 
2.39.2

