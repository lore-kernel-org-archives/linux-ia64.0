From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 19 Oct 2016 08:13:52 +0000
Subject: Re: [PATCH 08/10] mm: replace __access_remote_vm() write parameter with gup_flags
Message-Id: <20161019081352.GB7562@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-9-lstoakes@gmail.com>
 <20161019075903.GP29967@quack2.suse.cz>
In-Reply-To: <20161019075903.GP29967@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Kara <jack@suse.cz>
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, kvm@vger.kernel.org, linux-sh@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Lorenzo Stoakes <lstoakes@gmail.com>, linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.ker

On Wed 19-10-16 09:59:03, Jan Kara wrote:
> On Thu 13-10-16 01:20:18, Lorenzo Stoakes wrote:
> > This patch removes the write parameter from __access_remote_vm() and replaces it
> > with a gup_flags parameter as use of this function previously _implied_
> > FOLL_FORCE, whereas after this patch callers explicitly pass this flag.
> > 
> > We make this explicit as use of FOLL_FORCE can result in surprising behaviour
> > (and hence bugs) within the mm subsystem.
> > 
> > Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> 
> So I'm not convinced this (and the following two patches) is actually
> helping much. By grepping for FOLL_FORCE we will easily see that any caller
> of access_remote_vm() gets that semantics and can thus continue search

I am really wondering. Is there anything inherent that would require
FOLL_FORCE for access_remote_vm? I mean FOLL_FORCE is a really
non-trivial thing. It doesn't obey vma permissions so we should really
minimize its usage. Do all of those users really need FOLL_FORCE?

Anyway I would rather see the flag explicit and used at more places than
hidden behind a helper function.
-- 
Michal Hocko
SUSE Labs
