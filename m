From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sun, 09 Feb 2003 05:47:11 +0000
Subject: Re: [Linux-ia64] sigaltstack and RBS
Message-Id: <marc-linux-ia64-105590709805826@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Feb 08, 2003 at 09:27:54PM -0800, David Mosberger wrote:
> 
> It sounds like you're using an old kernel.

Sorry, I should have given more information.  I'm using 2.5.59-ia64-030124.

> I don't recall exactly
> when this was fixed, but recent kernels will put the dirty partition
> on the _new_ stack, not the old one.
> 
> You can check gate.S:ia64_sigtramp().  If it branches to "setup_rbs"
> _before_ the first "alloc" instruction, you should be fine.

Yes, it does.  Hmm, the faults I'm getting are at ia64_sigtramp (exactly).
The first instruction (add r2@,r12) doesn't look like it could possibly
be the cause, so I presume it is the RFI that is forcing a frame to be
loaded (?).

Matt


