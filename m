From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 20 Sep 2004 15:45:29 +0000
Subject: Re: page fault scalability patch V8: [4/7] universally available
Message-Id: <Pine.LNX.4.58.0409200844460.3633@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
 <B6E8046E1E28D34EB815A11AC8CA312902CD3243@mtv-atc-605e--n.corp.sgi.com>
 <Pine.LNX.4.58.0409181627300.24054@schroedinger.engr.sgi.com>
 <200409191430.37444.vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200409191430.37444.vda@port.imtp.ilyichevsk.odessa.ua>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Cc: akpm@osdl.org, "David S. Miller" <davem@davemloft.net>, benh@kernel.crashing.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Sun, 19 Sep 2004, Denis Vlasenko wrote:

> Far too large for inline
> Ditto.

Umm... The code was inline before and for non 80386 its the same size as
before.

