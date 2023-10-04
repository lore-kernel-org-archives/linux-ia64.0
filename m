Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DCE0E7B5F9
	for <linux-ia64@archiver.kernel.org>; Wed,  4 Oct 2023 12:17:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233074AbjJDMR5 (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Wed, 4 Oct 2023 08:17:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:35024 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232919AbjJDMR4 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Wed, 4 Oct 2023 08:17:56 -0400
Received: from mout.web.de (mout.web.de [212.227.15.3])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BA93493
        for <linux-ia64@vger.kernel.org>; Wed,  4 Oct 2023 05:17:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de; s=s29768273;
 t=1696421853; x=1697026653; i=frank.scheiner@web.de;
 bh=o3YcWECC7To5sqAsciQfu9WRCdilGJM8VaEpi7v2CZY=;
 h=X-UI-Sender-Class:Date:To:From:Cc:Subject;
 b=qcY2sw0diUQANzh5oIhW7NTN0Lsu+4tLuqfKz5K+uedS44CtoqZeTtFy4hq3KSWZGRbVPw/IVFY
 CJ/QLRE4inwpb2+ufkFDhDJot62Y0K5MBQyFXHtE3wyvkra2GUPbod5F+dUF4hNhrwIjSygPuknWe
 q1sq0ajWH2kEl6uQB4dqXKDwHBZSwsizi0fyjcAyD1W+XmbKzyHJrQuNtuWY5o8wNa72chw/ipDMI
 zYIpFsq7CqfZL0sD4+YyT0BHL/35pSTPRggQgPcjxgNLXpK5tWLYicaFqB3eV4ejC4qhvCvXyN/V7
 xRn4bc+Fw6oIsm9uUCEj1xG2L3w7s/djzTiA==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([217.247.47.162]) by smtp.web.de (mrweb005
 [213.165.67.108]) with ESMTPSA (Nemesis) id 1MFauo-1qpgJP339S-00HTCa; Wed, 04
 Oct 2023 14:17:33 +0200
Message-ID: <cb4faf4f-1efc-5ae7-c8f7-7aad9c2a4d73@web.de>
Date:   Wed, 4 Oct 2023 14:17:32 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.15.1
To:     linux-ia64@vger.kernel.org
Content-Language: en-US
From:   Frank Scheiner <frank.scheiner@web.de>
Cc:     debian-ia64 <debian-ia64@lists.debian.org>, ia64@gentoo.org,
        =?UTF-8?B?VG9tw6HFoSBHbG96YXI=?= <tglozar@gmail.com>
Subject: Linux/ia64: Kernel testing effort
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:RhpsQvGrsohREKKpOwHKkS20X/wytVsZpryY+ukTupuZh7O1cuL
 v7sm4DzeyppMiWICsbUtLhJwk9RZDHtSEezl18foXqshF6klN8UmxLNdMtTkSCER5jFAMcl
 TJwZdAdrTl5Od0BkchNmdraU9ozyrZsUIMS7ALvbS7E9VDSZ2IG73nn/fZDm7cns+Va8K9H
 y+CgtvEewDnaMA86ANj7g==
UI-OutboundReport: notjunk:1;M01:P0:LX0T+E5Dm9o=;iVcixgkJF9nqfnYueLf3bkr35ki
 9Wfyb1qKFpeVZhwI7tvBCkJ2wG4LiBBDnGHlMiLETC8I+IuEX+o1Ygk08t5sCwKYJ9/gLSr+R
 ks53Lv4wdPrqVKydxFW3DSmxfRmOO1wnL5SOWwvfUbEOqtWfiPN46LcNFdvxICN8JAoQMp9zL
 qKPJwN9X1NF1mabFOSVcweKco2O0NRg+5GkzyYjEkgTd3FTFUDDmSqwt4z1ZJ5NGi6SDuUMsQ
 hWGj03hmERrETmWbv2wro9jNjE73qDGlPYZLAgn+OeFBrC3Ts8uPfPCA+4OtA1mMdFJ/LVF1u
 +TQsJckDY0CxHc1oNM21RmP9UbYTzTgOa5Mn0BfdagZNrBRyG2mzfuGChdObDhV4220L75zIM
 neHccA2O8V0WmefKJDFFHp/KFcTiV3fm3jp2jMi/5DHq9ZvZ0s0KFSDm6ZP8jYjNv2SPrDSUE
 HmBrxLpBL1w87n7LwxaOWI+JWeXgNgtzM35w0oz7iVhWty9acj7I7XG1AQT765y0bzxvLHBdg
 eEB9r7CHwDwQHrDV5mA3ZFEPdwZNVWgX4Ol9lMDCk8EmpuLAjow1Kul18HRnTpvr4KM7PNHsv
 5DkLf+eHkmPigsYM2E/5gfqtTHVcmpxbyBTn9jFve2wUtMda93mGiB5zc7vrIWYBpHowh6qHG
 Z+tPdyi0+OQz7yhSWH3Jw/0zdiFT6HtBU8Vc14830nP46HZAnaRTFCIe5SxARte6JX4kkwaLa
 2lG3MG8uZGu1e/HHPErvD4jpOQxR6ckLfWM0T1tRMWSkXGc5794WE3R71TotujoJ69ovEau4u
 tpxuVhZdnEQ7XxCrJYRaHh+GHFV77CTIMTHXapn81Tz69W8j79wuGPTwHyw+fCOw3oF6ifXZD
 sgogUK7c2pdc9lglfhV3VQfPSErzXwqvDVRO0BcBqzb6XPZ68QJhyfTogdT8iE+mFkv7E5e1W
 4D9ITn5eKfHA0VexhbFaNAKvBQI=
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Hi there,

as I usually only write to this list to report problems for ia64, I
thought it might be a good idea to also report a success story here.
Also in order to drive away any doubts about ia64 being a working
architecture for Linux.

This also goes CC to Debian's and Gentoo's respective ia64 lists.

In the past quarter or so (v6.4-rc7 to v6.6-rc4) I
"Build-n-Boot-to-login" tested nearly every RC and release version of
Linux (13 versions tested in total) on my Itanium zoo of machines, which
includes:

* rx2620 (w/2 x Montecito)
* rx4640 (w/2 x Madison)
* 2 x rx2660 (w/2 x Montecito, w/1 x Montvale)
* rx6600 (w/4 x Montvale)
* rx2800 i2 (w/1 x Tukwila)

...spanning multiple generations of Itanium hardware. And during that
timeframe I didn't face any major problems that affected all machines
and broke ia64 as a whole for Linux.

In short: Linux for ia64 continues to work on real machines.

I expect to continue this testing effort for the time being. It should
uncover all breakages that affect the mentioned hardware and my used
configuration.

This testing effort for example uncovered a boot problem for the rx6600
(not reproducible on any of the other machines, happens with SMT on and
off), which is now bisected and worked upon. Expect to hear about that
sometime in the future. I don't consider it a showstopper, as it only
affects this one machine, though I assume it might also affect a rx3600
(Gentoo has one) as this one is pretty similar to the rx6600 hardware-wise=
.

All information gathered during testing is documented on a private
website for now. If you're interested, please contact me directly off-list=
.

Cheers,
Frank
