From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 24 Sep 2001 20:32:24 +0000
Subject: Re: [Linux-ia64] First Step
Message-Id: <marc-linux-ia64-105590698805246@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805239@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805239@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Sep 2001 13:31:24 -0700, cfk@pacbell.net said:

  Charles> Gentlemen, please pardon if a newbie for a bit. I have the
  Charles> hp cd now with the various rpm files (NUE-1_1, NUE_FS-1,
  Charles> SDI-0_94 & SKI_LINU). I have a reasonable amount of
  Charles> experience in Linux from the x86 viewpoint, but I would
  Charles> like to understand IA-64. So, I would appreciate a few
  Charles> pointers on how to get started.

  Charles> Do I try to rpm install these on a X86 system, probably
  Charles> not.

Yes, the Ski and NUE RPMS are indeed for x86 systems.  Once installed,
you can issue the "nue" command and that will put you in a virtual
environment that looks like an IA-64 machine).

  Charles> I don't yet know how to get an IA-32 system up and
  Charles> running.

Note that IA-32 is just a different name for x86.  They are the same
thing.

  Charles> Assuming I can use one of my existing computers to learn
  Charles> how to do IA-32 and IA-64 work, what is the series of
  Charles> steps.

Since you already know x86, there is nothing you need to do to learn
IA-32.

As for IA-64: NUE and Ski will allow you to do just that.  Since it's
based on a simulator, it will be too slow to run complicated apps, but
for learning the architecture and development and debugging, it's
quite useful.  We even continue to use it for Linux kernel
development.

	--david

