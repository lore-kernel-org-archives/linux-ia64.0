From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 02 Aug 2004 09:32:43 +0000
Subject: Re: Timer updates revision 7 (asm sets predicates/various fixes)
Message-Id: <16654.2619.3726.877635@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 30 Jul 2004 08:30:19 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> On Thu, 29 Jul 2004, David Mosberger wrote:
  >> It occurred to me now why your numbers are higher: I linked my
  >> program statically, whereas yours is probably linked dynamically?

  Christoph> Correct. But why would this have an influence?

I'm just trying to determine why our numbers were different.  I dont like
unexplained differences.

	--david
