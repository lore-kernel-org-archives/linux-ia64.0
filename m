From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 19 Oct 2006 21:21:37 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061019212137.GN2602@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 19, 2006 at 02:05:19PM -0700, Stephane Eranian wrote:
> I don't think this is going to work for the simple reason that perfmon supports per-thread
> monitoring. As a thread migrates from one CPU to another, its PMU state migrates with it.
> So you cannot reload a full Montecito state onto a Madison PMU. You will not crash, because
> write to unimplemented PMD are ignored but you will get false results. Even in system-wide
> tools are not prepare to cope with mixed configurations.

I suppose you could lock a thread to running only on the kind of CPU it
started running on.  It's not a great solution though.

