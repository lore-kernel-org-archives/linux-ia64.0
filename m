From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 23 Sep 2003 21:00:34 +0000
Subject: RE: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106435141020593@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Maw, 2003-09-23 at 19:21, Luck, Tony wrote:
> a) the programmer is playing fast and loose with types and/or casts.
> b) the end-user is going to be disappointed with the performance.

c) the programmer is being clever and knows the unaligned access is
cheaper on average than the cost of making sure it cant happen

> Looking at a couple of ia64 build servers here I see zero unaligned
> access messages in the logs.

Anyone who can deliver network traffic to your box can soon fix that...


