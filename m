From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 18:52:00 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434395610146@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 20:54:50 +0200
Andreas Schwab <schwab@suse.de> wrote:

> Unaligned access are a BUG.

Wrong, they've been allowed in the kernel networking from day
one and there is nothing that can be done to avoid the cases
for which they occur.

Stop spreading fud.
