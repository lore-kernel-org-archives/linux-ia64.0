From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 24 Dec 2004 16:18:26 +0000
Subject: Re: Prezeroing V2 [2/4]: add second parameter to clear_page() for
Message-Id: <Pine.LNX.4.58.0412240818030.6505@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
 <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
 <20041224083337.GA1043@openzaurus.ucw.cz>
In-Reply-To: <20041224083337.GA1043@openzaurus.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@ucw.cz>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 24 Dec 2004, Pavel Machek wrote:

> Hi!
>
> > o Extend clear_page to take an order parameter for all architectures.
> >
>
> I believe you sould leave clear_page() as is, and introduce
> clear_pages() with two arguments.

Did that in V1 and Andi Kleen complained about it.
