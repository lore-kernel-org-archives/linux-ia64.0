From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 08 Aug 2003 16:12:42 +0000
Subject: Re: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-106035920806139@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105909779318784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105909779318784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 07 August 2003 6:41 pm, Keith Owens wrote:
> On Thu, 7 Aug 2003 17:03:22 -0600, 
> Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> >On Saturday 19 July 2003 12:25 am, Keith Owens wrote:
> >>   OEM data can be variable sized, do not use sizeof().
> >
> >I don't quite understand this one.  Don't these:
> >
> >> -				      (int)sizeof(sal_log_plat_specific_err_info_t) - 1,
> >> +				      ((char*)psei->oem_data - (char*)psei),
> >
> >compute the same value?  I see that OEM data can be of variable
> >size (and we use "u8 oem_data[1]" as a placeholder), but isn't this
> >expression just computing the size of the fixed part of it?
> 
> platform_plat_specific_err_print() maps to ia64_log_prt_oem_data()
> which expects a header length and a section length.
> ia64_log_prt_oem_data() calculates the data length as the difference of
> the first two parameters.

Yes, I read the code and I saw that, but that doesn't address my
question.  The "section length" (which we're computing here) is
really a compile-time constant based on the structure layout.
The "header length" is the variable one and the difference is
the size of OEM data.

I now see the real reason this change is needed, though: because
of structure padding, we can't assume that the variable-length
OEM data begins at sizeof(fixed_part)-1

I'll apply this change now for 2.4 (I hope somebody is tracking
these for 2.5).

Bjorn

