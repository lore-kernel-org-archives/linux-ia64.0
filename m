From: Jan Kara <jack@suse.cz>
Date: Tue, 18 Oct 2016 12:43:05 +0000
Subject: Re: [PATCH 01/10] mm: remove write/force parameters from __get_user_pages_locked()
Message-Id: <20161018124305.GA29967@quack2.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-2-lstoakes@gmail.com>
In-Reply-To: <20161013002020.3062-2-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.orglin

On Thu 13-10-16 01:20:11, Lorenzo Stoakes wrote:
> This patch removes the write and force parameters from __get_user_pages_locked()
> to make the use of FOLL_FORCE explicit in callers as use of this flag can result
> in surprising behaviour (and hence bugs) within the mm subsystem.
> 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
