From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 09 Oct 2000 17:31:48 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205563@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 9 Oct 2000 19:21:01 +0200 (MET DST), Dan Pop <Dan.Pop@cern.ch> said:

  Dan> On Mon, 9 Oct 2000, David Mosberger wrote:

  >> >>>>> On Mon, 9 Oct 2000 17:37:35 +0200 (MET DST), Dan Pop
  >> <Dan.Pop@cern.ch> said:
  >> 
  Dan> #include <asm/fpu.h>

  >>  Please don't do this.  Applications must not include Linux
  >> kernel header files.

  Dan> I know.  I wrote it as a quick and dirty hack for Sverre,
  Dan> because no other option was available at the time.

It doesn't matter whether you and I happen to know this.  What matters
is that in the mail you sent out, you gave no indication that it's a
hack and relies on unspecified behavior.  Never recommend to include
kernel header files in applications.

Thanks,

	--david

