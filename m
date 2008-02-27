From: Roland McGrath <roland@redhat.com>
Date: Wed, 27 Feb 2008 20:49:21 +0000
Subject: Re: [patch 2/3] regset IA64 implementation
Message-Id: <20080227204921.5128F2700FD@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1203928720.3841.20.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1203928720.3841.20.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for this work, I'm very glad to see it!

The regset layouts look right to me.  Note that for full parity with native
x86, the ia32 view set needs to add NT_386_TLS too.  

It is up to ia64 to decide how the innards should look.  
However, I do have a few suggestions.

Firstly, I would recommend splitting this into a few more separate patches.
e.g. define CORE_DUMP_USE_REGSET in a separate patch after adding the
user_regset accessors.  This makes it easier to isolate problems quickly
should any arise later on, using git-bisect.

The writeback hook should use TIF_RESTORE_RSE.  If I understand correctly,
calling ia64_sync_user_rbs without regard to TIF_RESTORE_RSE might actually
break things.  It's certainly suboptimal.  Ideally, when TIF_RESTORE_RSE is
already set, you shouldn't even call into unw_*.  ia64_ptrace_stop is
nearly correct as the writeback hook already, it just needs to handle both
current and non-current task arguments.


Thanks,
Roland
