From: James E Wilson <wilson@specifix.com>
Date: Fri, 17 Mar 2006 23:15:48 +0000
Subject: Re: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <1142637348.24881.67.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317202301.GA20807@lucon.org>
In-Reply-To: <20060317202301.GA20807@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-03-17 at 13:52, H. J. Lu wrote:
>     *(.gnu.linkonce.t*)

This isn't something you added, but should be fixed just the same.  This
will accidentally cause some thread-local data sections to be merged
into the text section.  The thread-local sections may not have existed
when this code was written, but they do now.  .gnu.linkonce.td.* is used
for linkonce thread local data, and .gnu.linkonce.tb.* is used for
linkonce thread local bss.
-- 
Jim Wilson, GNU Tools Support, http://www.specifix.com

