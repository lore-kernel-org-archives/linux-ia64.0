From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Jun 2004 23:25:59 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <16583.40071.498807.557162@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Jun 2004 15:44:09 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> I think it would be better to fix up init_task so that it
  Tony> appeared to be in region 7 (that way it isn't a special case
  Tony> ... it just looks like every other task).  BUT, I'm not sure
  Tony> how easy that is to do without surgery to generic files
  Tony> (places that use "&init_task").

For the particular case of the init_task, we could just fix it up
at boot time (as suggested by the earlier patch).

My bigger worry is that this will be an issue _whenever_ somebody
initializes a linked list with a static initializer.  There needs to
be a way to protect from this happening accidentially.  Without that,
I'm not sure the virtual remapping is really viable.

	--david
