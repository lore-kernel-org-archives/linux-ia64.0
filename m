From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 12 Jul 2004 18:24:31 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <20040712182431.GB28281@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com> <Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com> <Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com> <Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com> <20040711123803.GD21264@devserv.devel.redhat.com> <Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
In-Reply-To: <Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>
Cc: Jakub Jelinek <jakub@redhat.com>, davidm@hpl.hp.com, suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 12, 2004 at 02:08:11PM -0400, Ingo Molnar wrote:
> the #ifdef could be made an arch inline or define. But it's really
> academic as only ia64 seems to have this problem. So i'd suggest the patch
> below.

Well, it's not.  We probably want each new port start to have the ia64
behaviour, so it should be abstracted out nicer.

