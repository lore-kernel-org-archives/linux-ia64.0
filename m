From: Paolo Bonzini <pbonzini@redhat.com>
Date: Mon, 31 Oct 2016 11:45:36 +0000
Subject: Re: [PATCH 2/2] mm: remove get_user_pages_locked()
Message-Id: <cc508436-156e-eb4b-ae01-b44f33c2d692@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161031100228.17917-1-lstoakes@gmail.com>
 <20161031100228.17917-3-lstoakes@gmail.com>
In-Reply-To: <20161031100228.17917-3-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, kvm@vger.kernel.org, linux-media@vger.kernel.org, devel@driverdev.osuosl.org



On 31/10/2016 11:02, Lorenzo Stoakes wrote:
> - *
> - * get_user_pages should be phased out in favor of
> - * get_user_pages_locked|unlocked or get_user_pages_fast. Nothing
> - * should use get_user_pages because it cannot pass
> - * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.

This comment should be preserved in some way.  In addition, removing
get_user_pages_locked() makes it harder (compared to a simple "git grep
-w") to identify callers that lack allow-retry functionality).  So I'm
not sure about the benefits of these patches.

If all callers were changed, then sure removing the _locked suffix would
be a good idea.

Paolo
