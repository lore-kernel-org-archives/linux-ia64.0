From: "Chris McDermott" <mcdermoc@us.ibm.com>
Date: Wed, 21 Feb 2001 18:58:22 +0000
Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005180@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Feb 2001 11:05:12 -0500, Bill Nottingham
<notting@redhat.com> said:

  Bill> Michael Madore (mmadore@turbolinux.com) said:
  >> Has anyone else seen lockups under the 2.4.1 kernel?  I saw two
  >> machines (one Lion, one Big Sur) hang over the weekend.  Both
  >> machines had black screens and wouldn't respond over the network.
  >>
  >> I had several other boxes running over the weekend with no
  >> problems.  Sorry I don't have any more details at the moment.

  Bill> I've definitely seen some completely random deaths here.

David> Please be more specific when reporting bugs.  At the least, include
David> (a) what type of machine and (b) what kernel patch you were running
at
David> the time.  Ideally, also describe what you where doing at the time
and
David> try to get a backtrace with kdb, if possible.

David> That way, we should be able to at least get an idea of what the
David> pattern of the failures are.

David> Having said that, except for the one-time "rpm" hang and the autofs4
David> instability, my Big Sur has been rock solid.


David,

I have seen similar symptoms on our IBM IA64 NUMA hardware. We are
running an in-house memory diagnostics test and a CPU benchmark
concurrently (strictly to keep the CPUs busy and to generate some remote
I/O). I have been assuming that this was a hardware problem (of course I
would, I'm a software guy). When I saw reports that other people were
seeing similar behavior on SDVs, I decided to try to reproduce this on a
4x Lion (B3's with BIOS 71, 2.4.1 kernel with your 0131 IA64 patch). Using
the
same tests, I was able to reproduce a "lockup" problem on the Lion (system
dead, no video). Not sure if it's the same problem yet, still need to do
some
more investigation.

Anyway, I have ITPs connected to the IBM hardware and have noticed that
when the lockup occurs, and we lose video, at least one of the CPUs is
executing in flush_tlb_no_ptcg() or handle_IPI(), in the 'do' loop where
TLB
entries are being purged. What I have observed is that the end address and
the start address are in completely different regions. Usually, the start
address
is in region register 1 (address of 0x2000XXXXXXXXXXXX) and the end address
is in region register 3 (address of 0x6000XXXXXXXXXXXX). I don't know if
this
is the same problem I am seeing on the Lion, but I plan to connect and ITP
and
a serial console (although we haven't been able to get one to work yet on
the
Lion with BIOS 71) to see if the symptoms are the same.


Chris



