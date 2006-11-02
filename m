From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Nov 2006 19:57:42 +0000
Subject: RE: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <617E1C2C70743745A92448908E030B2ABC8C04@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> But seriously, considering patch slot 1 instruction with bits slot1[40:18]
> (which is nicely contained within the upper 8-byte of a bundle). The encoding
> for break instruction takes [40:27], and it left you with 9 bits to encode
> immediate value (actually 10 because bit 36 is also part of immediate value).
> With that, kprobe on slot1 can be extended to all CPU, not just montecito.

Sounds like with some careful trickery (and choice of break value ranges) you
might well be able to *insert* the breakpoint in slot1 with only 8-byte atomic
operations.

But I can't see how you plan to *remove* the breakpoint and restore the
original instruction.

-Tony
