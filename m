From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 06:29:19 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16576.5823.37997.996516@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 3 Jun 2004 13:04:12 -0700, Chris Wedgwood <cw@f00f.org> said:

  Chris> On Wed, Jun 02, 2004 at 10:33:39AM -0700, David Mosberger wrote:
  >> Does this really make a substantial difference?  My guess is no and,
  >> if so, I'd rather not add any more #ifdefs.

  Chris> How about have the sn2 init code stomp over this value and point to
  Chris> some local code as required?

Do you know about the "nolwsys" option?  It already patches the
fsyscall-table at boot time.  Now this isn't something that we should
go overboard with, but in a few select cases, it may indeed be
reasonable (and the patch would have to be limited to boot-time, to
avoid races etc.).

It would, however, be good to share as much source code as possible
between the different implementations.  For example, me thinks the
HPET-version of fsys_gettimeofday() would look almost identical to the
SN2-version and some of the existing fsys_gettimeofday() source code
should be sharable as well.  So if someone wants to pursue this in
earnest, it might make sense to move fsys_gettimeofday() into a
separate file.

	--david
