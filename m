From: Robin Holt <holt@sgi.com>
Date: Mon, 22 Nov 2004 17:19:32 +0000
Subject: Re: scalability of signal delivery for Posix Threads
Message-Id: <20041122171932.GA19440@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A20AF3.9030408@sgi.com>
In-Reply-To: <41A20AF3.9030408@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

On Mon, Nov 22, 2004 at 09:51:15AM -0600, Ray Bryant wrote:
> We've encountered a scalability problem with signal delivery.  Our 
> application
> is attempting to use ITIMER_PROF to deliver one signal per clock tick to 
> each
> thread of a ptrheaded (NPTL).  These threads are created with CLONE_SIGHAND,
> so that there is a single sighand->siglock for the entire application.

Ray, can you provide a simple example application that trips this case?
