From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 15 Jun 2000 15:40:07 +0000
Subject: Re: [Linux-ia64] signal interface: SIGINFO and sa_sigaction
Message-Id: <marc-linux-ia64-105590678205142@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 Jun 2000 16:28:42 +0100, SCHAN@uk.ibm.com said:

  Sunny> But then the sa_sigaction function does require kernel to
  Sunny> call the handler with parameters (struct siginfo_t), if I
  Sunny> just patch the struct sigaction, will the other pieces of
  Sunny> kernel signal handling routine render those parameters and
  Sunny> pass it to the signal handler? - I am not an kernel expert,
  Sunny> so information is really appericated!

The kernel _always_ passes siginfo and sigcontext as the second and
third arguments to a signal handler.  sa_sigaction is just syntactic
sugar.

	--david


