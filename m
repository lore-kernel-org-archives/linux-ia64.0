From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 22 Nov 2002 18:51:49 +0000
Subject: Re: [Linux-ia64] Horrible mouse performance
Message-Id: <marc-linux-ia64-105590709805476@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805469@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Nov 2002 12:25:38 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi, When using the linux 2.5.45+IA64patch kernel on an I2000,
  Peter> the mouse pointer lags actual mouse movements by a long time,
  Peter> making X almost unusable.  I haven't configured in the frame
  Peter> buffer, if that makes a difference.

There certainly are problems with the input layer in 2.5.  So the
keyboard is actually working for you?  That's better than it used to
be! ;-) Both mouse and keyboard are connected via PS/2, not via USB, I
assume?

(I don't normally see such problems because I do most of my 2.5 work
remotely, without console access.)

	--david

