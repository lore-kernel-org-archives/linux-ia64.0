From: Grant Grundler <iod00d@hp.com>
Date: Tue, 23 Sep 2003 18:51:04 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434326809381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 02:29:25PM -0400, Benjamin LaHaise wrote:
...
> (yet another hardware issue pushed off on software for no significant gain).

Even x86 pays at least a one cycle penalty for every misaligned access.
In general, open source code has no excuse for using misaligned fields.
It's (mostly) avoidable.  TCP/IP headers are the historical exception.

One could make the same arguement that a modern NIC should not require
16 byte alignment for DMA. It's a tradeoff one way or the other.
Just a matter of perspective.

grant
