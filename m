From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Jun 2004 04:25:40 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <16590.31300.583565.349947@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 14 Jun 2004 21:17:34 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> We could go for a slightly uglier version of
  Tony> initialize_init_task() that just fixes the list_head elements
  Tony> ... there are only six of them ... so in one respect this
  Tony> isn't too ugly, but it would require maintenance every time
  Tony> someone added/removed a new list from the task structure.

I'm worried that would only defer the pain.  As long as we keep in
mind that static data resides in region 5, we should be OK with
Kaigai's second solution ("current" points to region 5 address for
swapper task).

	--david
