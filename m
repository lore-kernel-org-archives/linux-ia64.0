From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 19 Jul 2008 10:37:11 +0000
Subject: Re: [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)
Message-Id: <87prpa88iw.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080718203514.GD29621@sgi.com>
In-Reply-To: <20080718203514.GD29621@sgi.com> (Russ Anderson's message of "Fri, 18 Jul 2008 15:35:14 -0500")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Russ Anderson <rja@sgi.com> writes:

> [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)

FWIW I discussed this with some hardware people and the general
opinion was that it was way too aggressive to disable a page on the
first corrected error like this patchkit currently does.  

The corrected bit error could be caused by a temporary condition
e.g. in the DIMM link, and does not necessarily mean that part of the
DIMM is really going bad. Permanently disabling would only be
justified if you saw repeated corrected errors over a long time from
the same DIMM.

There are also some potential scenarios where being so aggressive
could hurt, e.g. if you have a low rate of random corrected events
spread randomly all over your memory (e.g. with a flakey DIMM
connection) after a long enough uptime you could lose significant parts
of your memory even though the DIMM is actually still ok.

Also the other issue that if the DIMM is going bad then it's likely
larger areas than just the lines making up this page. So you
would still risk uncorrected errors anyways because disabling
the page would only cover a small subset of the affected area.

If you really wanted to do this you probably should hook it up
to mcelog's (or the IA64 equivalent) DIMM database and then
control it from user space with suitable large thresholds
and DIMM specific knowledge. But it's unlikely it can be really
done nicely in a way that is isolated from very specific 
knowledge about the underlying memory configuration.

-Andi
