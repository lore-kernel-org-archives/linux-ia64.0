From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 14 Dec 2005 13:17:44 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <43A01B78.3080506@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:

> 
> Then you can register the drivers on all platforms, but the .add()
> function (and hence, the rest of the driver) will only be called
> when the hardware is actually present.  So you don't need any
> platform-qualified initcalls.
> 

Hmmm ... I haven't done alot with ACPI but I'll go take a look.

This seems to handle the drivers ... but the issue of the other
initcalls remains the same?  What do I do with layers above/below
the device calls (note, that some of the calls you list above are
NOT device_initcalls, but subsys_initcalls in order to get the
driver load order correct)?  What about non-device level
initcalls like sn_pci_init?

I suppose I could in that once instance use ia64_platform_is.
But then we're in the same boat we were in earlier ...

P.

