From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 19 Sep 2007 15:49:32 +0000
Subject: Re: [RFC] module to support ACPI AML calls to native firmware
Message-Id: <200709190949.32750.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200709111714.57095.bjorn.helgaas@hp.com> <200709131711.15015.bjorn.helgaas@hp.com> <617E1C2C70743745A92448908E030B2A0274F144@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0274F144@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

On Tuesday 18 September 2007 05:53:28 pm Luck, Tony wrote:
> > If you don't object to the two patches, can you incorporate them
> > as originally posted?  If you'd prefer a different approach, I'd
> > be happy to rework them, of course.
> 
> I think that adding 4K to the kernel (about 0.04% increase looking
> at a recent build ... or 0.0001% of total memory on a 4G system) isn't
> really a big deal.  I'd rather do that than export all the fw_call_*()
> functions for all the world to see.

That's certainly the most straightforward solution.  I'll post those
patches in a bit.

Bjorn
