From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Jul 2004 20:21:31 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <16626.62155.711114.734967@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
	<Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
	<20040711123803.GD21264@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407121315170.1764@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0407121315170.1764@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Ingo Molnar <mingo@redhat.com>, Jakub Jelinek <jakub@redhat.com>, davidm@hpl.hp.com, suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> On Mon, 12 Jul 2004 13:17:20 -0700 (PDT), Linus Torvalds <torvalds@osdl.org> said:

  Linus> On Mon, 12 Jul 2004, Ingo Molnar wrote:
  >>  so ... this should be #ifndef ia64?

  Linus> No. Make it a CONFIG_DEFAULT_NOEXEC and make the relevant
  Linus> architectures do a

  Linus> 	define_bool DEFAULT_NOEXEC y

  Linus> in their Kconfig files.

Would it be better to reverse the sense (i.e., make it DEFAULT_EXEC),
since the latter new platforms by default almost certainly do NOT want
DEFAULT_EXEC?

	--david
