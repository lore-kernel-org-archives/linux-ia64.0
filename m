From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Wed, 03 Apr 2002 16:18:45 +0000
Subject: RE: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905369@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905163@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905163@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We want to report success using the 2.4.18 kernel and the 
info sent to the segv handler on a page fault for our distributed
virtual shared memory system on IA64.  Thanks for your help.  We had
to make one assumption, though, that wasn't covered in your mail
(below).

The assumption was that if si_code=0, that the access was a "read".
We had originally assumed it was a "write", but this caused some errors.
When we changed to assuming "read", things worked.  Is this assumption
valid?  When does this case occur?  Our scan of the kernel source seemed
to indicate that this case can't happen.

Thanks

Jay Hoeflinger and Naveen Neelakantam



-----Original Message-----
From: David Mosberger [mailto:davidm@hpl.hp.com]
Sent: Friday, February 22, 2002 7:25 PM
To: Hoeflinger, Jay P
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] determining read or write on a page fault


If you want to try with a new kernel, the attached patch should give
you what you want.  Specifically, if you get a SIGSEGV or a SIGBUS and
si_code is non-zero, you can check si_flags.  If it has the
__ISR_VALID flag set, then the code in si_isr is valid.  If si_isr is
valid, you can check whether bit 34 (read exception) or bit 35
(non-access exception) is set.  If so, you may assume that the signal
was due to a load (or lfetch or some such).  In all other cases, you'd
have to play it safe and assume that you're dealing with a write
access.

	--david


< patch deleted >

