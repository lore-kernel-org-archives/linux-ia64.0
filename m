From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 05 Jan 2005 01:26:59 +0000
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
Message-Id: <Pine.LNX.4.58.0501041724050.4111@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
  <41C20E3E.3070209@yahoo.com.au>  <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
  <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com> 
 <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com> 
 <Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com> 
 <Pine.GSO.4.61.0501011123550.27452@waterleaf.sonytel.be> 
 <Pine.LNX.4.58.0501041510430.1536@schroedinger.engr.sgi.com> 
 <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
 <1104882342.16305.12.camel@localhost> <Pine.LNX.4.58.0501041715280.2222@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501041715280.2222@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>



On Tue, 4 Jan 2005, Christoph Lameter wrote:
> 
> Ahh. Great. Do I need to submit a corrected patch that removes those two
> lines or is it fine as is?

Please do split it up into a function of its own. It's going to look a lot 
prettier as an intermediate phase. I realize that that touches #3 in the 
series, but I suspect that one will also just be prettier as a result.

		Linus
