From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 18 Dec 2004 14:51:04 +0000
Subject: Re: [PATCH] 2.6.10 Altix : ioc4 serial driver support
Message-Id: <20041218145104.GA7669@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412162224.iBGMOQ52284713@fsgi900.americas.sgi.com> <20041216231519.GA16249@infradead.org> <41C35A45.7090206@sgi.com>
In-Reply-To: <41C35A45.7090206@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> I'm not sure what you mean here. I don't have an entry for ->remove and the 
> driver is self-contained.

In a PCI driver (well, just about any driver for a modern bus) you have
an probe and an remove entry.  All code to setup and teardown a device must
happen in those functions, and must not use global state but only the device
instance pointers. 

btw, no need to Cc linux-ia64, there's nothing ia64-specific in this driver.
