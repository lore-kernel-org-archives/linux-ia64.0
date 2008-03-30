From: Paul Mackerras <paulus@samba.org>
Date: Sun, 30 Mar 2008 10:53:07 +0000
Subject: Re: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <18415.28947.208842.304790@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	<20080329001341.7F93826FA1D@magilla.localdomain>
	<alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Linus Torvalds writes:

> Of course, it may well not be worth it. Unlike the TIF flags, the TS flags 
> have been architecture-specific and I don't think all architectures even 
> do them (x86 uses them for FP state bits and stuff like that).

Powerpc has a "local_flags" field.  I don't mind changing it if we are
going to have a consistent name across architectures, but "status" (as
x86 uses) seems a bit nondescript to me.

Paul.
