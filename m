From: Linus Torvalds <torvalds@osdl.org>
Date: Mon, 12 Jul 2004 20:17:20 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <Pine.LNX.4.58.0407121315170.1764@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
 <Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
 <20040711123803.GD21264@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
In-Reply-To: <Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>
Cc: Jakub Jelinek <jakub@redhat.com>, davidm@hpl.hp.com, suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org



On Mon, 12 Jul 2004, Ingo Molnar wrote:
> 
> so ... this should be #ifndef ia64?

No. Make it a CONFIG_DEFAULT_NOEXEC and make the relevant architectures do
a

	define_bool DEFAULT_NOEXEC y

in their Kconfig files.

In general, we should _never_ use an architecture-define. They just always
end up becoming more and more hairy, and less and less obvious what they 
are all about.

So instead, make a readable and explicit config define, and let each 
architecture just set it (or not) as they wish.

		Linus
