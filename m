From: Andi Kleen <ak@suse.de>
Date: Mon, 22 Nov 2004 16:54:25 +0000
Subject: Re: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <20041122165425.GG21861@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A20AF3.9030408@sgi.com> <20041122162214.GE21861@wotan.suse.de> <jept25yggg.fsf@sykes.suse.de>
In-Reply-To: <jept25yggg.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

On Mon, Nov 22, 2004 at 05:51:59PM +0100, Andreas Schwab wrote:
> Andi Kleen <ak@suse.de> writes:
> 
> > At least in traditional signal semantics you have to call sigaction
> > or signal in each signal handler to reset the signal. So that 
> > assumption is not necessarily true.
> 
> If you use sigaction then you get POSIX semantics, which don't have this
> problem.

It's just a common case where Ray's assumption is not true.

-Andi
