From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Jul 2004 22:00:37 +0000
Subject: Re: fix memory corruption/crash for physical-mode EFI calls
Message-Id: <16628.23429.514009.645984@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16623.29412.381259.793452@napali.hpl.hp.com>
In-Reply-To: <16623.29412.381259.793452@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 Jul 2004 09:54:13 -0500, Jack Steiner <steiner@sgi.com> said:

  Jack> FYI, I looked at the SGI boot failures that are occurring on
  Jack> recent 2.6 kernels that have INIT_TASK in region 5. The boot
  Jack> failures are caused by a bug in our PROM. It incorrectly
  Jack> assumes that the stack is identity mapped.

That would do it.  Glad you found the culprit.  One mystery we can
scratch off.

	--david
