From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Nov 2003 18:31:06 +0000
Subject: Re: speeding up thread-creation
Message-Id: <marc-linux-ia64-106943948323107@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106940282522654@msgid-missing>
In-Reply-To: <marc-linux-ia64-106940282522654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Nov 2003 09:22:17 -0800, Stephane Eranian <eranian@hpl.hp.com> said:

  Stephane> I assume you want to rely on the thread's flags to
  Stephane> determine if it is worth copying the thread_lazy structure
  Stephane> during a clone.

Yup.  I'd say "necessary" instead of "worth" though.  Also, we know
that the fph partition never needs to be copied (it contains scratch
registers only).

  Stephane> For perfmon, we may need to have two flags: one that says
  Stephane> we are storing information in pmds/pmcs and one that says
  Stephane> we need to context switch the PMU state. Today PM_VALID
  Stephane> flag is used to mean the latter only.

I think that would be fine.  In what cases would you want to clone the
PMU state when PM_VALID is false?

	--david
