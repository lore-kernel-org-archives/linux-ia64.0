From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 18 Dec 2000 00:42:14 +0000
Subject: [Linux-ia64] Re: alignment issues on netif_rx (fwd)
Message-Id: <marc-linux-ia64-105590678205859@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This just came up on the netdev list.  Is Andi correct and misaligned
IP options will cause a kernel error?

------- Forwarded Message

Return-Path: <owner-netdev@oss.sgi.com>
Date:   Sun, 17 Dec 2000 22:36:12 +0100
From:   Andi Kleen <ak@muc.de>
To:     Johannes Erdfelt <johannes@erdfelt.com>
Cc:     "David S. Miller" <davem@redhat.com>, kai@thphy.uni-duesseldorf.de,
        netdev@oss.sgi.com
Subject: Re: alignment issues on netif_rx

On Sun, Dec 17, 2000 at 04:21:14PM +0100, Johannes Erdfelt wrote:
> 
> However, I can't imagine we've made it this long without this being a
> problem so there must be something I'm missing.

Nobody apparently tried to use IPX on IA64 yet (due to a different ethernet
header length it usually has to deal with an misaligned header)

With this there are also plenty of ways to crash an IA64 box remotely,
e.g. by putting misaligned timestamps into options. 


- -Andi


------- End of Forwarded Message



