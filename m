From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Nov 2002 04:51:04 +0000
Subject: Re: [Linux-ia64] Debugging early ode under the simulator
Message-Id: <marc-linux-ia64-105590709805419@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805418@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805418@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Nov 2002 15:41:38 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi, There's no easy way to set breakpoints or watchpoints in
  Peter> the kernel before the kernel starts running, when running
  Peter> under the SKI simulator.

  Peter> One way to fix this is appended.

I usually would just look for the indirect branch in _start(), but
that's admittedly not the most obvious way to go about it.  Your
solution is easier for new users, so I applied a (slightly modified)
version of it.

Thanks,

	--david

