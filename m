From: Alex Chiang <achiang@hp.com>
Date: Tue, 26 Feb 2008 07:15:25 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:
Message-Id: <20080226071525.GA16310@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Shaohua Li <shaohua.li@intel.com>:
> 
> On Mon, 2008-02-25 at 16:08 -0700, Alex Chiang wrote:
> > 
> > My original commit relied on fall-through behavior to still
> > try and call ia64_sal_physical_id_info(), because there are
> > cases/platforms where PAL_LOGICAL_TO_PHYSICAL is not
> > implemented but SAL_PHYSICAL_ID_INFO is.
> > 
> > I think the more interesting question is, why is that SAL
> > call hanging / oops'ing your machine rather than returning
> > with an error code?
> > 
> > In other words, why doesn't the error path work?
>
> Yes, this is strange. But other SAL calls are ok, maybe
> firmware bug or something I don't know. I'm not familiar with
> this area, if you need further info, let me know.

Do you get anything useful (like the oops message) printed on the
console or in your syslog?

That might be a good first step.

Thanks.

/ac

