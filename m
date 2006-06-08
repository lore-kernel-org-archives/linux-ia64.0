From: Keith Owens <kaos@sgi.com>
Date: Thu, 08 Jun 2006 06:36:52 +0000
Subject: Re: [PATCH] printing support for MCA/INIT
Message-Id: <7954.1149748612@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4486BE32.80100@jp.fujitsu.com>
In-Reply-To: <4486BE32.80100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" (on Wed, 7 Jun 2006 23:01:54 -0700) wrote:
>> I guess there are only 2 cases actually needs to display its progress,
>> long time wait on rendezvous and INIT-monarch. 
>
>In the MCA case, something bad has already happened to the system,
>it is possible that we will not complete printing all of the
>messages, but if they are streaming directly to the console, then
>at least we will see the first part of the messages.  If you buffer
>them to be printed later, there may be no "later", and all the
>information will be lost.

Also consider that crash dump may be invoked from MCA/INIT.  The
various crash dump analysis tools all expect to find the messages in
the dmesg buffer in the dump.  Adding a special print buffer just for
MCA/INIT means changing all the crash dump tools to look in two places.

The existing 'oops_in_progress' code is working pretty well.  It does
leave nasty bits behind if the MCA is recoverable, but that problem is
not bad enough to justify a completely separate print mechanism plus
changes to external programs.  Instead we should fix the unwanted side
effects of oops_in_progress.

It is possible to make the core of printk completely NMI safe.  We can
make it lockless, or retain the locks but detect that there is no
movement and ignore the lock.  The SN2 serial console does the latter,
see drivers/serial/sn_console.c::sn_sal_console_write().  This means
that SN2 machines can safely write to the console even from MCA/INIT.
printk can use the same technique to lock access to its print buffer.


	/* somebody really wants this output, might be an
	 * oops, kdb, panic, etc.  make sure they get it. */
	if (spin_is_locked(&port->sc_port.lock)) {
		int lhead = port->sc_port.info->xmit.head;
		int ltail = port->sc_port.info->xmit.tail;
		int counter, got_lock = 0;

		/*
		 * We attempt to determine if someone has died with the
		 * lock. We wait ~20 secs after the head and tail ptrs
		 * stop moving and assume the lock holder is not functional
		 * and plow ahead. If the lock is freed within the time out
		 * period we re-get the lock and go ahead normally. We also
		 * remember if we have plowed ahead so that we don't have
		 * to wait out the time out period again - the asumption
		 * is that we will time out again.
		 */

		for (counter = 0; counter < 150; mdelay(125), counter++) {
			if (!spin_is_locked(&port->sc_port.lock)
			    || stole_lock) {
				if (!stole_lock) {
					spin_lock_irqsave(&port->sc_port.lock,
							  flags);
					got_lock = 1;
				}
				break;
			} else {
				/* still locked */
				if ((lhead != port->sc_port.info->xmit.head)
				    || (ltail !					port->sc_port.info->xmit.tail)) {
					lhead 						port->sc_port.info->xmit.head;
					ltail 						port->sc_port.info->xmit.tail;
					counter = 0;
				}
			}
		}
		/* flush anything in the serial core xmit buffer, raw */
		sn_transmit_chars(port, 1);
		if (got_lock) {
			spin_unlock_irqrestore(&port->sc_port.lock, flags);
			stole_lock = 0;
		} else {
			/* fell thru */
			stole_lock = 1;
		}
		puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
	} else {
		stole_lock = 0;
		spin_lock_irqsave(&port->sc_port.lock, flags);
		sn_transmit_chars(port, 1);
		spin_unlock_irqrestore(&port->sc_port.lock, flags);

		puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
	}

