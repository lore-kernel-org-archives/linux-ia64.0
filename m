From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 22 Nov 2004 16:07:05 +0000
Subject: Re: scalability of signal delivery for Posix Threads
Message-Id: <20041122160705.GG25636@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A20AF3.9030408@sgi.com>
In-Reply-To: <41A20AF3.9030408@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

On Mon, Nov 22, 2004 at 09:51:15AM -0600, Ray Bryant wrote:
> Since signals are sent much more often than sigaction() is called, it would
> seem to make more sense to make sigaction() take a heavier weight lock of
> some kind (to update the signal handler decription) and to have the signal
> delivery mechanism take a lighter weight lock.  Making 
> current->sighand->siglock a rwlock_t really doesn't improve the situation
> much, since cache line contention is just a severe in that case (if not 
> worse) than it is with the current definition.

What about RCU or seqlock?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
