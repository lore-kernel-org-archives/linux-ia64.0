From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 20 May 2002 18:26:00 +0000
Subject: Re: [Linux-ia64] Registers are incorrect in panic message
Message-Id: <marc-linux-ia64-105590701905587@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905583@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 May 2002 08:06:37 -0700, Ken Pearlstein <pearlste@sgi.com> said:

  Ken> When the system panics, linux prints the contents of the
  Ken> register file.  Registers 0-31 are OK, the rest are garbage.
  Ken> Has this problem been addressed ?

What do you mean by "rest"?  The stacked registers?  If they are
incorrect, that's news to me (they used to be correct, but I haven't
checked recently).

	--david

