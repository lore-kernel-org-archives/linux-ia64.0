From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 09 Dec 2002 16:37:35 +0000
Subject: [Linux-ia64] Re: backtrace()...
Message-Id: <marc-linux-ia64-105590709805520@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 09 Dec 2002 15:33:37 +0100, Fons Rademakers <Fons.Rademakers@cern.ch> said:

  Fons> Hi David, I try to use backtrace() (/usr/include/execinfo.h)
  Fons> but it returns nothing meaningfull (one 0 stackframe). This is
  Fons> on Itanium2:

  Fons> Kernel 2.4.18-e.4smp glibc-2.2.4-29.2

  Fons> Is this expected or should I do something special?

Yes, the backtrace() in glibc is hopeless.  libunwind implements a
working version of backtrace() (see
http://www.hpl.hp.com/research/linux/libunwind/).

	--david

