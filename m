From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 20 Oct 2003 20:42:22 +0000
Subject: RE: MCA Recovery for Enterprise Server
Message-Id: <marc-linux-ia64-106668311500762@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106663088408345@msgid-missing>
In-Reply-To: <marc-linux-ia64-106663088408345@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 20 Oct 2003 10:02:21 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> David: does "ski" have any hooks for fault injection?

Not that I know of.  However, wouldn't it be possible to extend
fw-emu.c to do such things?  You could hit Ctrl-C at any point in
time, then force a branch to a special fault-injection routine.  That
ought to be workable, though setting up all the info etc. is probably
non-trivial.

	--david
