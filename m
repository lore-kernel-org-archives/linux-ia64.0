From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Dec 2003 03:22:04 +0000
Subject: Re: q-tools OOPS: Fixed perfmon.
Message-Id: <marc-linux-ia64-107094017311501@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092926502909@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092926502909@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 8 Dec 2003 17:57:04 -0800, Stephane Eranian <eranian@hpl.hp.com> said:

  Stephane> Peter, Yes, clearly you do not want to preempt in the
  Stephane> perfmon interrupt handler.  I think we need to also make
  Stephane> sure we do not preempt during the perfmonctl() system
  Stephane> call, at least until we verify that there is no
  Stephane> assumptions in there.  Similarly in all the VFS entry
  Stephane> points, such as pfm_close(). I will try and see what I can
  Stephane> do before the end of the week.

  Stephane> Thanks for your patch.

I did put in Peter's fix in my tree, since it fixes a known crash and
is obviously correct.

	--david
