From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 Jul 2004 18:46:28 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <16618.62340.963969.957946@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 30 Jun 2004 09:23:52 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> On Tuesday, June 29, 2004 5:04 pm, David Mosberger wrote:
  >> <jbarnes@engr.sgi.com> (04/06/29 1.1807)
  >> [PATCH] ia64: update early printk for new console driver

  Jesse> Btw, with this new early console setup stuff,
  Jesse> CONFIG_IA64_EARLY_PRINTK is obsolete.  If we tie in the other
  Jesse> early consoles, we can probably drop that part of the ia64
  Jesse> patch altogether.

Sounds fine to me, but someone will have to send me a patch for this
to happen.

	--david
