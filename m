From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Feb 2004 20:08:22 +0000
Subject: Re: megaraid warnings
Message-Id: <16434.29878.769928.305667@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16434.28509.327706.76307@napali.hpl.hp.com>
In-Reply-To: <16434.28509.327706.76307@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Feb 2004 19:58:47 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> This keeps coming up on linux-scsi; basically these are
  Matthew> ioctls that are called by some binary-only (and
  Matthew> x86-binary-only at that) management program.  so if they
  Matthew> want to ship an ia64 version of their management program,
  Matthew> they'll have to fix this; otherwise the addresses are
  Matthew> guaranteed to be in the lower 32 bits of the address space.

Then why not disable the offending code for 64-bit platforms for the
time being?

	--david
