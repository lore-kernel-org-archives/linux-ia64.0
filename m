From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jun 2004 00:58:41 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <16583.45633.130888.933576@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Jun 2004 16:35:48 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> This is only an issue if we view the same structure via both
  Tony> its region 5 and region 7 aliases.  I think that init_task may
  Tony> currently be a special case here ... in general arbitrary
  Tony> structures that users declare and statically initialize with
  Tony> lists will only be referenced via the region 5 alias ... so
  Tony> they will be safe.

You're probably right.

We _could_ do something like this in init_task.c:

void
initialize_init_task (void)
{
	*current = (task_t) INIT_TASK((*current));
}

and then call this function from setup_arch().

The code does compile but doesn't seem to work.  I suspect there are
other lists that are inconsistent now.  Anybody want to track this
down?


	--david
