From: Roland McGrath <roland@redhat.com>
Date: Wed, 14 Nov 2007 07:40:13 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <20071114074013.1DD4D26F8B6@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What's arch_ptrace_resume about?  
I thought we were agreed on the plan using TIF_RESTORE_RSE.


Thanks,
Roland
