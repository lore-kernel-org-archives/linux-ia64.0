From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 27 Aug 2004 15:45:48 +0000
Subject: Re: Latest Altix I/O code reorganization code
Message-Id: <20040827164548.A32422@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <20040806141836.A9854@infradead.org> <411AAABB.8070707@sgi.com> <412F4EC9.7050003@sgi.com>
In-Reply-To: <412F4EC9.7050003@sgi.com>; from pfg@sgi.com on Fri, Aug 27, 2004 at 10:10:01AM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 27, 2004 at 10:10:01AM -0500, Patrick Gefre wrote:
> 
> This is an update to our last set of patches. I've added some comments from the
> last review and another synopsis of the patches. The individual patches will
> follow this email.

Applying this against current BK gives a reject in
arch/ia64/sn/io/machvec/pci_bus_cvlink.c for the 6th patch

