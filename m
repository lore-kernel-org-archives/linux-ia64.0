From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Oct 2003 23:36:28 +0000
Subject: Re: user-space unaligned accesses
Message-Id: <marc-linux-ia64-106565620208556@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106562414203331@msgid-missing>
In-Reply-To: <marc-linux-ia64-106562414203331@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 Oct 2003 16:54:07 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> On Wednesday 08 October 2003 3:46 pm, Grant Grundler wrote:
  >> On Wed, Oct 08, 2003 at 08:42:00AM -0600, Bjorn Helgaas wrote:
  >> > ...
  >> > The ia64 architecture does a tty_write
  >> > on a userspace unaligned access. Not only is this extremenly annoying,
  >> > it's also very broken since the tty may well be suspended etc etc.
  >> > Doing a printk on such an access by default is very broken already,
  >> > lets not make it worse

  >> This was beat to death on linux-ia64 already where davidm and davem
  >> decided to disagree on the utility of printing unaligned accesses
  >> to the tty.

  Bjorn> I thought that discussion was mainly about messages printed by the
  Bjorn> kernel using printk.

Correct.

  Bjorn> The Red Hat concern was specifically about writing to the
  Bjorn> user tty.

There are users (other than me ;-) that find the messages helpful.  If
there is something wrong about the current printing code, I'd rather
fix that instead (and as Grant pointed out, if someone doesn't like
the message, prctl can be used to turn it off).  The mail you
forwarded was unclear on whether there was a real security/correctness
bug.  If there is, please ask for/provide details.

	--david
