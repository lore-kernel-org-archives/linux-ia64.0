From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 02 Jun 2003 18:19:05 +0000
Subject: RE: [Linux-ia64] [PATCH] MCA recovery for TLB faults for 2.4
Message-Id: <marc-linux-ia64-105590723706110@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706058@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706058@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 2 Jun 2003 10:00:28 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> At the moment the trust level is extremely high.  Linux
  Tony> doesn't even provide a checksum for the ia64_os_mca_dispatch
  Tony> entry code when it registers it with the SAL.

That's true.

  Tony> A checksum in the list of saved translations would only be
  Tony> part of reducing the level of trust ... we'd also need to
  Tony> validate that the entire code path has the correct code (not
  Tony> just the entry point).  There are several other data items on
  Tony> which the code also relies which a truly paranoid MCA handler
  Tony> would also need to validate.

I probably just don't understand what the plan is here.  Are you
planning to fix everything in one fell swoop?  If not, I think
incrementally improving the situation makes sense (i.e., if you work
on piece X, make X as solid as possible; over time do this for more
and more pieces of the MCA subsystem).  There is no doubt that making
the entire MCA subsystem as robust as possible involves a huge amount
of rather tricky work.  Same goes for the INIT path, of course (there
are obvious ways to deadlock it right now; probably something that
could benefit from a reasonably generic lock-busting infrastructure).

	--david

