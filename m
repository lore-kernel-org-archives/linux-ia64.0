From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 21 Oct 2003 00:10:35 +0000
Subject: Re: [RFC] Endianness and signals
Message-Id: <marc-linux-ia64-106669550812841@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106669369711349@msgid-missing>
In-Reply-To: <marc-linux-ia64-106669369711349@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 21 Oct 2003 00:42:09 +0100, "R. Lake" <rich@lakes.plus.com> said:

  Richard> Further to my study of IA64 architecture, and to an extent
  Richard> the linux kernel, I wonder if the gate page ought to
  Richard> default to little endian upon issue of a signal. i.e. "rum
  Richard> 2" prior to any loads/stores? It would seem to me that in
  Richard> the current state, if the process were preempted
  Richard> immediately after a memory access (fundamentally) in
  Richard> big-endian mode the signal context would likely execute in
  Richard> the wrong endianness and fail.  - It's my understanding
  Richard> that the user mask is preserved in the context switch.

I don't think the psABI requires twiddling the PSR.be bit on signal
delivery (though it probably also does not disallow it).  The thing
is, if you have an applications that's completely big-endian, you'd
probably NOT want to clear PSR.be on a signal.  On the other hand, if
you just have one or two routines which turn on PSR.be, then clearing
the bit is clearly advantageous (e.g., would avoid sigprocmask()
calls).  But given that the current kernel behavior has existed for a
long time, I'm not sure it's a good idea to change the behavior now
(it's not like you _can't_ have big-endian code at the moment).

	--david
