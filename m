From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 29 Mar 2006 22:17:45 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <Pine.LNX.4.64.0603291415140.23901@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <65953E8166311641A685BDF71D865826A23D0E@cacexc12.americas.cpqcorp.net>
In-Reply-To: <65953E8166311641A685BDF71D865826A23D0E@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Boehm, Hans" <hans.boehm@hp.com>
Cc: "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 29 Mar 2006, Boehm, Hans wrote:

> Somewhat improved slides for the talk Grant is referring to are at
> http://www.hpl.hp.com/personal/Hans_Boehm/misc_slides/pldi05_threads.pdf

Hmm.. A paper on that subject would be better. Cannot get much from the 
slides.

> It's hard to get this stuff right.  But we knew that.

Could you come up with a proposal how to correctly define and API to bit 
ops in such a way that they work for all architectures and allow us to 
utilize all the features that processors may have?
