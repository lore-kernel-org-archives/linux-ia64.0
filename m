From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 06 Apr 2005 00:33:59 +0000
Subject: Re: [PATCH] add a clear_pages function to clear pages of higher
Message-Id: <Pine.LNX.4.58.0504051729080.12307@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503101229420.13911@schroedinger.engr.sgi.com>
 <200503111008.12134.vda@port.imtp.ilyichevsk.odessa.ua>
 <Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
 <200503181154.37414.vda@port.imtp.ilyichevsk.odessa.ua>
 <Pine.LNX.4.58.0503180652350.15022@schroedinger.engr.sgi.com>
 <20050318192808.GB38053@muc.de> <16963.2075.713737.485070@napali.hpl.hp.com>
 <Pine.LNX.4.58.0504051706110.12179@schroedinger.engr.sgi.com>
 <16979.11287.36091.610287@napali.hpl.hp.com>
In-Reply-To: <16979.11287.36091.610287@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Andi Kleen <ak@muc.de>, Christoph Lameter <clameter@sgi.com>, Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, linux-ia64@vger.kernel.org, Jens.Maurer@gmx.net

On Tue, 5 Apr 2005, David Mosberger wrote:

> What LMbench test other than fork/exec would you have expected to be
> affected by this?  LMbench is not a good benchmark for this (remember:
> it's a _micro_ benchmark).

LMbench does a variety of things and I expected to see at least
something on the page fault test and hopefully also some variations for
other tests.

Which benchmark would you recommend for this?

