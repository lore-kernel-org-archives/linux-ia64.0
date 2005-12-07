From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 07 Dec 2005 18:47:45 +0000
Subject: RE: [RFC 1/3] Framework for accurate node based statistics
Message-Id: <Pine.LNX.4.62.0512071046380.24659@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F052359F9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F052359F9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Keith Owens <kaos@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>

On Wed, 7 Dec 2005, Luck, Tony wrote:

> Can you live with a pointer to that monster block of space in the
> per-cpu area?
> 
> Otherwise the next step up is a 256K per cpu area ... which I wouldn't
> want to make the default (so we'll have another 2*X explosion in the
> number of possible configs to test).

Lets wait. I just did this to show how local_t could be implemented. This 
is a RFC and the major problems (f.e. the 3 second delay) 
have not been addressed so this is all vaporware for now.

