From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Wed, 14 Apr 2004 15:21:37 +0000
Subject: Re: [Lse-tech] Re: hugetlb demand paging patch part [0/3]
Message-Id: <17200000.1081956095@[10.10.2.4]>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404132317.i3DNH4F21162@unix-os.sc.intel.com> <1081933442.4688.6.camel@laptop.fenrus.com>
In-Reply-To: <1081933442.4688.6.camel@laptop.fenrus.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arjanv@redhat.com, "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, raybry@sgi.com, 'Andy Whitcroft' <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>

>> In addition to the hugetlb commit handling that we've been working on
>> off the list, Ray Bryant of SGI and I are also working on demand paging
>> for hugetlb page.  Here are our final version that has been heavily
>> tested on ia64 and x86.  I've broken the patch into 3 pieces so it's
>> easier to read/review, etc.
> 
> Ok I think it's time to say "HO STOP" here.
> 
> If you're going to make the kernel deal with different, concurrent page
> sizes then please do it for real. Or alternatively leave hugetlb to be
> the kludge/hack it is right now. Anything inbetween is the road to
> madness...

I'd prefer to see it walk step by step to "doing it for real" than have
a huge cataclysmic patch that breaks everything ....

M.

