From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 May 2003 00:25:58 +0000
Subject: Re: [Linux-ia64] Re: new ia64 kernel patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705742@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705722@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705722@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 May 2003 10:01:00 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> On Sun, 11 May 2003 00:02:50 +1000, Keith Owens
  Keith> <kaos@sgi.com> wrote:
  >> * Always save the return address in r28 in addition to b6 ...
  >> ... kernprof only gets the minstate data and it needs the return
  >> address to report the real contention code.

  Keith> Ignore that last bit, b6 is in pt_regs.  I don't know what I
  Keith> was thinking when I wrote that.  But the bit about not
  Keith> appearing in the INIT/MCA minstate dump still applies.

Then fix the dump.  There is certainly not a reason to change normal
kernel code because of something that (for ordinary users) happens
once in a blue moon, if ever.

	--david

