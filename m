From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 10 Oct 2001 22:51:50 +0000
Subject: Re: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805325@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Oct 2001 15:31:22 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> I was thinking of hacking up the 'prctl' tool to take a PID
  Jesse> as an argument, that way it could set the flags for any task.
  Jesse> It would allow an initscript to set init's flags, among other
  Jesse> things.  Would such a change qualify as a cleaner solution?

Yes, but how do you change the settings for the target process?
prctl(2) can only change the setting of the calling process (there is
no pid argument).  You can't do it via ptrace() either.

	--david

