From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 May 2003 06:51:37 +0000
Subject: [Linux-ia64] Re: 2.5.69 process.c: cpu_idle() cleanup
Message-Id: <marc-linux-ia64-105590723705750@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705738@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705738@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 12 May 2003 22:09:17 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> It was actually a deliberate decision of mine to not make it a machine
  Jes> vector, because this was meant to be an optional feature. With a
  Jes> machine vector one always ends up calling a dummy function on
  Jes> platforms that do not wish to do anything here.

  Jes> I'll be happy to change it over to a machine vector if you still
  Jes> prefer, let me know.

It doesn't make a huge difference either way.  But I definitely want
there to be only a single function/callback.  In fact, if you load the
function pointer into a local variable, the load (and NULL check) can
be amortized across both calls and we can rest assured that we squeze
every single cycle out of the idle loop! ;-)

(Actually, on the more serious side, we don't want to waste CPU cycles
outright in the idle loop either, as that could negatively affect
power consumption---not that it makes a huge difference on current
generation CPUs.)

	--david

