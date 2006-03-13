From: William Cohen <wcohen@nc.rr.com>
Date: Mon, 13 Mar 2006 19:15:53 +0000
Subject: Re: [Perfctr-devel] 2.6.16-rc5 perfmon2 new code base + libpfm with
Message-Id: <4415C4E9.5070702@nc.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308155311.GD13168@frankl.hpl.hp.com> <4415BC45.1010601@nc.rr.com> <20060313185500.GB32683@frankl.hpl.hp.com>
In-Reply-To: <20060313185500.GB32683@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, oprofile-list <oprofile-list@lists.sourceforge.net>

Stephane Eranian wrote:
> Will,
> 
> On Mon, Mar 13, 2006 at 01:39:01PM -0500, William Cohen wrote:
> 
>>Hi Stephane,
>>
>>I have been looking through the perfmon2 code to see how it is going to 
>>work with OProfile. It looks like the ia64 oprofile support has not been 
>>modified to work with the changes in perfmon2. Has the ia64 kernel been 
>>built with perfmon2 and oprofile support? I don't have easy access to an 
>>ia64, so I haven't been able to verify that the attached patch works. 
>>However, I expect that the changes in the patch will be required for 
>>OProfile to function with perfmon2.
>>
> 
> Good timing. I just fixed this today. Now it compiles fine on
> IA64.  I also started looking into using the same technique on
> i386. It is very easy. It looks like opcontrol or ophelp
> would need to be updated. I think the trick is to make
> sure that ophelp knows the PMU mapping used by perfmon2,
> i.e., knows that PERFEVTSEL0 is PMC0 for instance.
> 

Yes, I have a similar patch for i386 in the kernel. I don't yet have 
modifications for opcontrol or ophelp.

One question would be identifying the processor when using the perfmon2 
support for i386/* processors? There is prior support in the oprofile 
driver for i386 processors. Identify the processor differently depending 
on whether perfmon2 is being used to distinguish between the different 
interfaces? The way that OProfile has the events each name processor 
requires a different directory in /usr/share/oprofile. Would prefer to 
keep down the proliferation of new directories.

-Will
