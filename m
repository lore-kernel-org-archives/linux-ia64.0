From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Dec 2003 17:26:03 +0000
Subject: Re: q-tools OOPS: Fixed perfmon.
Message-Id: <marc-linux-ia64-107099147729926@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092926502909@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092926502909@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 09 Dec 2003 08:46:06 -0500, Martin Hicks <mort@bork.org> said:

  Martin> On Mon, 2003-12-08 at 20:24, Matthew Wilcox wrote:

  >> surely there needs to be a matching put_cpu() or else preempt is forever
  >> disabled.  no?

  Martin> I agree.

The put is already there!  See put_cpu_no_resched().

Remember that patches are diffs... ;-)

	--david
