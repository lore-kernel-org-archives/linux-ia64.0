From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 15 Sep 2000 15:43:46 +0000
Subject: Re: [Linux-ia64] setjmp/longjmp : flushing register stack
Message-Id: <marc-linux-ia64-105590678205497@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205495@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205495@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 15 Sep 2000 16:17:55 +0100, SCHAN@uk.ibm.com said:

  Sunny> We are developing the Linux/IA64 Java VM and we need
  Sunny> sigsetjmp/setjmp flushing the register stack properly -
  Sunny> however currently it only flush on the call of longjmp - is
  Sunny> there any chance of adding flushrs into setjmp/sigsetjmp? We
  Sunny> could do it in our code but there will be rather
  Sunny> inconvenient...

Please explain why you want this.  The setjmp/longjmp semantics does
not require a register stack flush on setjmp and given that in most
programs setjmp is called much more frequently than longjmp, doing so
would involve a substantial performance hit.

	--david

