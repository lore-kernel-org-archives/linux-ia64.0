From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 19 Sep 2001 21:49:28 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805228@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Sep 2001 14:35:24 +0100, Richard Hirst <rhirst@linuxcare.com> said:

  Richard> The following patch fixes this for me.  It seems that after
  Richard> the SET_LEDS command is written, the keyboard sets it's
  Richard> status bit to say the acknowledge is available, but never
  Richard> generates an interrupt.  Or maybe it does generate the
  Richard> interrupt and somehow it gets cleared without the keyboard
  Richard> driver being called.

Glad to see you're making progress on this, but the patch looks
suspicious to me.  There shouldn't be anything ia64 specific in this
code.  It would be good to understand why the keyboard interrupt gets
lost.

	--david

