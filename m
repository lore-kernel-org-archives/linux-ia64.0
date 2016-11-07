From: Jesper Nilsson <jesper.nilsson@axis.com>
Date: Mon, 07 Nov 2016 10:49:18 +0000
Subject: Re: [PATCH 1/2] mm: add locked parameter to get_user_pages()
Message-Id: <20161107104918.GQ30704@axis.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161031100228.17917-1-lstoakes@gmail.com>
 <20161031100228.17917-2-lstoakes@gmail.com>
In-Reply-To: <20161031100228.17917-2-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: devel@driverdev.osuosl.org, Rik van Riel <riel@redhat.com>, linux-ia64@vger.kernel.org, linux-cris-kernel@axis.com, kvm@vger.kernel.org, linux-rdma@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-media@vger.kernel.org

On Mon, Oct 31, 2016 at 10:02:27AM +0000, Lorenzo Stoakes wrote:
> This patch adds an int *locked parameter to get_user_pages() to allow
> VM_FAULT_RETRY faulting behaviour similar to get_user_pages_[un]locked().
> 
> It additionally clears the way for get_user_pages_locked() to be removed as its
> sole remaining useful characteristic was to allow for VM_FAULT_RETRY behaviour
> when faulting in pages.
> 
> It should not introduce any functional changes, however it does allow for
> subsequent changes to get_user_pages() callers to take advantage of
> VM_FAULT_RETRY.

For the cris-part:
Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
