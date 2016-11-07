From: Lorenzo Stoakes <lstoakes@gmail.com>
Date: Mon, 07 Nov 2016 11:00:50 +0000
Subject: Re: [PATCH 1/2] mm: add locked parameter to get_user_pages()
Message-Id: <20161107110050.GA25313@lucifer>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161031100228.17917-1-lstoakes@gmail.com>
 <20161031100228.17917-2-lstoakes@gmail.com>
 <20161107104918.GQ30704@axis.com>
In-Reply-To: <20161107104918.GQ30704@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: devel@driverdev.osuosl.org, Rik van Riel <riel@redhat.com>, linux-ia64@vger.kernel.org, linux-cris-kernel@axis.com, kvm@vger.kernel.org, linux-rdma@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-media@vger.kernel.org

On Mon, Nov 07, 2016 at 11:49:18AM +0100, Jesper Nilsson wrote:
> For the cris-part:
> Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

Thanks very much for that, however just to avoid any confusion, I realised this
series was not not the right way forward after discussion with Paolo and rather
it makes more sense to keep the API as it is and to update callers where it
makes sense to.
