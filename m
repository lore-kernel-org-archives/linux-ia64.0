From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 16 Dec 2004 23:15:19 +0000
Subject: Re: [PATCH] 2.6.10 Altix : ioc4 serial driver support
Message-Id: <20041216231519.GA16249@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412162224.iBGMOQ52284713@fsgi900.americas.sgi.com>
In-Reply-To: <200412162224.iBGMOQ52284713@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Dec 16, 2004 at 04:24:26PM -0600, Pat Gefre wrote:
> I have a serial driver for Altix I'd like to submit.
> 
> The code is at:
> ftp://oss.sgi.com/projects/sn2/sn2-update/033-ioc4-support
> 
> Signed-off-by: Patrick Gefre <pfg@sgi.com>

I took a very short look and what spring to mind first is that the
device probing/remoal is rather bogus.  The ->probe/->remove callbacks
of a PCI driver can be called at any time, and any initialization /
teardown actions must happen from those.  A logical consequence of that
is that a proper PCI driver should have no global state.

I'd also like to second Matthews commens, please move the driver to
drivers/serial and use proper readX/writeX accessors.  Please run the
driver through sparse to find the iomem derferences and possibly other
issues.
