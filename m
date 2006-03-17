From: James E Wilson <wilson@specifix.com>
Date: Fri, 17 Mar 2006 23:54:28 +0000
Subject: Re: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <1142639668.24881.109.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317202301.GA20807@lucon.org>
In-Reply-To: <20060317202301.GA20807@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-03-17 at 15:31, H. J. Lu wrote:
> I guess we never used TLS in EFI applications before. It doesn't
> really matter since TLS needs more than the linker script change.

True, but there is always the danger that someone might copy this linker
script somewhere else where it does matter.  So we may as well get it
right.

This version looks good to me.
-- 
Jim Wilson, GNU Tools Support, http://www.specifix.com

