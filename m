From: Andy Whitcroft <apw@shadowen.org>
Date: Wed, 14 Apr 2004 10:08:14 +0000
Subject: Re: hugetlb demand paging patch part [0/3]
Message-Id: <8822415.1081940894@42.150.104.212.access.eclipse.net.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404132317.i3DNH4F21162@unix-os.sc.intel.com>
 <1081933442.4688.6.camel@laptop.fenrus.com>
In-Reply-To: <1081933442.4688.6.camel@laptop.fenrus.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arjanv@redhat.com, "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, raybry@sgi.com, Andrew Morton <akpm@osdl.org>

--On 14 April 2004 11:04 +0200 Arjan van de Ven <arjanv@redhat.com> wrote:

> On Wed, 2004-04-14 at 01:17, Chen, Kenneth W wrote:
>> In addition to the hugetlb commit handling that we've been working on
>> off the list, Ray Bryant of SGI and I are also working on demand paging
>> for hugetlb page.  Here are our final version that has been heavily
>> tested on ia64 and x86.  I've broken the patch into 3 pieces so it's
>> easier to read/review, etc.
> 
> Ok I think it's time to say "HO STOP" here.

I would say yes for 2.7.  Then things like actual swapping of large pages
and the like could be done properly.

> If you're going to make the kernel deal with different, concurrent page
> sizes then please do it for real. Or alternatively leave hugetlb to be
> the kludge/hack it is right now. Anything inbetween is the road to
> madness...

The original request was not to generify for 2.6.  Thus all of this work
has been to fix or improve the usability of the kludge without removing its
cancerous sore like nature.  I think that requires a radical rethink and is
not 2.6 material.

-apw
