From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Jul 2004 19:10:28 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <16626.57892.533203.683465@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
	<Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
	<20040711123803.GD21264@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
	<20040712182431.GB28281@infradead.org>
	<Pine.LNX.4.58.0407121428270.22224@devserv.devel.redhat.com>
In-Reply-To: <Pine.LNX.4.58.0407121428270.22224@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jakub Jelinek <jakub@redhat.com>, davidm@hpl.hp.com, suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> On Mon, 12 Jul 2004 14:29:16 -0400 (EDT), Ingo Molnar <mingo@redhat.com> said:

  >> Well, it's not.  We probably want each new port start to have the ia64
  >> behaviour, so it should be abstracted out nicer.

  Ingo> is it an issue? Each new port will have PT_GNU_STACK, unless they base
  Ingo> themselves on old compilers.

PT_GNU_STACK is pure bloat on new architectures (and ia64).

	--david
