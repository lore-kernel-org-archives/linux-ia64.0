From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Feb 2004 20:18:07 +0000
Subject: Re: megaraid warnings
Message-Id: <16434.30463.969436.102136@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16434.28509.327706.76307@napali.hpl.hp.com>
In-Reply-To: <16434.28509.327706.76307@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Feb 2004 20:09:18 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Tue, Feb 17, 2004 at 12:08:22PM -0800, David Mosberger
  Matthew> wrote:
  >> >>>>> On Tue, 17 Feb 2004 19:58:47 +0000, Matthew Wilcox
  >> <willy@debian.org> said:

  Matthew> This keeps coming up on linux-scsi; basically these are
  Matthew> ioctls that are called by some binary-only (and
  Matthew> x86-binary-only at that) management program.  so if they
  Matthew> want to ship an ia64 version of their management program,
  Matthew> they'll have to fix this; otherwise the addresses are
  Matthew> guaranteed to be in the lower 32 bits of the address space.

  >>  Then why not disable the offending code for 64-bit platforms for
  >> the time being?

  Matthew> Because it works when the x86 app is run in emulation.

Ah, your mail wasn't clear on this.  In that case, I'd suggest to fix
the code as I suggested in the earlier mail.

	--david
