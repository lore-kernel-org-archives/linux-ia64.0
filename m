From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 30 Jul 2003 22:07:34 +0000
Subject: Re: A new patch for hint_pause
Message-Id: <marc-linux-ia64-105960301403916@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105951916520159@msgid-missing>
In-Reply-To: <marc-linux-ia64-105951916520159@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 29 July 2003 6:11 pm, Chris Wedgwood wrote:
> On Tue, Jul 29, 2003 at 04:51:14PM -0600, Bjorn Helgaas wrote:
> 
> > +$(warning Warning: Please use binutil version 2.14.90.0.4.1 or higher to get the support of hint instruction in kernel.) 
> 
> Making a new binutils a requirement would be considered too drastic?

I think the new binutils is a requirement for 2.5/2.6, but I didn't want
to force that for 2.4.

Bjorn

