From: Jes Sorensen <jes@sgi.com>
Date: Mon, 31 Jul 2006 09:22:38 +0000
Subject: Re: [PATCH 0/2] Fix RAID5 + IA64 compile
Message-Id: <yq01ws29li9.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060728140145.9149.43458.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20060728140145.9149.43458.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prarit Bhargava <prarit@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-scsi@vger.kernel.org

>>>>> "Prarit" = Prarit Bhargava <prarit@sgi.com> writes:

Prarit> Patchset to fix RAID5 on ia64.  Removes dead CONFIG options
Prarit> and introduces a new CONFIG option.

Prarit,

Looking through that patch, why introduce a new CONFIG_ option when it
can all be deducted from CONFIG_MDRAID456 and CONFIG_ia64?

Cheers,
Jes
