Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C7D3C4332F
	for <linux-ia64@archiver.kernel.org>; Thu,  2 Nov 2023 02:52:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1347265AbjKBCwd (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Wed, 1 Nov 2023 22:52:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33914 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1346830AbjKBCwc (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Wed, 1 Nov 2023 22:52:32 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BB6318E;
        Wed,  1 Nov 2023 19:52:22 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPS id 50695C433C8;
        Thu,  2 Nov 2023 02:51:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1698893495;
        bh=ZBAWtiIOYkdG9orUs68qxJWDX5OS0690ycLhXx3uc3E=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=mO18hbjoSnwscZYQf+y07XalR0Kcun8GFdPrShKQIKA/k44b1n2pCUTgRgFJLj3yn
         Ar1J81odWl74beQq875GF+OEsqfmN/eETCFlnf3/ZETo1c9sWF7QzsTEJht0/Rv3Zt
         kHdBqeI7TakLlBpBihcQGooruQzZzWKpbbcjsGYei3UDDRcD9D5KFCJx30Fmbbnl42
         yIIBmvBY9BLolinDRlHI9A3+3zHHdCpNW2RsPNA6QrC4siPpGONQrXLkE0HjOc/aat
         1EOhW6oTZKg0HxFIyBuZknIIILI+yRna/FFdLjEHOLc8u3xAgnNegQbkWEfMA97Srl
         kAo8c1+ZSCu2Q==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
        by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 3F9EBC4316B;
        Thu,  2 Nov 2023 02:51:35 +0000 (UTC)
Subject: Re: [GIT PULL] asm-generic updates for v6.7
From:   pr-tracker-bot@kernel.org
In-Reply-To: <340fc037-c18f-417f-8aaa-9cf88c9052f4@app.fastmail.com>
References: <340fc037-c18f-417f-8aaa-9cf88c9052f4@app.fastmail.com>
X-PR-Tracked-List-Id: <linux-ia64.vger.kernel.org>
X-PR-Tracked-Message-Id: <340fc037-c18f-417f-8aaa-9cf88c9052f4@app.fastmail.com>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/arnd/asm-generic.git tags/asm-generic-6.7
X-PR-Tracked-Commit-Id: 550087a0ba91eb001c139f563a193b1e9ef5a8dd
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 1e0c505e13162a2abe7c984309cfe2ae976b428d
Message-Id: <169889349525.17707.3659637299446006728.pr-tracker-bot@kernel.org>
Date:   Thu, 02 Nov 2023 02:51:35 +0000
To:     Arnd Bergmann <arnd@arndb.de>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux-Arch <linux-arch@vger.kernel.org>,
        linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
        Ard Biesheuvel <ardb@kernel.org>
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

The pull request you sent on Thu, 02 Nov 2023 00:50:30 +0100:

> https://git.kernel.org/pub/scm/linux/kernel/git/arnd/asm-generic.git tags/asm-generic-6.7

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/1e0c505e13162a2abe7c984309cfe2ae976b428d

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
