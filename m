From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 19 Sep 2005 06:44:33 +0000
Subject: RE: Volanomark regress on ia64
Message-Id: <200509190644.j8J6iZg01092@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509160040.j8G0eFg06734@unix-os.sc.intel.com>
In-Reply-To: <200509160040.j8G0eFg06734@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nick Piggin wrote on Sunday, September 18, 2005 3:57 AM
> It looks like the problem is confined to ia64? Are the x86-64 machines
> also running with HZ set to 250?

Yes, it appears to be confined to ia64.  X86-64 machines are running at
250 Hz and there is no perf. regression there.


> I would look at differences between SD_CPU_INIT for ia64 versus the
> generic definition. cache_hot_time and cache_nice_tries by the looks,
> both those could cause increased idle time.

Thanks for the suggestion.  My first experiment was in those area as
well, in particular changing newidle_idx and idle_idx.  I have not yet
come up any concrete resolution.

- Ken

