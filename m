From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 19 Sep 2003 05:11:21 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106394849303696@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Grant" = Grant Grundler <iod00d@hp.com> writes:

Grant> On Fri, Sep 19, 2003 at 06:43:15AM +0200, Andi Kleen wrote:

Grant> Same is true for TX/RX descriptor addresses.  Behavior is
Grant> undefined if the addresses for DMA are not 4-byte aligned.

Grant> Anyone know if that's true for NS83820?  I couldn't find which
Grant> driver controls that chip/NIC via a quick grep.

I believe it is, based on the experiments I've done here, and on
looking at the BSD driver.

Driver is drivers/net/ns83820.c

Peter C
