From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Jul 2002 20:22:14 +0000
Subject: Re: Fw: [Linux-ia64] problem in sigtimedwait
Message-Id: <marc-linux-ia64-105590701905775@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 23 Jun 2002 22:33:39 +0530, "kumar" <kumareshind@gmx.net> said:

  Kumar> If somebody else have some idea, please post it asap.
  Kumar> Hello david,
  Kumar> I have attached the test program as you asked for testing
  Kumar> "sigtimedwait".whether it returns proper "si_fd" value.
  Kumar> Please try with this.

  Kumar> I have tested by the following way:
  Kumar> 1)Compiled and run the program
  Kumar> 2)In the other terminal, i have run the command "telnet localhost 5001".
  Kumar> 3)You can view the results in the terminal where the test program is
  Kumar> running.

I tried this and it seems to work as expected:

	$ ./rtsignaltest
	Listening FD is 3
	Signum : 42 : Success
	Signum : 42
	FD     : 0
	BAND   : 65
	Code   : 1
	Signum : -1 : Resource temporarily unavailable
	Unknown signal

Perhaps there is a problem due to an old version of glibc?  I ran the
above on a Debian based system with glibc-2.2.5.  I vaguely recall a
problem with the glibc siginfo structure being out of sync with the
kernel, but that was a long time ago.

	--david

