From: Scott Hankin <shankin@rational.com>
Date: Mon, 13 Nov 2000 22:36:20 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels
Message-Id: <marc-linux-ia64-105590678205707@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I've built Jim's 1024 toolchain release this way.
>
>I have not yet played with the test10 kernel - I'm still on test9 because
>of the number of patches I'm using, not all of which are yet at test10
>(actually, the last one or two was just announced, so I can probably move
>up a notch soon).
>
>You might want to look into just why it won't boot.  There are several
>workarounds (e.g. qlc > 4GB memory addressing turned on in BIOS, EFI
>workarounds, kernel config parameters such as VHPT and related workarounds
>enabled/disabled, etc.).  Your problem may not be just the toolchain.

Actually, it does boot, but the Ethernet card reports that the 
receiver overflows, and I end up not connected to the net.  In the 
August Red Hat release, the log shows a message about detecting 
"Receiver lock-up bug"
and enables the workaround that exists in the code (even in test10) but
my kernel fails to detect the problem, so the workaround doesn't get
enabled, and my eth0 ends up non-functional as a result.  Have you seen
or heard of this?

- Scott

-----------------------------
Scott Hankin                  In the beginning, there was nothing, then
Rational Software             God said, "Let there be light."  And there
20 Maguire Road               was light.  There was still nothing, but
Lexington, MA 02421           you could see it a lot better.

