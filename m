From: "David S. Miller" <davem@davemloft.net>
Date: Thu, 24 Mar 2005 19:03:36 +0000
Subject: Re: [PATCH] add a clear_pages function to clear pages of higher
Message-Id: <20050324110336.488241c4.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503101229420.13911@schroedinger.engr.sgi.com>
	<200503111008.12134.vda@port.imtp.ilyichevsk.odessa.ua>
	<Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
	<200503181154.37414.vda@port.imtp.ilyichevsk.odessa.ua>
	<Pine.LNX.4.58.0503180652350.15022@schroedinger.engr.sgi.com>
	<20050318192808.GB38053@muc.de>
	<16963.2075.713737.485070@napali.hpl.hp.com>
	<Pine.LNX.4.58.0503241038040.5663@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503241038040.5663@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: davidm@hpl.hp.com, ak@muc.de, clameter@sgi.com, vda@port.imtp.ilyichevsk.odessa.ua, haveblue@us.ibm.com, akpm@osdl.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, linux-ia64@vger.kernel.org, Jens.Maurer@gmx.net

On Thu, 24 Mar 2005 10:41:06 -0800 (PST)
Christoph Lameter <clameter@engr.sgi.com> wrote:

> So it would be useful to have
> 
> clear_page 	-> Temporal. Only zaps one page
> 
> 	and
> 
> clear_pages	-> Zaps arbitrary order of page non-temporal
> 
> 
> Rework the clear_pages patch to do just that? Maybe rename clear_pages
> clear_pages_nt?
> 
> prep_zero_page would use a temporal clear for an order 0 page but a
> nontemporal clear for higher order pages.

That sounds about right to me.

Hmmm, I'm inspired to experiment with this on sparc64 a bit.
:-)
