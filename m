From: afzal mohammed <afzal.mohd.ma@gmail.com>
Date: Sat, 21 Mar 2020 17:55:03 +0000
Subject: Re: [PATCH 00/18] genirq: Remove setup_irq()
Message-Id: <20200321174303.GA7930@afzalpc>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1581478323.git.afzal.mohd.ma@gmail.com>
 <87y2somido.fsf@nanos.tec.linutronix.de>
 <20200227110713.GA5708@afzalpc>
In-Reply-To: <20200227110713.GA5708@afzalpc>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Nicolas Palix <nicolas.palix@imag.fr>, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, Julia Lawall <Julia.Lawall@lip6.fr>, linux-m68k@lists.linux-m68k.org, Michal Marek <michal.lkml@markovi.net>, linux-rpi-kernel@lists.infradead.org, linux-alpha@vger.kernel.org, Gilles Muller <Gilles.Muller@lip6.fr>, linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

Hi Thomas,

On Thu, Feb 27, 2020 at 04:37:13PM +0530, afzal mohammed wrote:
> On Thu, Feb 27, 2020 at 11:31:15AM +0100, Thomas Gleixner wrote:

> > Vs. merging this series, I suggest the following approach:
> > 
> >    - Resubmit the individual changes as single patches or small series
> >      to the relevant maintainers and subsystem mailing lists. They have
> >      no dependency on a core change and can be applied where they belong
> >      to.
> > 
> >    - After 5.6-rc6, verify which parts have made their way into
> >      linux-next and resubmit the ignored ones as a series to me along
> >      with the removal of the core parts.
> > 
> > That way we can avoid conflicting changes between subsystems and the tip
> > irq/core branch as much as possible.
> 
> Okay, i will do accordingly.

i am on it, is delayed due to the reason as mentioned at,

https://lkml.kernel.org/r/20200321172626.GA6323@afzalpc

[ not repeating contents here since other mail was sent just now,
  cc'ing you ]

Regards
afzal
