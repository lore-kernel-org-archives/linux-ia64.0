From: Grant Grundler <iod00d@hp.com>
Date: Fri, 19 Sep 2003 04:38:47 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106394634502338@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 02:16:29PM +1000, Peter Chubb wrote:
> The obvious approach of realigning the SKB by 2 bytes seems not to
> work.

Could you be more detailed about the "obvious approach"?
ie show the diff of what you changed.

Several other NIC driver "alias" (as davidm describes it) the buffer
by reserving two bytes at the beginning of the recieve buffer
where header and payload data are DMAd on inbound traffic.

I look to my favorite driver, tulip, for an example and promptly
get confused. interrupt.c:tulip_rx() calls skb_reserve(xx,2)
to force alignment when replenishing RX buffers while a note in
tulip_core.c:tulip_init_ring() clearly says not to. I haven't
looked further to figure out the difference.

hth,
grant
