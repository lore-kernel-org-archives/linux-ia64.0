From: Patrick Gefre <pfg@sgi.com>
Date: Fri, 17 Dec 2004 22:14:29 +0000
Subject: Re: [PATCH] 2.6.10 Altix : ioc4 serial driver support
Message-Id: <41C35A45.7090206@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412162224.iBGMOQ52284713@fsgi900.americas.sgi.com> <20041216231519.GA16249@infradead.org>
In-Reply-To: <20041216231519.GA16249@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> On Thu, Dec 16, 2004 at 04:24:26PM -0600, Pat Gefre wrote:
> 
>>I have a serial driver for Altix I'd like to submit.
>>
>>The code is at:
>>ftp://oss.sgi.com/projects/sn2/sn2-update/033-ioc4-support
>>
>>Signed-off-by: Patrick Gefre <pfg@sgi.com>
> 
> 
> I took a very short look and what spring to mind first is that the
> device probing/remoal is rather bogus.  The ->probe/->remove callbacks
> of a PCI driver can be called at any time, and any initialization /
> teardown actions must happen from those.  A logical consequence of that
> is that a proper PCI driver should have no global state.
> 

Christoph,

I'm not sure what you mean here. I don't have an entry for ->remove and the driver is self-contained.

-- Pat
