From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 19:08:56 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434575613169@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 21:16:33 +0200
Andreas Schwab <schwab@suse.de> wrote:

> Or the compiler generates code to take advantage of the fact that the
> lower address bits are zero.

The only place where I can se it doing this legally is for structure
offsets.  For example where a "load 4 byte word" instruction takes an
offsetable address composed of a reg and an integer offset where the
integer offset must be a multiple of 4.

This rule we do abide by in the kernel, because PARISC requires this.

Anything more is asking for trouble, I wouldn't want to use such a compiler
in the real world :)
