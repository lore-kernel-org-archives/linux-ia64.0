From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 24 Dec 2004 16:24:03 +0000
Subject: Re: Prezeroing V2 [1/4]: __GFP_ZERO / clear_page() removal
Message-Id: <Pine.LNX.4.58.0412240823240.6561@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
 <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
 <41CB25AE.6010109@didntduck.org>
In-Reply-To: <41CB25AE.6010109@didntduck.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brian Gerst <bgerst@didntduck.org>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 23 Dec 2004, Brian Gerst wrote:

> This part is wrong.  kmalloc() uses the slab allocator instead of
> getting a full page.

Thanks for finding that. V3 will have that fixed.
