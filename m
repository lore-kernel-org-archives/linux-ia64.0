From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Feb 2001 17:57:51 +0000
Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005177@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Feb 2001 11:05:12 -0500, Bill Nottingham <notting@redhat.com> said:

  Bill> Michael Madore (mmadore@turbolinux.com) said:
  >> Has anyone else seen lockups under the 2.4.1 kernel?  I saw two
  >> machines (one Lion, one Big Sur) hang over the weekend.  Both
  >> machines had black screens and wouldn't respond over the network.
  >> 
  >> I had several other boxes running over the weekend with no
  >> problems.  Sorry I don't have any more details at the moment.

  Bill> I've definitely seen some completely random deaths here.

Please be more specific when reporting bugs.  At the least, include
(a) what type of machine and (b) what kernel patch you were running at
the time.  Ideally, also describe what you where doing at the time and
try to get a backtrace with kdb, if possible.

That way, we should be able to at least get an idea of what the
pattern of the failures are.

Having said that, except for the one-time "rpm" hang and the autofs4
instability, my Big Sur has been rock solid.

>>>>> On Wed, 21 Feb 2001 09:16:51 -0800, Gerrit Huizenga <gerrit@us.ibm.com> said:

  Gerrit> I've been seeing these even under 2.4.0 on a Lion.  And my
  Gerrit> current BIOS/EFI is making it difficult to get a serial
  Gerrit> console working to see what happens at the time of machine
  Gerrit> death.

Please don't bother with bug reports against the 2.4.0 patch---it is
known to hang in certain cases.  The latest patch is relative to
2.4.1.

Thanks,

	--david

