From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 22 Jun 2004 21:23:12 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406221523.12446.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 22 June 2004 3:16 pm, Grant Grundler wrote:
> On Tue, Jun 22, 2004 at 09:59:11AM -0600, Bjorn Helgaas wrote:
> > David saw this late last week on a 2.6.7 kernel compiled for UP,
> 
> This is for SMP

Yeah, I saw it with slightly different "console=" parameters than
David did.  So I think it's just a heisenbug and he happened to
trip over it with a UP kernel.

> I suppose that's a possibility. I have a TOC dump on the machine
> and just need to "harvest" it, then see where it's spinning.

Have you used salinfo_decode?  I think there's a debian package
for it now ("salinfo").
