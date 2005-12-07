From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 07 Dec 2005 18:24:58 +0000
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
Message-Id: <Pine.LNX.4.62.0512071023530.24516@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9353.1133934652@kao2.melbourne.sgi.com>
In-Reply-To: <9353.1133934652@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>

On Wed, 7 Dec 2005, Keith Owens wrote:

> On Tue, 6 Dec 2005 14:52:33 -0800 (PST), 
> Christoph Lameter <clameter@engr.sgi.com> wrote:
> >+DEFINE_PER_CPU(local_t [MAX_NUMNODES][NR_STAT_ITEMS], vm_stat_diff);
> 
> How big is that array going to get?  The total per cpu data area is
> limited to 64K on IA64 and we already use at least 34K.

Maximum around 1k nodes and I guess we may end up with 16 counters:

1024*16*8 = 131k ?

