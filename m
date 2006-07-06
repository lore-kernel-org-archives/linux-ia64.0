From: Peter Chubb <peterc@chubb.wattle.id.au>
Date: Thu, 06 Jul 2006 00:23:18 +0000
Subject: Re: NUMA but not SMP
Message-Id: <87veqbzimh.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A30031D@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A30031D@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

Tony> What does NUMA && !SMP mean?  Should selecting NUMA force SMP?


I can imagine meanings for this combination.. e.g. booting a machine with
multiple memory nodes, but only one processor.  But whether this is
useful is a different matter.  Maybe NUMA should select SMP, as you suggest.
