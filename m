From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 25 Oct 2006 14:18:59 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061025141859.GC5591@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com> <20061025063022.GC12319@colo.lackof.org>
In-Reply-To: <20061025063022.GC12319@colo.lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <grundler@parisc-linux.org>
Cc: Roland Dreier <rdreier@cisco.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

On Wed, Oct 25, 2006 at 12:30:22AM -0600, Grant Grundler wrote:
> Can someone provide a quote of the PCI Local bus spec that allows this?
> (Or at least a reference to a spec version and section number)

PCI-PCI bridges are allowed to do it.  If you look in table E-1 of PCI
2.3, or table 8-3 of PCI-X 2.0, you'll see that a Posted Memory Write
can pass a Delayed Write Request (or in PCI-X, a Memory Write can pass a
Split Write Request).

So mmiowb() will solve the problem for Altix, but leave everybody else
vulnerable.  I actually don't see a way of forcing the config write to
complete before a memory write -- everything is allowed to pass a config
write, even a config read.  I initially thought "But only a crack monkey
would implement a system where a config read could pass a config write",
but the spec explains that:

  In most PCI-X implementations, Split Requests are managed in separate
  buffers from Split Completions, so Split Requests naturally pass Split
  Completions. However, no deadlocks occur if Split Completions block
  Split Requests.

So all this code that checks to see if a write had an effect is unsafe.
I'm a little perturbed by this.  It means the only way to reliably
distinguish between a write that hasn't taken effect yet and a bit (say,
MWI) the device hasn't implemented is to do a memory access to the
device.  Which is hard when you're trying to program the BARs.

I suppose this hasn't bitten us before in, what, 7 years of PCI-X, so
it can't be *that* common a thing for bridges to do.  And we would have
noticed the BAR sizing code going wrong (as it does config write
followed immediately by config read), so maybe implementations aren't as
crackful as the PCI spec seems to permit them to be.

I find it really hard to believe the PCI committee have done something
this stupid.  There must be another rule somewhere that I'm missing.

