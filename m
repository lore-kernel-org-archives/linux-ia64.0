From: Andi Kleen <ak@suse.de>
Date: Fri, 19 Sep 2003 04:43:15 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106394670602546@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 18, 2003 at 09:38:47PM -0700, Grant Grundler wrote:
> On Fri, Sep 19, 2003 at 02:16:29PM +1000, Peter Chubb wrote:
> > The obvious approach of realigning the SKB by 2 bytes seems not to
> > work.
> 
> Could you be more detailed about the "obvious approach"?
> ie show the diff of what you changed.
> 
> Several other NIC driver "alias" (as davidm describes it) the buffer
> by reserving two bytes at the beginning of the recieve buffer
> where header and payload data are DMAd on inbound traffic.

It is a mixed blessing, because the result is a non cache line 
aligned buffer. Some NIC chipsets don't like this because they have
to do a read-modify-write cycle for the first cache line and cannot
burst the full packet.

-Andi
