From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Sat, 23 Nov 2002 07:50:19 +0000
Subject: Re: [Linux-ia64] Horrible mouse performance
Message-Id: <marc-linux-ia64-105590709805480@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805469@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Fri, 22 Nov 2002 12:25:38 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:
Peter> Hi, When using the linux 2.5.45+IA64patch kernel on an I2000,
Peter> the mouse pointer lags actual mouse movements by a long time,
Peter> making X almost unusable.  I haven't configured in the frame
Peter> buffer, if that makes a difference.

David> There certainly are problems with the input layer in 2.5.  So
David> the keyboard is actually working for you?  That's better than
David> it used to be! ;-) Both mouse and keyboard are connected via
David> PS/2, not via USB, I assume?

Yes, this is on an I2000.  I'm trying to see if preemption support
makes any difference.  But the interactive-via-X performance is so
awful anyway, that I can see no difference.

Peter C

