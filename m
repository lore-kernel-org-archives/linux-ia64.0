From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2003 18:26:40 +0000
Subject: RE: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-106002225806115@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>    Here's a redesign of the CMC and CPE polling for both 2.6.0-test2
> and 2.4.21.  This is roughly the same design I requested comment on
> a while back (BTW, nobody commented...).  Basically, rather than
> flooding all the cpus in parallel, I used some low priority interrupts
> to cascade through the cpus.  This should be much more scalable.  I
> also added a new feature of enabling interrupts for the CMC and CPE
> handlers.  The SAL spec claims these functions are SMP safe and
> re-entrant and even recommends that the corrected error handlers
> should run with interrupts enabled.  It works on HP boxes, others
> might want to double check that their firmware adheres to the spec.
> The combination of these things should keep polling from impacting
> system response time.  I tried to keep the 2.6 and 2.4 code as similar
> as possible, so I also backported __ffs() to 2.4.  Feedback and bug
> reports welcome.  Thanks,

I think that there are some race conditions around the setting/clearing
of cmc_polling_enabled.

-Tony
