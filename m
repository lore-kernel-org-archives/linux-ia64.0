From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Feb 2005 01:13:00 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <16906.46364.860076.109807@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Feb 2005 17:05:52 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> Am I seeing this right: the path doesn't save practically nothing
  >> other than what is saved in the PAL min-state area?  The path
  >> presumably also ought to switch the register-backing store (I
  >> think Keith alluded to this previously).

  Tony> No ... we jump down to ia64_os_mca_proc_state_dump that saves
  Tony> a lot of stuff ... but not apparently the right stuff.

Ah, yes, that looks (slightly) better.  That code is really hard to
follow and could use serious cleanup.

BTW: just as a heads-up: as I'm working on integrating libunwind, I'm
changing the way INIT stack-dumps are done.  The idea is to do things
in such a way that we avoid having to create a (dummy) switch-stack
structure before invoking the INIT-handler.  Basically, it'll just
simplify the assembly code.  Hopefully, this will also make it easier
to create a stack trace from an MCA-handler, but I'm not there yet.

	--david
