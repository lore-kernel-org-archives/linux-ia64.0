From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Jan 2002 19:15:11 +0000
Subject: Re: [Linux-ia64] Re: can we make anonymous memory non-EXECUTABLE?
Message-Id: <marc-linux-ia64-105590698805777@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805771@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805771@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Jan 2002 13:23:15 +0000 (GMT), Alan Cox <alan@lxorguk.ukuu.org.uk> said:

  Alan> We are borg of x86 is true for the near future, but codifying
  Alan> an x86ism for all ports for ever seems unwise.

Glad to hear that.

  Alan> For IA32 on IA64 binaries you would however need to keep the
  Alan> executable data behaviour.

Yes.  I don't recall off hand whether the x86 emulation hardware (aka
"IVE") automatically takes care of that.  I'll work on prototyping
this.

Thanks,

	--david

