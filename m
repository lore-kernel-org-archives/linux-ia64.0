Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12426C4167B
	for <linux-ia64@archiver.kernel.org>; Mon,  6 Nov 2023 13:24:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232489AbjKFNYE (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Mon, 6 Nov 2023 08:24:04 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48796 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232494AbjKFNYD (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Mon, 6 Nov 2023 08:24:03 -0500
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 37BD8112
        for <linux-ia64@vger.kernel.org>; Mon,  6 Nov 2023 05:24:01 -0800 (PST)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B0115C433CB;
        Mon,  6 Nov 2023 13:24:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
        s=korg; t=1699277040;
        bh=DTKRhjSleDTZk9eAUJM8sKYO/hlx2nMg5wzl/LS7Vkk=;
        h=Date:From:To:Subject:From;
        b=QO3ae7qPH738PS1A8moFBSRLhCtF+ggFJ8fcFzXVISu7IGdqup+Ciqbm9zrhIENtY
         tkvDsPIidL+RHG4Ae3iOJJ4RXY6ITMieNxid01dncU++wehrt/L+O6CLMbEyrZFM/F
         0cWeTINWl5iFZGTtCx2589qyw8tvJOKRXE+29jsU=
Date:   Mon, 6 Nov 2023 08:23:59 -0500
From:   Konstantin Ryabitsev <konstantin@linuxfoundation.org>
To:     linux-ia64@vger.kernel.org
Subject: PSA: migrating linux-ia64 to new vger infrastructure
Message-ID: <20231106-pronghorn-of-scientific-certainty-fb4c6f@nitro>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Good day!

I plan to migrate the linux-ia64@vger.kernel.org list to the new
infrastructure this week. We're still doing it list-by-list to make sure that
we don't run into scaling issues with the new infra.

The migration will be performed live and should not require any downtime.
There will be no changes to how anyone interacts with the list after
migration is completed, so no action is required on anyone's part.

Please let me know if you have any concerns.

Best wishes,
-K
