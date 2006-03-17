From: James E Wilson <wilson@specifix.com>
Date: Fri, 17 Mar 2006 20:53:24 +0000
Subject: Re: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <1142628803.24881.50.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317202301.GA20807@lucon.org>
In-Reply-To: <20060317202301.GA20807@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-03-17 at 12:45, James E Wilson wrote:
> That should be .text.*, not .text*.

And because .text.* doesn't match .text, this actually needs to be
    *(.text .text.*)
Try looking at ld --verbose output, and grepping for .text.
-- 
Jim Wilson, GNU Tools Support, http://www.specifix.com

