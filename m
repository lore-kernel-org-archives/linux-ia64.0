From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Jun 2003 18:50:28 +0000
Subject: Re: [patch] input: Fix CLOCK_TICK_RATE usage ...  [8/13]
Message-Id: <marc-linux-ia64-105596232527176@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Jun 2003 09:47:44 -0500, Hollis Blanchard <hollisb@us.ibm.com> said:

  Hollis> On Tuesday, Jun 17, 2003, at 18:24 US/Central, David Mosberger wrote:
  >> #ifdef CONFIG_LEGACY_HW
  >> # define PIT_FREQ	1193182
  >> # define LATCH		((CLOCK_TICK_RATE + HZ/2) / HZ)
  >> #endif

  >> This way, machines that support legacy hardware can define
  >> CONFIG_LEGACY_HW and on others, the macro can be left undefined, so
  >> that any attempt to compile drivers requiring legacy hw would fail to
  >> compile upfront (much better than accessing random ports!).

  Hollis> Is "having legacy hardware" an all-or-nothing condition for you? If
  Hollis> not, a CONFIG_LEGACY_PIT might be more appropriate...

I believe it is, though I'm not entirely certain about Intel's Tiger
platform.  If more fine-grained distinction really is needed, I
suspect we'd rather want something called CONFIG_8259_PIT.  Might be a
good idea to do this for all legacy devices.

	--david
