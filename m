From: Rik van Riel <riel@redhat.com>
Date: Mon, 08 Nov 2004 16:35:13 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <Pine.LNX.4.44.0411081134310.8589-100000@chimarrao.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <226170000.1099843883@[10.10.2.4]>
References: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Sun, 7 Nov 2004, Martin J. Bligh wrote:

> Doing ps or top is not unusual at all, and the sysadmins should be able
> to monitor their system in a reasonable way without crippling it, or
> even effecting it significantly.

I don't think there is a single system out there where
people throw performance monitoring out the window, in
the name of performance.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

