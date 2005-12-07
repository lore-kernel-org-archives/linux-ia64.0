From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Dec 2005 18:39:54 +0000
Subject: RE: [RFC 1/3] Framework for accurate node based statistics
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F052359F9@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0512061447590.20377@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0512061447590.20377@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>, Keith Owens <kaos@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>

>> How big is that array going to get?  The total per cpu data area is
>> limited to 64K on IA64 and we already use at least 34K.
>
> Maximum around 1k nodes and I guess we may end up with 16 counters:
>
> 1024*16*8 = 131k ?

Ouch.

Can you live with a pointer to that monster block of space in the
per-cpu area?

Otherwise the next step up is a 256K per cpu area ... which I wouldn't
want to make the default (so we'll have another 2*X explosion in the
number of possible configs to test).

-Tony
