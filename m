From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 27 Aug 2004 17:15:38 +0000
Subject: Re: Latest Altix I/O code reorganization code
Message-Id: <20040827181538.A1173@infradead.org>
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

The header changes in your patchkit are still rather strange, you're e.g.
adding a pfn_t or clusterid_t but never using it.  As suggested in a previous
mail please also provide a clean set of headers in addition to the clean set
of source files.  There's lots of dead wood in thos and with all the code
gone youshould be able to kill off all the IRIX-compat gunk, etc..

