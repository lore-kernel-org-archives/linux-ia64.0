From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Wed, 30 Jul 2003 01:31:32 +0000
Subject: RE: A new patch for hint_pause
Message-Id: <marc-linux-ia64-105952894027478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105951916520159@msgid-missing>
In-Reply-To: <marc-linux-ia64-105951916520159@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It is a requirement if the kernel wants to have the hint_pause
instruction.  If the right version of binutil is not installed then
kernel will be built without this support.

rohit

> -----Original Message-----
> From: Chris Wedgwood [mailto:cw@f00f.org] 
> Sent: Tuesday, July 29, 2003 5:12 PM
> To: Bjorn Helgaas
> Cc: Seth, Rohit; linux-ia64@vger.kernel.org
> Subject: Re: A new patch for hint_pause
> 
> 
> On Tue, Jul 29, 2003 at 04:51:14PM -0600, Bjorn Helgaas wrote:
> 
> > +$(warning Warning: Please use binutil version 
> 2.14.90.0.4.1 or higher 
> > +to get the support of hint instruction in kernel.)
> 
> Making a new binutils a requirement would be considered too drastic?
> 
> 
>   --cw
> 
