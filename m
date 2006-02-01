From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Wed, 01 Feb 2006 03:12:26 +0000
Subject: Re: FW: [patch 1/6] remove dead code in ia64_leave_kernel
Message-Id: <ed5aea430601311912ncbc9ea5oc28cb6a2fe17e81@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310907.k0V976g12698@unix-os.sc.intel.com>
In-Reply-To: <200601310907.k0V976g12698@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/31/06, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:

> Having said that, I have a craze idea of optimize away two bsp reads
> along with cover instruction in the syscall leave path.  I'm still
> exploring whether that is achievable or not.  If we can do that, then
> all that latency would go away along with the code that this patch moved.

That would be nice, indeed.

  --david
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
