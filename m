From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 05 Mar 2001 19:37:39 +0000
Subject: RE: [Linux-ia64] CONFIG_IA64_L1_CACHE_SHIFT
Message-Id: <marc-linux-ia64-105590693005244@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 2 Mar 2001 15:30:18 -0800 , "Grover, Andrew" <andrew.grover@intel.com> said:

  Andrew> In the future, when we have achieved certain functional
  Andrew> power management milestones under Linux and a significant
  Andrew> number of developers have come to understand the complexity
  Andrew> of the ACPI subsystem, it makes sense that the code be
  Andrew> optimized explicitly for the target OS environment. We
  Andrew> expect that this will happen over time for each OS vendor -
  Andrew> the OS vendor should start maintaining and advancing their
  Andrew> OS specific ACPI implementation.

Yes, I agree with this.  My mail wasn't so much meant to critize the
existing code (like you say: it does what it is designed for...) but
to encourage others to think about developing a leaner, more tightly
integrated version for Linux.  I think it would be a nice challenge to
see what could be done in this area, but it would definitely be a
non-trivial project.

	--david

