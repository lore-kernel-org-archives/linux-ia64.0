From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 05 Mar 2002 07:00:36 +0000
Subject: Re: [Linux-ia64] simeth problem...
Message-Id: <marc-linux-ia64-105590701905220@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905218@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905218@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter,

On Tue, Mar 05, 2002 at 11:36:19AM +1100, Peter Chubb wrote:
> 	I'm having problems with the simulated ethernet interface.
> 
> >From within the simulator, I can ping any machine on the local network
> except the machine the simulator is being hosted on.
> 
That's normal. Because of the way simeth is implemented you cannot ping 
the local host IP address from within the simulated kernel. 

> I can ping the simulated ethernet from any machine on the network
> except the one the simulator is hosted on.

That's also normal.

The simulated ethernet is using a packet filter and the host interface
is put in promiscuous mode. The filter routes all broadcasts + packet
for the simeth address to the simeth driver, the rest goes to the local
host interface. I believe such configuration forbids sending from the
simeth back to the local host and that's why pinging in any direction does
not work.


-- 
-Stephane

