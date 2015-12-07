From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 07 Dec 2015 16:33:30 +0000
Subject: RE: [PATCH v2 8/8] treewide: Remove newlines inside DEFINE_PER_CPU() macros
Message-Id: <063D6719AE5E284EB5DD2968C1650D6D1CBE695F@AcuExch.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449242787-16598-1-git-send-email-mmarek@suse.com>
 <1449242787-16598-9-git-send-email-mmarek@suse.com>
In-Reply-To: <1449242787-16598-9-git-send-email-mmarek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Michal Marek' <mmarek@suse.com>, "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

From: Michal Marek
> Sent: 04 December 2015 15:26
> Otherwise make tags can't parse them:
> 
> ctags: Warning: arch/ia64/kernel/smp.c:60: null expansion of name pattern "\1"
...

Seems to me you need to fix ctags.

	David
