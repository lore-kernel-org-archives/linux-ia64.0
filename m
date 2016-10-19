From: Lorenzo Stoakes <lstoakes@gmail.com>
Date: Wed, 19 Oct 2016 08:58:15 +0000
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly pass FOLL_* flags
Message-Id: <20161019085815.GA22239@lucifer>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161018153050.GC13117@dhcp22.suse.cz>
In-Reply-To: <20161018153050.GC13117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.orglin

On Tue, Oct 18, 2016 at 05:30:50PM +0200, Michal Hocko wrote:
> I am wondering whether we can go further. E.g. it is not really clear to
> me whether we need an explicit FOLL_REMOTE when we can in fact check
> mm != current->mm and imply that. Maybe there are some contexts which
> wouldn't work, I haven't checked.

This flag is set even when /proc/self/mem is used. I've not looked deeply into
this flag but perhaps accessing your own memory this way can be considered
'remote' since you're not accessing it directly. On the other hand, perhaps this
is just mistaken in this case?

> I guess there is more work in that area and I do not want to impose all
> that work on you, but I couldn't resist once I saw you playing in that
> area ;) Definitely a good start!

Thanks, I am more than happy to go as far down this rabbit hole as is helpful,
no imposition at all :)
