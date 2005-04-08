From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Apr 2005 22:33:34 +0000
Subject: Re: Beauties staggering timer interrupt
Message-Id: <16983.1726.808570.594727@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504082221.j38MLFg20356@unix-os.sc.intel.com>
In-Reply-To: <200504082221.j38MLFg20356@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 8 Apr 2005 15:21:20 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> However, when it initialize itm_next, it didn't make any
  Ken> references to the AP's itm_next.  So we end up with random
  Ken> staggering relative to AP's timer interrupt.

Good catch.  You can move the declaration of "shift" inside the "if"
then and drop its initialization.

	--david
