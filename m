From: Michael Raymond <mraymond@sgi.com>
Date: Tue, 22 Feb 2005 23:01:35 +0000
Subject: Re: User Level I/O
Message-Id: <20050222170135.A165166@xanatos.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050222105957.B67472@goliath.americas.sgi.com>
In-Reply-To: <20050222105957.B67472@goliath.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    Your project appears to wrap user I/O functionality together nicely.  I
hadn't looked at it in a while but I'll try to come up to speed on it.
    Where your work appears to differ is that you explicitly use a thread
for handling interrupts whereas ULIs run on whatever thread was running when
the interrupt came in.  Specifically, code running on the interrupt stack
twiddles the TLBs so that the address space of the process that registered
the ULI is addressable from the CPU.  It then RFI's into user space, runs
the handler, returns to the kernel, and resets the VM info.  Depending on
the scheduling load, ULIs can offer much better responsiveness.
    I think that both approaches have their place.
      	    	      		      	    	  	Michael

On Wed, Feb 23, 2005 at 09:18:44AM +1100, Peter Chubb wrote:
> How does this compare with the user-level interrupts stuff I've done?
> 
> http://www.gelato.unsw.edu.au/IA64wiki/UserLevelDrivers
> 
> 
> -- 
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
> The technical we do immediately,  the political takes *forever*

-- 
Michael A. Raymond              Office: (651) 683-3434
Core OS Group                   Real-Time System Software
