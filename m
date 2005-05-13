From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 May 2005 20:59:06 +0000
Subject: Re: heads up: apparent GAS bug in current (CVS) binutils
Message-Id: <17029.5402.827349.738563@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
In-Reply-To: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 13 May 2005 13:50:04 -0700, "H. J. Lu" <hjl@lucon.org> said:

  HJ> On Fri, May 13, 2005 at 01:34:10PM -0700, David Mosberger wrote:
  >> >>>>> On Fri, 13 May 2005 10:32:19 -0700, "Lu, Hongjiu"
  >> <hongjiu.lu@intel.com> said:

  HJ> I tried binutils 2.15.92.0.2 20040927 and got the same
  HJ> result. What is the version of assembler which you think is
  HJ> good?
  >>  The standard Debian/sarge as seems fine:

  >> $ as -v GNU assembler version 2.15 (ia64-linux) using BFD version
  >> 2.15

  HJ> As I have mentioned before, it is an IPF specific kernel issue.
  HJ> Basically, when you use weak functions, unwind info may be
  HJ> wrong.  I am enclosing an updated kernel patch.

I agree that this is weird code that needs to be fixed, preferably by
not using weak functions at all (as Andreas suggested).

However, there still seems to be a binutils issues here: if this is
something binutils cannot properly support, it should issue an error,
not silently generate wrong code, no?

	--david
