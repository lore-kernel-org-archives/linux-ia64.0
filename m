From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 30 Sep 2003 22:10:23 +0000
Subject: Re: [PATCH] disable legacy floppy related ioctl32s
Message-Id: <marc-linux-ia64-106496011230402@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106495318021597@msgid-missing>
In-Reply-To: <marc-linux-ia64-106495318021597@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 30 September 2003 3:01 pm, Randy.Dunlap wrote:
> On Tue, 30 Sep 2003 14:55:00 -0600 Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> | BTW, it looks like one can still select legacy floppy support on ia64:
> | 
> | config BLK_DEV_FD
> |         tristate "Normal floppy disk support"
> |         depends on !X86_PC9800 && !ARCH_S390
> 
> Yes, I submitted a patch for that (and others), but it was rejected
> by reasoning that we can't and don't want to keep up with fixing
> all of these...

Heh.  Your patch (http://www.ussg.iu.edu/hypermail/linux/kernel/0308.3/0320.html)
contained:

	 config BLK_DEV_FD
	 tristate "Normal floppy disk support"
	 - depends on !X86_PC9800
	 + depends on !X86_PC9800 && !IA64

so obviously somebody decided it was reasonable to do it for s390, but
not for ia64 :-)  I didn't see the rejection rationale on the list, but
it's hard enough to build a working .config without distractions like
being asked about drivers that can't possibly work (and probably don't
even compile) on my architecture.

Bjorn

