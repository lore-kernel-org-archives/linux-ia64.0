From: Patrick Gefre <pfg@sgi.com>
Date: Fri, 27 Aug 2004 16:32:45 +0000
Subject: Re: Latest Altix I/O code reorganization code
Message-Id: <412F622D.5050404@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <20040806141836.A9854@infradead.org> <411AAABB.8070707@sgi.com> <412F4EC9.7050003@sgi.com> <20040827164548.A32422@infradead.org>
In-Reply-To: <20040827164548.A32422@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Christoph Hellwig wrote:
> On Fri, Aug 27, 2004 at 10:10:01AM -0500, Patrick Gefre wrote:
> 
>>This is an update to our last set of patches. I've added some comments from the
>>last review and another synopsis of the patches. The individual patches will
>>follow this email.
> 
> 
> Applying this against current BK gives a reject in
> arch/ia64/sn/io/machvec/pci_bus_cvlink.c for the 6th patch
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I used the tree at http://lia64.bkbits.net/linux-ia64-test-2.6.8.1
from yesterday
