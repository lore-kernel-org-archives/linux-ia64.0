From: Grant Grundler <iod00d@hp.com>
Date: Fri, 19 Sep 2003 05:04:29 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106394792803386@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 06:43:15AM +0200, Andi Kleen wrote:
> It is a mixed blessing, because the result is a non cache line 
> aligned buffer. Some NIC chipsets don't like this because they have
> to do a read-modify-write cycle for the first cache line and cannot
> burst the full packet.

yeah, that reminds me...tulip can only DMA to word aligned addresses.
I looked it up again in DEC 21143 HWREF (page 113 of the pdf):
        Table 4-3. RDES2 Bit Field Description
    Field      Description
    31:0       Buffer Address 1
               Indicates the physical address of buffer 1. 
               The buffer must be longword aligned (RDES2<1:0> = 00).

Same is true for TX/RX descriptor addresses.
Behavior is undefined if the addresses for DMA are not 4-byte aligned.

Anyone know if that's true for NS83820?
I couldn't find which driver controls that chip/NIC via a quick grep.

grant
