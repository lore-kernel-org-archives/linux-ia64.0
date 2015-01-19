From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 19 Jan 2015 20:56:27 +0000
Subject: Re: ia64: use current->state helpers
Message-Id: <1421700987.4903.9.camel@stgolabs.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421308200.17403.3.camel@stgolabs.net>
In-Reply-To: <1421308200.17403.3.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2015-01-14 at 23:50 -0800, Davidlohr Bueso wrote:
> Call __set_current_state() instead of assigning the new state directly.
> These interfaces also aid CONFIG_DEBUG_ATOMIC_SLEEP environments, keeping
> track of who changed the state.

ping?


