From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 13 Sep 2007 23:11:14 +0000
Subject: Re: [RFC] module to support ACPI AML calls to native firmware
Message-Id: <200709131711.15015.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200709111714.57095.bjorn.helgaas@hp.com>
In-Reply-To: <200709111714.57095.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Tuesday 11 September 2007 05:14:56 pm Bjorn Helgaas wrote:
> ...
> So I'm interested in feedback on the following patches, which do not
> export sal_lock, but rather export functions that can be used to call
> SAL or other native firmware interfaces.

Hi Tony,

I haven't heard much feedback, and I couldn't come up with any
significantly better text for the description.

If you don't object to the two patches, can you incorporate them
as originally posted?  If you'd prefer a different approach, I'd
be happy to rework them, of course.

Thanks,
  Bjorn
