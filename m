From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 05 Mar 2002 09:34:46 +0000
Subject: Re: [Linux-ia64] simeth problem...
Message-Id: <marc-linux-ia64-105590701905221@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905218@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905218@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@frankl.hpl.hp.com> writes:

peterc> I'm having problems with the simulated ethernet interface.

peterc> From within the simulator, I can ping any machine on the local
peterc> network except the machine the simulator is being hosted on.

Stephane> That's normal. Because of the way simeth is implemented you
Stephane> cannot ping the local host IP address from within the
Stephane> simulated kernel.

Can this be added to the readme file or something?  Or, preferably,
fixed (although that might be too hard, and there be too little interest).  

Another problem I'm having is that if I create lots of simulated discs
only the first two are ever recognised.  The documentation says I can
have up to 26, but only sda and sdb are ever seen by the kernel.

Peter C

