From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sun, 09 Feb 2003 10:55:50 +0000
Subject: Re: [Linux-ia64] sigaltstack and RBS
Message-Id: <marc-linux-ia64-105590709805829@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Feb 09, 2003 at 12:48:40AM -0800, David Mosberger wrote:
> 
> The current sigaltstack implementation isn't designed to handle such a
> case.  And I'm not sure whether it should.  Is there a particular
> reason you want to do this sort of thing?

I'll explain the context.  I've written a virtual machine monitor which
currently (for ease of prototyping) runs completely in userspace.
e.g. itc does an mmap, ptc does an munmap, changing RID unmaps a whole
region, SIGSEGV delivers a TLB miss to the "guest" kernel.

Now after a flush or RID change the guest kernel returns to its
userspace with ar.bspstore pointing off to somewhere that isn't mapped,
expecting to get a fault eventually.  This is where the problem occurs.
A mandatory RSE load faults as expected and the kernel tries to deliver
SIGSEGV.  But then the RFI to the signal trampoline repeats the same
RSE load that caused the fault in the first place, before the signal
handler can deal with it.

Is there any reason that the signal trampoline needs to see the
original frame, or would it suffice to give it an empty frame?
(Hmm, presumably this would mean filling out sc_cfm in the kernel...
how to do that if we're in a syscall and haven't done the cover?)

Matt


