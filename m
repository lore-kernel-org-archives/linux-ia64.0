From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Feb 2004 02:35:38 +0000
Subject: Re: HUGEPAGE SIZE a boottime option
Message-Id: <16437.29306.947060.600300@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 19 Feb 2004 19:07:31 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> Here is a preliminary version of a patch that makes the size
  Jack> of HUGEPAGES a boottime option. Only ia64-specific files are
  Jack> changed (except for the Documentation file).

  Jack> We have a number of customers using large
  Jack> pages. Unfortunately, the "optimum" size of a large page is
  Jack> application & configuration dependent. Rather that having each
  Jack> customer recompile to specify their own HUGEPAGESIZE, this
  Jack> patch make the size a boottime option.

  Jack> Does this patch look reasonable? If so, I will incorporate feedback,
  Jack> finish testing it, update it to 2.6.3 & resubmit.

Looks neat to me.  But, man, do lose that trailing whitespace!
(especially in Kconfig---all 166 characters of it! ;-)

Rohit?

	--david
