From: Olof Johansson <olof@lixom.net>
Date: Tue, 29 Jan 2008 21:56:49 +0000
Subject: Re: system hang on latest git
Message-Id: <20080129215648.GB28997@lixom.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC75736A@orsmsx424.amr.corp.intel.com> <20080129201136.GX15220@kernel.dk> <20080129201648.GA15220@kernel.dk> <20080129214653.GA27978@lixom.net> <20080129213852.GF15220@kernel.dk>
In-Reply-To: <20080129213852.GF15220@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <jens.axboe@oracle.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tue, Jan 29, 2008 at 10:38:52PM +0100, Jens Axboe wrote:
> Please try this.

[...]

> The latter is the problem, but since the queue lock is also held before
> doing the double_spin_lock(), we get into even more trouble. The locking
> hierarchy is fine, it's always queue lock -> io context locks, so the
> above patch should be all that is needed to fix this.
> 
> My initial analysis was wrong, that's all :/

Yep, looks much better now.

Tested-by: Olof Johansson <olof@lixom.net>


-Olof
