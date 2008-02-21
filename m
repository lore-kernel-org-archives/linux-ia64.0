From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 21 Feb 2008 19:40:03 +0000
Subject: Re: [PATCH 03/11] xen: add missing definitions for xen grant table
Message-Id: <47BDD393.5080307@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080221084530.470680000@ls.local.valinux.co.jp> <20080221091001.314830000@ls.local.valinux.co.jp>
In-Reply-To: <20080221091001.314830000@ls.local.valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yamahata@valinux.co.jp
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, linux-ia64@vger.kernel.org, xen-ia64-devel@lists.xensource.com, Chris Wright <chrisw@sous-sol.org>, "Stephen C. Tweedie" <sct@redhat.com>

yamahata@valinux.co.jp wrote:

Yep.  We removed the guest handle stuff for the initial upstreaming, 
since it isn't necessary on x86 and it quietened some of the reviewer 
noise.  But I expected we'd need to reintroduce it at some stage.

    J
