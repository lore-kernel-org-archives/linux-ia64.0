From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 19 Oct 2016 17:23:55 +0000
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly pass FOLL_* flags
Message-Id: <5807AC2B.4090208@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161018153050.GC13117@dhcp22.suse.cz> <20161019085815.GA22239@lucifer>
 <20161019090727.GE7517@dhcp22.suse.cz> <5807A427.7010200@linux.intel.com>
 <20161019170127.GN24393@dhcp22.suse.cz>
In-Reply-To: <20161019170127.GN24393@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Lorenzo Stoakes <lstoakes@gmail.com>, linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org, linux-fs

On 10/19/2016 10:01 AM, Michal Hocko wrote:
> The question I had earlier was whether this has to be an explicit FOLL
> flag used by g-u-p users or we can just use it internally when mm !> current->mm

The reason I chose not to do that was that deferred work gets run under
a basically random 'current'.  If we just use 'mm != current->mm', then
the deferred work will sometimes have pkeys enforced and sometimes not,
basically randomly.

We want to be consistent with whether they are enforced or not, so we
explicitly indicate that by calling the remote variant vs. plain.
