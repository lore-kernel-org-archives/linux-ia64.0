From: "Jim Hull" <jim.hull@hp.com>
Date: Fri, 17 Oct 2003 18:16:41 +0000
Subject: RE: load-store emulation with SIGSEGV
Message-Id: <marc-linux-ia64-106641454931514@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634457403703@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634457403703@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt Chapman wrote:

> Yep, I do similar things in a virtual machine that I wrote.  
> Here are some notes in case you've overlooked some of the finer
details 
> (and perhaps I've overlooked some of the finer details as well :)).
> 
> Incrementing the IP:
> sc->sc_ip += ((sc->sc_ip & 0xf) = 2) ? 0xe : 1;

I think there's one scenario where this won't work.  If it's possible
for your signal handler to be invoked in cases where the instruction
you're trying to skip over is a two-slot "L+X" instruction from an MLX
bundle (e.g., movl or brl), then the "slot" bits of sc_ip will be 1,
you'll increment them to 2, and when you return to slot 2 of the MLX
bundle you'll immediately take an Illegal Instruction fault.

Probably most "skip an instruction" signal handlers don't need to worry
about this case, because they'll always be pointing at an ordinary
single-slot instruction, but it's something to be aware of.

 -- Jim Hull
    HP Itanium Processor Architect

