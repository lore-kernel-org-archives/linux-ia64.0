From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jun 2004 05:23:03 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <16583.61495.638457.369405@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Jun 2004 22:19:28 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  >> void initialize_init_task (void) { *current = (task_t)
  >> INIT_TASK((*current)); }

  >> and then call this function from setup_arch().

  >> The code does compile but doesn't seem to work.  I suspect there
  >> are other lists that are inconsistent now.  Anybody want to track
  >> this down?

  Tony> Don't you need a "ia64_tpa()" call in there someplace to
  Tony> convert the region 5 address to region 7?

"current" already contains the region 7 address.  Perhaps I'm misunderstanding
what you're saying, though.

	--david
