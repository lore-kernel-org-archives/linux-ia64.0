From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 30 Sep 2003 22:18:06 +0000
Subject: Re: [PATCH] disable legacy floppy related ioctl32s
Message-Id: <marc-linux-ia64-106496061531070@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106495318021597@msgid-missing>
In-Reply-To: <marc-linux-ia64-106495318021597@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> Heh.  Your patch (http://www.ussg.iu.edu/hypermail/linux/kernel/0308.3/0320.html)
> contained:
> 
> 	 config BLK_DEV_FD
> 	 tristate "Normal floppy disk support"
> 	 - depends on !X86_PC9800
> 	 + depends on !X86_PC9800 && !IA64
> 
> so obviously somebody decided it was reasonable to do it for s390, but
> not for ia64 :-)  I didn't see the rejection rationale on the list, but
> it's hard enough to build a working .config without distractions like
> being asked about drivers that can't possibly work (and probably don't
> even compile) on my architecture.

There's some discussion here too:

http://marc.theaimsgroup.com/?t6015010700002&r=1&w=2

depends on ISA || M68K || SPARC64

seems to be what was suggested in the thread, but I didn't see a patch. I also agree that the check should be in one place (KConfig). Will send a new patch.

	-Arun


