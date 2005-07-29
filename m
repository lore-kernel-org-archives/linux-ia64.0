From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 29 Jul 2005 07:45:42 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <10766.1122623142@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Fri, 29 Jul 2005 00:22:43 MST."
             <200507290722.j6T7Mig07477@unix-os.sc.intel.com> 
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Ingo Molnar' <mingo@elte.hu>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, 29 Jul 2005 00:22:43 -0700, 
"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>On ia64, we have two kernel stacks, one for outgoing task, and one for
>incoming task.  for outgoing task, we haven't called switch_to() yet.
>So the switch stack structure for 'current' will be allocated immediately
>below current 'sp' pointer. For the incoming task, it was fully ctx'ed out
>previously, so switch stack structure is immediate above kernel_stack(next).
>It Would be beneficial to prefetch both stacks.

struct switch_stack for current is all write data, no reading is done.
Is it worth doing prefetchw() for current?  IOW, is there any
measurable performance gain?

