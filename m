Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7FB2CDB474
	for <linux-ia64@archiver.kernel.org>; Tue, 17 Oct 2023 15:21:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1344302AbjJQPVv (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 17 Oct 2023 11:21:51 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51546 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1344325AbjJQPVu (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 17 Oct 2023 11:21:50 -0400
Received: from mout.web.de (mout.web.de [212.227.15.3])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BEF7310C
        for <linux-ia64@vger.kernel.org>; Tue, 17 Oct 2023 08:21:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de; s=s29768273;
        t=1697556086; x=1698160886; i=frank.scheiner@web.de;
        bh=1CSl67BQYf7aAzTML7j89+wdZx0BHKDlU0Mq6uAlIu4=;
        h=X-UI-Sender-Class:Date:From:Subject:Cc:To;
        b=RZJY0qh6w55HHXjOSkxy8R90tLUib55R9WXjpq+YznnCQPYc3ouN+Sbh1Nb53jQV
         jkMXOkE9OjK7+LVUXKseeEr/MZYjZ1EQOpAjwnWRGZhZVCYg0ma9cQrrk2ztf67kk
         +0Ftmsr9riBL/Ylc4Y5S2OgCoK7mT0t7ok37vjs+qKl5xvAvds4bxu9JGfADVWGXX
         F17/eWCxE5qynemAhqo9RDvVW8nnRKUWXCbHClh6TxXS2TJrIOey6aAPVrTt4ihbO
         EINQcD+VBLWcA1gny0hC14UWq/ldLnho8MBW2ek+Ju1vGX59O5EgRI8+54/ANBQq4
         6rZorUcJNekfZfzYVQ==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([87.155.236.78]) by smtp.web.de (mrweb005
 [213.165.67.108]) with ESMTPSA (Nemesis) id 1MFauo-1qkVTP3uQg-00H830; Tue, 17
 Oct 2023 17:21:26 +0200
Message-ID: <87cbede6-a1fe-4d66-9156-df92c51e132f@web.de>
Date:   Tue, 17 Oct 2023 17:21:24 +0200
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US
From:   Frank Scheiner <frank.scheiner@web.de>
Subject: Linux/ia64: An update
Cc:     =?UTF-8?B?VG9tw6HFoSBHbG96YXI=?= <tglozar@gmail.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        aurel32@debian.org, debian-ia64 <debian-ia64@lists.debian.org>,
        ia64@gentoo.org
To:     linux-ia64@vger.kernel.org
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:kNFjR9VnW8wFoMbjhNqz/N/GEG3Hhc+8XTVA66gTU9G1q1NVneK
 brd4fniZnFkj/uO8eg/3qoTmHUgiOYDzTgOk1WjbwyF4PTbV0xFC8jzcac6jv4/NdmVsLGe
 zmLxf+iTysWit2wmUoAhDhrYp6mtNE4iFhoNPALWdV6qVeT3YPcLE/9gDMnS8rccyGydWOr
 dFGO/95ojZ/dZO2zonUqQ==
UI-OutboundReport: notjunk:1;M01:P0:RA4p2CswWdg=;QNqfvSdVuXGfzKyvHIQx51Dszfy
 zHflvIp27U2RDwdC8oQOhyWK67s278zvUhAhEuBeLEQvzRIMrZ3+o/yk40dmfCv3b8b6tio8o
 ERgWc1SJmBtl+ieYtH7CYZm5pkuXkkJ4YWWzRJjx2GFGbnWM9tocS+S3IVUIWMbFCRARnlCJa
 0tIiVfVL5gGT8oNbfSdpjTMolu5CiJOOnAVItymjh1Rd92KPmkSOIor6zEeHsq7GS5L9iZhHz
 duOUBByino6ZvDFMGza5vYw+0AO50TnWwNstHQ8M7HorSJwNfjZonQAU8dD9h+XPmgWjwC3sM
 G631MHhVix8M/H8cZCpaETN0jvMryCYvJBZOzABF1SRbHxknP4YgQTfcGVI6lbLrP03+ffDJa
 Tgnwz+1sL9M83C6N3sQRCY0d+SUqiNLaANE2XiGcsllpf8z5ODEbcYMp/8xQ6qJlBW44pWQjE
 +3WIrvC/j9EGfNV7BIZhxFOzMIIEIcqllQhXQK1subbbuSFMJSfLjzdpVFnAmDz6cSE0hW1US
 SAeItDwf6q8G0nOIPkUpWJts7mZt1nYkQw4klRzMNAloWGexbVjHWcWWuXQ8YVychasfrDDKy
 Em9cEJQfzW3VcJdqg9CJpRlulI1/8TkGOwOUfDlyLSE3aZJx6cGLAOYTJhl3ZRX4hkWJL5v8E
 T8A09JtvZyAU44kjOhDAwBfjXjLXqTm5g6aWfZyY5VqgIaO0W2HsQXcOaBzvwdIHprA/m/Kaj
 w+tSPSBKOKmlpto7aiHZAizsKEvcOWvupk4TaktWjw5hR1C/Ref9EBWMCa9I8jhEcnoBOwtyL
 Ai7Cwh8EEt3LKGcw2l5TXR5dQsyF4GE6Q3FJMCWS9rJKORiheQWwKJFxfx3R17L2wPGbxsw2y
 M5isn9Qao3U6fT54HWeuEVW6ijEhPJrILqGDT25tvrq+8PYIzAR1uDSJvxwYqA21BtzqUd0XS
 PxjbbGlgvlzxGz1Kpqd2LKjKteI=
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Dear all,

consider this an update to [1].

[1]:
https://lore.kernel.org/linux-ia64/cb4faf4f-1efc-5ae7-c8f7-7aad9c2a4d73@we=
b.de/T/#u

So about two weeks later and another two v6.6 release candidates (5 and
6) tested successfully on the following machines:

* rx2620 (w/2 x Montecito)
* rx4640 (w/2 x Madison)
* 2 x rx2660 (w/2 x Montecito, w/1 x Montvale)
* rx6600 (w/4 x Montvale)*
* rx2800 i2 (w/1 x Tukwila)

This doesn't look like a broken architecture, does it?

*) As I haven't yet found out why exactly the breakage (mentioned in
[1]) happens for the rx6600, I just reverted the problematic commit
(61167ad) to check if anything else could hinder its operation. And that
is not the case. As 61167ad seems to not break any other systems or
architectures, I want to give it a little more time and sprinkle some
printks around where it breaks, before giving up on this and contact the
author for help.

In addition I'm looking into testing patches dropped for ia64, e.g. [2]
- which worked for me - and with v6.6-rc6 also [3] - which was merged
with ddf2085 and which also worked for me (see above).

[2]:
https://lore.kernel.org/linux-ia64/d43037ee-bb7f-0cdc-a14d-8cddca8bb373@we=
b.de/

[3]:
https://lore.kernel.org/linux-ia64/E1qgnh2-007ZRZ-WD@rmk-PC.armlinux.org.u=
k/

****

Outside of the kernel - but still relevant for distributions - work was
done for the glibc, too: Tomas discovered a seemingly long forgotten
patch for ia64 by Aurelien Jarno that was adapted to the current state
of the glibc sources and extended with own changes. In total this
enabled 50 unsupported tests, lowered the number of failed tests by 30,
and increased the total number of passing tests by 83 - don't ask me how
`make check` calculates the last number ;-). See [4] for details, since
then we could increase the number of passing tests further.

[4]: https://sourceware.org/bugzilla/show_bug.cgi?id=3D10163#c6

Considering that math "errors" like those (e.g. for `tanf(INFINITY)`)
are there in the glibc for more than 10 years, our progress in just
three weeks into it is not bad. We are working on getting the remaining
errors fixed, too.

Cheers,
Frank
