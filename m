From: Ray Bryant <raybry@sgi.com>
Date: Mon, 22 Nov 2004 19:22:49 +0000
Subject: Re: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <41A23C89.6090903@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A20AF3.9030408@sgi.com> <20041122162214.GE21861@wotan.suse.de> <jept25yggg.fsf@sykes.suse.de> <20041122165425.GG21861@wotan.suse.de>
In-Reply-To: <20041122165425.GG21861@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Andreas Schwab <schwab@suse.de>, Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

OK, apparently SIGPROF is delivered in both the ITIMER_PROF and
pmu interrupt cases, so if we special case that signal we should
be fine.
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
