From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 04 Apr 2002 21:59:25 +0000
Subject: RE: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905385@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905163@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905163@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 3 Apr 2002 08:18:45 -0800 , "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com> said:

  Jay> We want to report success using the 2.4.18 kernel and the info
  Jay> sent to the segv handler on a page fault for our distributed
  Jay> virtual shared memory system on IA64.

Great!  Glad to hear that.

  Jay> We had to make one assumption, though, that wasn't covered in
  Jay> your mail (below).

  Jay> The assumption was that if si_code=0, that the access was a
  Jay> "read".  We had originally assumed it was a "write", but this
  Jay> caused some errors.  When we changed to assuming "read", things
  Jay> worked.  Is this assumption valid?  When does this case occur?
  Jay> Our scan of the kernel source seemed to indicate that this case
  Jay> can't happen.

Hmmh, that's a bit odd.  If si_code is zero, we can't know what
triggered the segfault.  It could have been a read, a write, a
semaphore instruction, or something entirely different (e.g., user
sending SIGSEGV via kill(2)).  Now, for a distributed shared memory
system, I'd have thought that you'd want to treat such unknown
accesses as writes, because otherwise the fault might re-occur as soon
as the faulting instruction is restarted (since the page still doesn't
have write permission).  For normal cases (non-error cases/silly user
cases), I wouldn't have expected this to occur.  Do you know where
those SIGSEGVs with si_code=0 were coming from?

	--david

