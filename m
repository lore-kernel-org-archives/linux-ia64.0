From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 12 Jul 2004 23:40:13 +0000
Subject: Re: Timer patches (nsec support + fastcalls for gettod/clock_gettime
Message-Id: <B6E8046E1E28D34EB815A11AC8CA3129023F68FA@mtv-atc-605e--n.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 12 Jul 2004, David Mosberger wrote:

> I haven't reviewed the assembly code yet--the fsys-handlers need great
> care (and testing), obviously.  (Does your fsys_gettimeofday() save
> "pr" before modifying p1 etc?  I didn't see it, but like I said, I
> haven't yet fully reviewed the assembly code.  Also, please use ar.itc
> instead of ar44.)

Ok. Will do all of what you said that I did not quote. Do I really
need to save predicates? There are no docs on saving pr and the old
gettimeofday assembly routine did not save the predicates and worked
without a problem.

>  * I think the getnstimeofday() changes won't be accepted.  Instead,
>    probably a better approach is to switch over to gettimeofday()
>    returning a timespec.  IIRC, George Anziger had a patch to do that.
>    Perhaps you can ask him to dust off that patch?

I was not able to find the patch but I will talk to George about this.
However, gettimeofday with a timeval is an established standard. George's
current patches on sf.net use clock_gettime to retrieve higher precision
timer values.

What could be done is to change do_gettimeofday to use a timespec and then
have sys_gettimeofday to the proper scaling. Is that what you were
thinking? But do_gettimeofday is used a gazillion times all over the linux
sources and changing that would result in a huge patch that might not be
acceptable either.

I surely wish there would be some easy way of dealing with the
gettimeofday legacy issue.

