From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 03 Feb 2003 23:43:28 +0000
Subject: Re: [Linux-ia64] Preempt problems
Message-Id: <marc-linux-ia64-105590709805805@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805801@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805801@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Feb 2003 09:33:31 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> I just got one of these on a straight 2.5.59+davidm's
  Peter> patches, on a vanilla zx2000.  The kernel address is always
  Peter> the same, at 0xffe6bf10, regardless of the kernel, and
  Peter> regardless of the command that was (apparently) running at
  Peter> the time.

Can't say I have ever seen anything like this.  It does look like the
top 32 bits somehow get truncated to zero.  Rather weird.

  Peter> I'm at a loss as to how to debug this thing now.  Can anyone
  Peter> suggest anything?  It *could* be a hardware problem (I've had
  Peter> problems with this machine before).

If you had problems before, a hw problem sounds like a real
possibility.  If I can find some time, I'll try your patch on some of
our machines.

	--david

