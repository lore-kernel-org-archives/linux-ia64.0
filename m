From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Dec 2003 17:29:03 +0000
Subject: Re: gcc builtin memcpy is bogus?
Message-Id: <marc-linux-ia64-107090506304484@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107090003129207@msgid-missing>
In-Reply-To: <marc-linux-ia64-107090003129207@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 8 Dec 2003 16:01:24 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> This is a fun one ... I don't know what to blame for this.

  Matthew> struct rfd {
  Matthew>   u16 status;
  Matthew>   u16 command;
  Matthew>   u32 link;
  Matthew>   u32 rbd;
  Matthew>   u16 actual_size;
  Matthew>   u16 size;
  Matthew> };

  Matthew> The kernel doesn't use -fno-builtin or -fno-builtin-memcpy
  Matthew> so it attempts to optimise this by doing 4-byte loads and
  Matthew> stores.  Problem is, the destination is misaligned
  Matthew> (deliberately), so the kernel emits unaligned messages.
  Matthew> Adding -fno-builtin to the command line turns this back
  Matthew> into a call to memcpy.

The code is wrong.  If it's 2-byte aligned, use

	attribute ((packed) (aligned (2))

to mark it as such (check on the syntax of the attributes, I probably
got it wrong).

	--david
