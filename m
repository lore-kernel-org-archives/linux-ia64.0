From: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Date: Thu, 25 Sep 2003 16:11:27 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106450653714069@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 08:08:32PM -0700, David S. Miller wrote:
> It's not even decided that the copying version is faster.

On Alpha it is - I did some experimentation yesterday with
the tulip driver and "rx_copybreak=0" vs default "rx_copybreak18".
That's true, copying the large packet is very expensive due to constant
cache misses. On UP1500 it costs more than 2500 cycles per 1.5Kb
copy on large ftp transfers.
OTOH, minimal time to handle unaligned load is ~200 cycles (ev6 cpu),
but only when the trap handler itself and its data are in L1 cache
(like doing unaligned load in a tight loop). In the real life average
time is ~400 cycles due to cache misses.
Further, with "rx_copybreak=0" I've got 20 (!) unaligned traps per TCP
packet, i.e. penalty was 8000 vs 2500 cycles...
Note that my network setup is as simple as possible - no routing/filtering
etc., just a networked workstation. I guess one with a more complex
routing/firewalling configuration would have a LOT more unaligned
traps per packet.

Ivan.
