From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 25 Jun 2004 21:18:41 +0000
Subject: Re: [PATCH] module relocation code
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01864439@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
In-Reply-To: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This thread:
http://www.gelato.unsw.edu.au/linux-ia64/0404/9348.html

died out a couple of days in with these final comments:

Jean-Marc> Indeed, but the only benefit I can see is that we could
Jean-Marc> use a smaller plt entry that does not update gp and
Jean-Marc> simply branches to the target. Only module .init code is
Jean-Marc> impacted, so I'm not sure it is worth handling it
Jean-Marc> differently.

David> I'm not sure either but I think it should be explored.  If
David> the code comes out nicer and cleaner, I'd certainly prefer
David> that approach.  I'm not so much worried about the savings,
David> but about introducing different kinds of bugs or maintenance
David> head-ache.

Which is a pity ... because I just got an ENOEXEC trying to load
a module with a "value 3440586 out of IMM21b range" message in the
log :-(

Looking through this thread, and at the patch itself it looks to
me like avoiding the PLT and using a "relaxing" branch would cause
more complexity in the module_frob_arch_sections code path ... as
we'd have to figure out then how many branches needed full sized
PLT, and how many could use simpler stub, and reserve space for
enough of each type.  For the module that I'm looking at the O(N^2)
code in the count_{gots|plts|fdescs} routines is already causing
significant pain without making it more complicated.

-Tony
