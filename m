From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 May 2004 03:42:24 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <16537.46112.573022.514558@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 06 May 2004 12:04:13 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> On Wed, 5 May 2004 17:19:37 -0700, David Mosberger
  Keith> <davidm@napali.hpl.hp.com> wrote:
  >> I'd have preferred if there had been a simple and clean fix to
  >> the existing unwinder that supports .save rp,r0, but I haven't
  >> seen/found something acceptable yet.

  Keith> The clean patch is a bit bigger than the kludge.

I considered that approach but rejected it because it runs the
"FORTRAN constant" risk.  That is, someone might write to a saved
register (e.g., via unw_set_br()) and end up inadvertently redefining
the 0 "constant" (unw_r0) to a non-zero value.

Perhaps what we could do is change unw_access_{gr,br,fr,ar,pr} to
reject attempts to write to the special save-address &unw_r0.  I think
that would make it safe.

	--david

