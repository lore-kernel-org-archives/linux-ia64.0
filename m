From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 25 Oct 2004 07:51:37 +0000
Subject: Re: ptrace problem in 2.6.9
Message-Id: <16764.45193.900066.555108@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041022170557.GW19372@frankl.hpl.hp.com>
In-Reply-To: <20041022170557.GW19372@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 23 Oct 2004 01:25:42 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

>>>>> On Fri, 22 Oct 2004 10:05:57 -0700, Stephane Eranian <eranian@hpl.hp.com> said:
  Stephane> Hi Roland, I have some problems with the recent
  Stephane> modifications to the Ptrace infrastructure in 2.6.9
  Stephane> release. Basically I have the smiple test program attached
  Stephane> to this E-mail and it hangs in 2.6.9 but not in
  Stephane> 2.6.9-rc4. Somehow the first waitpid() does not return. It
  Stephane> is not clear to me why.  Is there something Ineed to
  Stephane> change in the call itself?  I am running all of this on a
  Stephane> 2-way IA-64 machine with 2.6.9. I have not tried on x86.

  David> Shoot, I think I ran into the same problem yesterday when
  David> running the GCC testsuite.  In my case, the problem seemed to
  David> disappear (mostly) after downgrading "expect" from the
  David> "unstable" to the "stable" version, but the symptoms where
  David> exactly like in your case: waitpid() didn't return, so I
  David> suspect it really was the kernel's fault.  I'll try Roland's
  David> patch on Monday.

Then again, may be not: it appears that the bug only relates to
PTRACE'd processes, which "expect" is unlikely to do.  Oh, well, would
have been too easy.

	--david
