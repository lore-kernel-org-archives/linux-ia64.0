From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Jun 2004 23:35:48 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F016C4732@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>For the particular case of the init_task, we could just fix it up
>at boot time (as suggested by the earlier patch).
>
>My bigger worry is that this will be an issue _whenever_ somebody
>initializes a linked list with a static initializer.  There needs to
>be a way to protect from this happening accidentially.  Without that,
>I'm not sure the virtual remapping is really viable.

This is only an issue if we view the same structure via both its
region 5 and region 7 aliases.  I think that init_task may currently
be a special case here ... in general arbitrary structures that users
declare and statically initialize with lists will only be referenced
via the region 5 alias ... so they will be safe.

-Tony
