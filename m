From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 29 Jun 2004 18:03:53 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406291802.i5TI26Y13866@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote on Tuesday, June 29, 2004 10:46 AM
> > >
> > > I tried both of these on a machine that doesn't have memory at the stock
> > > kernel load address, and it failed very early on.  However, it works with
> > > the attached patch.
> >
> > Let me confirm what I understand:
> > David's bk tree doesn't boot.
> > David's bk tree + 2 patches I posted this morning doesn't boot.
> >
> > Is that correct?
>
> Correct.  David's tree hangs at a later point though, after printing
> "Console: ... 80x25".


I presume David's bk tree plus this patch also hung on your machine?
http://www.gelato.unsw.edu.au/linux-ia64/0406/10162.html

- Ken


