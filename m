From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Dec 2003 01:21:48 +0000
Subject: Re: Unwind bug on out of line code called from leaf functions
Message-Id: <marc-linux-ia64-107110576623219@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106989195923088@msgid-missing>
In-Reply-To: <marc-linux-ia64-106989195923088@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 26 Nov 2003 22:52:50 -0800, Jim Wilson <wilson@specifixinc.com> said:

  Jim> On Wed, 2003-11-26 at 20:28, David Mosberger wrote:

  >> gcc-3.3.2 also can handle ar.pfs clobbers, so we may just want to
  >> update the kernel code to be a bit more premissive and not insist
  >> on >= gcc-3.4.  I'm not exactly sure though when this got fixed,
  >> so somebody would have to look into that first.

  Jim> The patch is in gcc-3.3.0.  See Richard Henderson's 2003-04-26
  Jim> ia64 change in gcc.  However, that patch resulted in an ICE in
  Jim> some other cases, and unnecessary saves/restores of ar.pfs, see
  Jim> gcc PR 10681.  The patch for that is in gcc-3.3.1.  See Richard
  Jim> Henderson's 2003-06-26 change in gcc.

  Jim> It would be reasonable to just check for >= gcc-3.3 for use of
  Jim> this feature.  I wouldn't recommend using gcc-3.3.0 though.

OK, I'm changing the kernel now to check for >= gcc-3.3.

Thanks!

	--david
