From: Jes Sorensen <jes@linuxcare.com>
Date: Tue, 08 Aug 2000 19:36:13 +0000
Subject: Re: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205283@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Gerrit" = Gerrit Huizenga <Gerrit.Huizenga@us.ibm.com> writes:

Gerrit> I noted recently that I couldn't build a kernel on the Lion
Gerrit> when rlogin'd to the machine, but at the console I seem to
Gerrit> have no problem.

Gerrit> Could the problems be a deadlock or other problem in the
Gerrit> test1/test4 linux tcp code?

I have actually noticed that my machine seems slightly more stable
when compiling without spewing the output to a remote window. Ie. if I
compile XFree in a remote window it is almost certain to lock up, but
both times I tried running it directing the output from stdout/stderr
to a local file the build actually completed. This is on a UP A2 Lion
btw.

I would actually suspect that eepro100 driver or similar.

Jes

