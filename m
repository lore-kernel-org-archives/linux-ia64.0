From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 26 Oct 2001 17:05:24 +0000
Subject: Re: [Linux-ia64] Lion problems with 2.4.13...
Message-Id: <marc-linux-ia64-105590698805399@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805398@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805398@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Oct 2001 18:58:27 +0200 (MEST), Erich Focht <efocht@ess.nec.de> said:

  Erich> The latest kernel crashes for me on the Lion we have
  Erich> here. The same kernel runs fine on a BigSur.

  Erich> The Lion is a 4 CPU B3, 4GB memory, OEM version, BIOS 83B. It
  Erich> works fine with kernels up to 2.4.7 but hangs for newer
  Erich> kernel short time after switching to runlevel 3.

  Erich> Did anybody else see this problem on LIONs?

I suspect you need newer firmware.  Build 99 seems to be good (ask
Intel how to get it).

	--david

