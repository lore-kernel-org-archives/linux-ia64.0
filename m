From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Mar 2006 23:56:46 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05E8BC92@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Have we just been lucky?
>
>Yes. The window is very small. The zapping must happen between the 
>generation of the accessed/dirty fault and the cmpxchg in the 
>dirty/accessed bit handlers. It seems also that most HPC machines do not 
>use swap making it highly unlikely to encounter this race. The other cases 
>where this could occur are probably even rarer.

Thinking about this further ... in most cases the swap path will also
conceal any evidence that this happened, because it will overwrite
the pte with the swap file number and offset of where it stashed
the page ... so "we've been lucky for all these years" theory is
looking quite credible.

-Tony
