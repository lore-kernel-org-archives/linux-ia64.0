From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 04 Jun 2004 14:26:12 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406040724040.3221@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 3 Jun 2004, David Mosberger wrote:

> Do you know about the "nolwsys" option?  It already patches the
> fsyscall-table at boot time.  Now this isn't something that we should
> go overboard with, but in a few select cases, it may indeed be
> reasonable (and the patch would have to be limited to boot-time, to
> avoid races etc.).
>
> It would, however, be good to share as much source code as possible
> between the different implementations.  For example, me thinks the
> HPET-version of fsys_gettimeofday() would look almost identical to the
> SN2-version and some of the existing fsys_gettimeofday() source code
> should be sharable as well.  So if someone wants to pursue this in
> earnest, it might make sense to move fsys_gettimeofday() into a
> separate file.

Ahh. Interesting. This is likely in the scope of my work.

