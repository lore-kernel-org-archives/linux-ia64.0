From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 05 Dec 2003 17:05:38 +0000
Subject: RE: [RFE] Add stacked registers to SAL records (resend)
Message-Id: <marc-linux-ia64-107064399701180@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106870740330038@msgid-missing>
In-Reply-To: <marc-linux-ia64-106870740330038@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Bjorn Helgaas
> Sent: Friday, December 05, 2003 8:29 AM
> To: Keith Owens; linux-ia64@vger.kernel.org
> Subject: Re: [RFE] Add stacked registers to SAL records (resend)
> 
> 
> On Thursday 04 December 2003 5:59 pm, Keith Owens wrote:
> > SAL error records contain most registers in 
> sal_processor_static_info,
> > but not the stacked registers.  What is the process for 
> adding another
> > GUID to the SAL specification to contain the stacked registers?
> 
> I've always been puzzled about why the stacked registers aren't
> available after an INIT, so this proposal sounds incredibly useful
> to me.  Much of the useful information, i.e., function arguments,
> is in the stacked registers and hence currently unavailable.
> 
> As for getting it added to the spec, I don't really know the process.
> But I'll forward this to our people who deal with the spec.  I think
> it would help to have an actual draft of a proposal.
> 
> Tony Luck might have a good Intel contact, too.

I'm looking around for the right person to pass this to.

-Tony
