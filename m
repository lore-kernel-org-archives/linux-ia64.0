From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Jul 2004 20:41:56 +0000
Subject: Re: fix memory corruption/crash for physical-mode EFI calls
Message-Id: <16626.63380.998369.350919@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16623.29412.381259.793452@napali.hpl.hp.com>
In-Reply-To: <16623.29412.381259.793452@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 10 Jul 2004 09:54:05 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> On Friday, July 9, 2004 9:39 pm, David Mosberger wrote:
  >> I think you'll want to try out the patch below.  If my guess is
  >> correct and the SGI firmware doesn't support switching into
  >> virtual mode, then this may fix the boot-problem you are seeing
  >> on SN2.

  Jesse> I believe we do.  IIRC we can call into our PROM in either
  Jesse> physical or virtual mode.

Ah, in that case the patch won't help.  Too bad.

	--david
