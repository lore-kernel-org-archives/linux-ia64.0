From: "David S. Miller" <davem@redhat.com>
Date: Fri, 26 Sep 2003 01:12:58 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106453959819378@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 25 Sep 2003 20:11:27 +0400
Ivan Kokshaysky <ink@jurassic.park.msu.ru> wrote:

> On Alpha it is - I did some experimentation yesterday with
> the tulip driver and "rx_copybreak=0" vs default "rx_copybreak18".
> That's true, copying the large packet is very expensive due to constant
> cache misses. On UP1500 it costs more than 2500 cycles per 1.5Kb
> copy on large ftp transfers.
> OTOH, minimal time to handle unaligned load is ~200 cycles (ev6 cpu),
> but only when the trap handler itself and its data are in L1 cache
> (like doing unaligned load in a tight loop). In the real life average
> time is ~400 cycles due to cache misses.
> Further, with "rx_copybreak=0" I've got 20 (!) unaligned traps per TCP
> packet, i.e. penalty was 8000 vs 2500 cycles...

Fine, then we should have something like an rx_copybreak scheme in
the ns83820 driver too.

Thanks for your data.
