From: James E Wilson <wilson@specifix.com>
Date: Fri, 17 Mar 2006 23:07:50 +0000
Subject: Re: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <1142636870.24881.58.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317202301.GA20807@lucon.org>
In-Reply-To: <20060317202301.GA20807@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-03-17 at 13:52, Matthew Wilcox wrote:
> I believe his point is that .text* matches .textual and .texterific and
> many other sections which shouldn't be matched.  So you need to match
> .text and .text.*, not just .text*

Exactly.

The best example I can give is that I've fixed broken linker scripts in
libgloss that tried to match linkonce small data sections using
.gnu.linkonce.s*, without realizing that linkonce small bss sections are
.gnu.linkonce.sb.*.  This caused some C++ programs to fail in strange
and difficult to debug ways.  Those dots are important.
-- 
Jim Wilson, GNU Tools Support, http://www.specifix.com

