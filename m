From: "David S. Miller" <davem@davemloft.net>
Date: Fri, 24 Dec 2004 17:05:39 +0000
Subject: Re: Prezeroing V2 [2/4]: add second parameter to clear_page() for
Message-Id: <20041224090539.40bba423.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
	<41C20E3E.3070209@yahoo.com.au>
	<Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 23 Dec 2004 11:33:59 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> Modification made but it would be good to have some feedback from the arch maintainers:
> 
 ...
> sparc64

I don't see any sparc64 bits in this patch, else I'd
review them :-)
