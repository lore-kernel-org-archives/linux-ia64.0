From: Marcelo Tosatti <mtosatti@redhat.com>
Date: Thu, 31 May 2012 22:07:37 +0000
Subject: Re: [PATCH] KVM: ia64: Mark ia64 KVM as BROKEN
Message-Id: <20120531220737.GA19287@amt.cnet>
List-Id: <linux-ia64.vger.kernel.org>
References: <1337249648-16894-1-git-send-email-avi@redhat.com>
In-Reply-To: <1337249648-16894-1-git-send-email-avi@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Avi Kivity <avi@redhat.com>
Cc: Xiantao Zhang <xiantao.zhang@intel.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Thu, May 17, 2012 at 01:14:08PM +0300, Avi Kivity wrote:
> Practically all patches to ia64 KVM are build fixes; numerous warnings remain;
> the last patch from the maintainer was committed more than three years ago.  It
> is clear that no one is using this thing.
> 
> Mark as BROKEN to ensure people don't get hit by pointless build problems.
> 
> Signed-off-by: Avi Kivity <avi@redhat.com>

Applied, thanks.

