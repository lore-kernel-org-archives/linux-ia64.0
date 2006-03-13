From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 13 Mar 2006 18:55:00 +0000
Subject: Re: [Perfctr-devel] 2.6.16-rc5 perfmon2 new code base + libpfm with Montecito support
Message-Id: <20060313185500.GB32683@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308155311.GD13168@frankl.hpl.hp.com> <4415BC45.1010601@nc.rr.com>
In-Reply-To: <4415BC45.1010601@nc.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@nc.rr.com>
Cc: linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Will,

On Mon, Mar 13, 2006 at 01:39:01PM -0500, William Cohen wrote:
> Hi Stephane,
> 
> I have been looking through the perfmon2 code to see how it is going to 
> work with OProfile. It looks like the ia64 oprofile support has not been 
> modified to work with the changes in perfmon2. Has the ia64 kernel been 
> built with perfmon2 and oprofile support? I don't have easy access to an 
> ia64, so I haven't been able to verify that the attached patch works. 
> However, I expect that the changes in the patch will be required for 
> OProfile to function with perfmon2.
> 
Good timing. I just fixed this today. Now it compiles fine on
IA64.  I also started looking into using the same technique on
i386. It is very easy. It looks like opcontrol or ophelp
would need to be updated. I think the trick is to make
sure that ophelp knows the PMU mapping used by perfmon2,
i.e., knows that PERFEVTSEL0 is PMC0 for instance.

-- 
-Stephane
