From: Ray Bryant <raybry@sgi.com>
Date: Mon, 22 Nov 2004 19:25:09 +0000
Subject: Re: scalability of signal delivery for Posix Threads
Message-Id: <41A23D15.3040207@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A20AF3.9030408@sgi.com> <20041122171932.GA19440@lnx-holt.americas.sgi.com>
In-Reply-To: <20041122171932.GA19440@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

Robin Holt wrote:
> On Mon, Nov 22, 2004 at 09:51:15AM -0600, Ray Bryant wrote:
> 
>>We've encountered a scalability problem with signal delivery.  Our 
>>application
>>is attempting to use ITIMER_PROF to deliver one signal per clock tick to 
>>each
>>thread of a ptrheaded (NPTL).  These threads are created with CLONE_SIGHAND,
>>so that there is a single sighand->siglock for the entire application.
> 
> 
> Ray, can you provide a simple example application that trips this case?

I'll do that, but it may be after the Thanksgiving holiday when I get it
out to the mailing list.  It's a minor thing, but the test we are using
now is an OpenMP application (written in .c) and I'd propose rewriting
it using POSIX threads without OpenMP for a more general audience

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
