From: Erich Focht <efocht@hpce.nec.com>
Date: Thu, 12 May 2005 21:06:35 +0000
Subject: Re: Redirectable IRQs
Message-Id: <200505122306.36432.efocht@hpce.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <OFC99CCFB1.3123C49E-ON07256FFF.00687D83-07256FFF.0069CEAC@us-phx1.az05.bull.com>
In-Reply-To: <OFC99CCFB1.3123C49E-ON07256FFF.00687D83-07256FFF.0069CEAC@us-phx1.az05.bull.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 12 May 2005 22:37, Michael.Meduna@bull.com wrote:
> Thank you for the reply.  I forgot to mention that this is an Intel ia64
> platform.

As far as I remember I've been told by Intel that the i870 chipset doesn't
implement the XTP priority based IRQ rerouting. The NEC TX-7 chipset does and
allows priority based routing within a cell (ccNUMA node). Maybe fixed
routing works for you.

Regards,
Erich

