From: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Date: Tue, 08 Mar 2005 19:29:29 +0000
Subject: RE: PCI Express
Message-Id: <C7AB9DA4D0B1F344BF2489FA165E502407F63B3F@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, March 07, 2005 8:41 PM Colin wrote:
> On Altix systems, we have a set of "Interrupt Registers" in Memory
Address
> Space that is initialized to target specific CPUs.  The way we 
> initialize a card's MSI is:
>
> 1.  The Target Address is One of these "Interrupt Registers"
> 2.  The Data Payload is the IRQ plus some special Altix bits.
>
> This memory write causes the "Interrupt Chipset" to generate a LINTR
> message to the configured targeted cpu with the IRQ.  Ofcourse, these
> registers are Altix Platform specific.  Moreover, we have chunks of
these
> registers all over the place.

Your solution is Altix chipset specific. MSI affects other architectures
too. General solution would almost certainly be a better one.

> Is there a more direct mechanism to generate an interrupt(LINTR
Message) 
> to a Processor?  

I agree with Jesse's comment.

> With Altix, it's always interesting, with respect to "just work" with 
> typical ia64 code base.  Hopefully, it will work cleaner compared to 
> some of our other efforts.
>
> Are you the maintainer for the MSI code?

I suggest you move any discussion or any proposed changes to LKML
because MSI affects other architectures too. Again, general solution
would almost certainly be a better one.

Thanks,
Long
