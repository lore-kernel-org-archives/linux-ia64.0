From: "Alberto Munoz" <amunoz@vmware.com>
Date: Wed, 05 Nov 2003 17:14:08 +0000
Subject: RE: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106805276211464@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Thank you for the clarification.

> > I still believe that a failed speculative read (for example 
> > of poisoned data) will generate an MCA. Perhaps someone from
> > Intel can confirm or deny?
> 
> It depends on exactly what you mean by "speculative read", and
> even there it is not architecturally defined, so different
> implementations may behave differently ("Ask not the elves for
> advice for they will say both yes and no" - Tolkien).
> 
> "Speculative" reads from memory as a result of lfetch, or a code
> fetch for a mispredicted branch that reference poisoned data may
> not generate an MCA (since the processor can know that the poisoned
> data will not be consumed.  Speculative reads from "ld.s" have
> less scope to avoid the MCA

I actually meant a read generated as a result of a ld.s. 

By the way, what do you mean by "less scope to avoid the MCA"? this statement
seems to imply that some existing implementations do it (avoid generating and
MCA when a ld.s accesses poisoned data) under some circumstances. Can you
elaborate?

What implementation of the Itanium processor supports avoiding MCAs from
lfetch or code fetch operations? I don't think Itanium 1 or 2 do this. How
about Madison?

> There's a new bit coming for PAL_PROC_{GET,SET}_FEATURES which
> will at least tell you (and may allow you to request, if the
> implementation supports it) whether the processor will respond
> to poison with CMCI, or upgrade to MCA ... watch the web for a
> spec update to the SDV

I assume this is only for the write path (not the read). As a CMCI on the
read path cannot possibly guarantee containment (prevent unmarked corrupt
data from making it to a register and eventually to memory, disk or the
network). Unless the (architectural) position is that an OS sets this bit at
its own risk...

Thanks again,

Bert Munoz
 
> -Tony
> 
> 


