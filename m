From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 23 Oct 2004 08:25:42 +0000
Subject: Re: ptrace problem in 2.6.9
Message-Id: <16762.5510.635288.946710@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041022170557.GW19372@frankl.hpl.hp.com>
In-Reply-To: <20041022170557.GW19372@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Oct 2004 10:05:57 -0700, Stephane Eranian <eranian@hpl.hp.com> said:

  Stephane> Hi Roland, I have some problems with the recent
  Stephane> modifications to the Ptrace infrastructure in 2.6.9
  Stephane> release. Basically I have the smiple test program attached
  Stephane> to this E-mail and it hangs in 2.6.9 but not in
  Stephane> 2.6.9-rc4. Somehow the first waitpid() does not return. It
  Stephane> is not clear to me why.  Is there something Ineed to
  Stephane> change in the call itself?  I am running all of this on a
  Stephane> 2-way IA-64 machine with 2.6.9. I have not tried on x86.

Shoot, I think I ran into the same problem yesterday when running the
GCC testsuite.  In my case, the problem seemed to disappear (mostly)
after downgrading "expect" from the "unstable" to the "stable"
version, but the symptoms where exactly like in your case: waitpid()
didn't return, so I suspect it really was the kernel's fault.  I'll
try Roland's patch on Monday.

	--david
