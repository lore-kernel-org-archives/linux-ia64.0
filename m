From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jun 2002 16:41:18 +0000
Subject: Re: [Linux-ia64] problem in sigtimedwait
Message-Id: <marc-linux-ia64-105590701905689@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905688@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905688@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Jun 2002 16:31:30 +0530, "kumar" <kumareshind@gmx.net> said:

  Kumar> All, Do IA64 Linux release have complete support for RT
  Kumar> Signals.  Or which version has full support for RT signals.

There have not been any recent changes in this area.

  Kumar> The problem we faced is that the : sigtimedwait call does not
  Kumar> return siginfo_t's si_fd value.

Do you have a minimal test program that reproduces the issue?

	--david

